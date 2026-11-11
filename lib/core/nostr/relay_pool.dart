import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:crypto/crypto.dart';

import 'event.dart';
import 'filter.dart';
import 'relay.dart';
import 'signer.dart';

/// One relay of the user's list with its NIP-65 role.
class RelayConfig {
  final String url;
  final bool read;
  final bool write;
  const RelayConfig(this.url, {this.read = true, this.write = true});

  RelayConfig copyWith({bool? read, bool? write}) =>
      RelayConfig(url, read: read ?? this.read, write: write ?? this.write);

  Map<String, dynamic> toJson() => {'url': url, 'read': read, 'write': write};

  factory RelayConfig.fromJson(Map<String, dynamic> json) => RelayConfig(
    json['url'] as String,
    read: json['read'] as bool? ?? true,
    write: json['write'] as bool? ?? true,
  );

  @override
  bool operator ==(Object other) =>
      other is RelayConfig &&
      other.url == url &&
      other.read == read &&
      other.write == write;

  @override
  int get hashCode => Object.hash(url, read, write);

  @override
  String toString() => 'RelayConfig($url, r=$read, w=$write)';
}

class PublishReport {
  final String eventId;
  final Map<String, bool> relayResults; // url -> accepted
  final Map<String, String> relayMessages; // url -> relay's answer
  const PublishReport(
    this.eventId,
    this.relayResults, {
    this.relayMessages = const {},
  });

  int get acceptedCount => relayResults.values.where((ok) => ok).length;
  bool get publishedSomewhere => acceptedCount > 0;

  /// Why the first relay refused, for user-facing error messages.
  String? get firstFailureReason {
    for (final entry in relayResults.entries) {
      if (!entry.value) {
        final msg = relayMessages[entry.key];
        if (msg != null && msg.isNotEmpty) return '${entry.key}: $msg';
      }
    }
    return null;
  }
}

/// Signs the NIP-42 AUTH event for [relayUrl]/[challenge].
typedef AuthSigner = Future<NostrEvent> Function(
  String relayUrl,
  String challenge,
);

/// Handle on an open subscription. Events are deduplicated per
/// subscription, signature-checked and filtered to match the request, so a
/// second subscription for the same data still receives everything.
class PoolSubscription {
  final String id;
  final Stream<NostrEvent> events;

  /// Completes when every relay finished sending stored events (EOSE), or
  /// after a timeout. The subscription stays open for live events.
  final Future<void> eose;
  final void Function() _onClose;
  bool _closed = false;

  PoolSubscription._(this.id, this.events, this.eose, this._onClose);

  bool get isClosed => _closed;

  void close() {
    if (_closed) return;
    _closed = true;
    _onClose();
  }
}

class _Sub {
  final String id;
  final List<NostrFilter> filters;
  final bool authRequired;
  final bool onlyExtra;
  final controller = StreamController<NostrEvent>();
  final seen = <String>{};
  final relays = <String>{};
  final extra = <String>{};
  final eoseWaiting = <String>{};
  final closedByAuth = <String>{};
  final eose = Completer<void>();
  Timer? eoseTimer;

  /// See `straggler` in [RelayPool.subscribe].
  Duration? straggler;
  Timer? stragglerTimer;

  /// Events of this subscription still waiting for signature verification:
  /// EOSE must not be reported before they were delivered.
  int pending = 0;

  _Sub(this.id, this.filters, this.authRequired, this.onlyExtra);
}

class _Entry {
  final Relay relay;
  RelayConfig? config; // null → ephemeral (extra) relay
  int refs = 0;
  Timer? idleTimer;
  _Entry(this.relay, this.config);
}

/// Multi-relay pool. The relay set is dynamic ([updateRelays]) so
/// subscriptions survive settings changes; events are verified once (off the
/// UI isolate) and routed per subscription; publishes report per relay.
class RelayPool {
  final Map<String, _Entry> _entries = {};
  final Map<String, _Sub> _subs = {};
  final Map<String, String> _verified = {};
  final _statusController =
      StreamController<Map<String, RelayConnectionState>>.broadcast();
  final List<(_Sub, NostrEvent)> _queue = [];
  final Map<String, Future<bool>> _authInFlight = {};
  Timer? _flushTimer;
  int _counter = 0;
  bool _disposed = false;

  /// When false (e.g. in tests), signatures are not verified.
  final bool verifySignatures;
  final Duration eoseTimeout;

  /// Set while a user that can sign is logged in; enables NIP-42 AUTH for
  /// relays that require it (needed by private messages).
  AuthSigner? authSigner;

  RelayPool(
    Iterable<RelayConfig> relays, {
    this.verifySignatures = true,
    this.eoseTimeout = const Duration(seconds: 8),
  }) {
    updateRelays(relays);
  }

  List<RelayConfig> get relays => [
    for (final e in _entries.values)
      if (e.config != null) e.config!,
  ];

  List<String> get readRelays => [
    for (final e in _entries.values)
      if (e.config?.read == true) e.relay.url,
  ];

  List<String> get writeRelays => [
    for (final e in _entries.values)
      if (e.config?.write == true) e.relay.url,
  ];

  Map<String, RelayConnectionState> get statuses => {
    for (final e in _entries.values) e.relay.url: e.relay.state,
  };

  Stream<Map<String, RelayConnectionState>> get statusStream =>
      _statusController.stream;

  // ── relay set management ────────────────────────────────────────────

  /// Replaces the configured relay set without touching open
  /// subscriptions: new read relays join them, removed ones leave.
  void updateRelays(Iterable<RelayConfig> configs) {
    if (_disposed) return;
    final wanted = <String, RelayConfig>{};
    for (final c in configs) {
      final url = normalizeRelayUrl(c.url);
      if (url == null) continue;
      final prev = wanted[url];
      wanted[url] = prev == null
          ? RelayConfig(url, read: c.read, write: c.write)
          : RelayConfig(
              url,
              read: prev.read || c.read,
              write: prev.write || c.write,
            );
    }

    final wasRead = {
      for (final e in _entries.values) e.relay.url: e.config?.read == true,
    };

    // Removed or demoted relays.
    for (final entry in _entries.values.toList()) {
      final next = wanted[entry.relay.url];
      entry.config = next;
      if (next == null && entry.refs <= 0) {
        _disposeEntry(entry);
        continue;
      }
      if ((wasRead[entry.relay.url] ?? false) && next?.read != true) {
        for (final sub in _subs.values) {
          if (!sub.onlyExtra && !sub.extra.contains(entry.relay.url)) {
            entry.relay.unsubscribe(sub.id);
            sub.relays.remove(entry.relay.url);
            sub.eoseWaiting.remove(entry.relay.url);
          }
        }
      }
    }

    // Added or promoted relays.
    for (final config in wanted.values) {
      final entry = _entries[config.url] ?? _createEntry(config.url, config);
      entry.config = config;
      if (config.read && !(wasRead[config.url] ?? false)) {
        for (final sub in _subs.values) {
          if (sub.onlyExtra || sub.relays.contains(config.url)) continue;
          sub.relays.add(config.url);
          entry.relay.subscribe(sub.id, sub.filters);
        }
      }
    }
    _emitStatus();
  }

  _Entry _createEntry(String url, RelayConfig? config) {
    final relay = Relay(url)
      ..onEvent = ((subId, event) => _onEvent(subId, event))
      ..onEose = ((subId) => _onEose(url, subId))
      ..onClosed = ((subId, message) => _onClosed(url, subId, message))
      ..onAuthChallenge = ((challenge) => _onAuthChallenge(url))
      ..onStateChanged = ((state) => _onRelayState(url, state));
    final entry = _Entry(relay, config);
    _entries[url] = entry;
    return entry;
  }

  void _disposeEntry(_Entry entry) {
    entry.idleTimer?.cancel();
    _entries.remove(entry.relay.url);
    entry.relay.dispose();
    for (final sub in _subs.values) {
      sub.relays.remove(entry.relay.url);
      sub.eoseWaiting.remove(entry.relay.url);
      _checkEose(sub);
    }
  }

  _Entry _retain(String url) {
    final entry = _entries[url] ?? _createEntry(url, null);
    entry.refs++;
    entry.idleTimer?.cancel();
    entry.idleTimer = null;
    return entry;
  }

  void _release(String url) {
    final entry = _entries[url];
    if (entry == null) return;
    entry.refs--;
    if (entry.refs <= 0 && entry.config == null) {
      entry.idleTimer?.cancel();
      entry.idleTimer = Timer(const Duration(seconds: 25), () {
        if (entry.refs <= 0 && entry.config == null && !_disposed) {
          _disposeEntry(entry);
        }
      });
    }
  }

  /// Opens the connections of the configured relays ahead of the first
  /// request, so the first screen does not wait for the handshakes.
  void connect() {
    for (final e in _entries.values) {
      if (e.config != null) e.relay.connect();
    }
  }

  /// Before a refresh, and when the app returns to the foreground: connects
  /// the relays that are down and replaces the connections that died without
  /// saying so (see [Relay.checkAlive]). Await it *before* asking for
  /// something: a request sent on a dead socket is lost, and one open while
  /// its relay is replaced stops waiting for that relay.
  Future<void> wake({
    Duration quiet = const Duration(seconds: 15),
    Duration timeout = const Duration(seconds: 3),
  }) async {
    if (_disposed) return;
    await Future.wait([
      for (final e in _entries.values.toList())
        if (e.config != null || e.refs > 0)
          e.relay.checkAlive(quiet: quiet, timeout: timeout),
    ]);
  }

  // ── subscriptions ───────────────────────────────────────────────────

  /// Subscribes on the configured read relays plus [extraRelays] (e.g. an
  /// author's own relays, NIP-65 outbox model). With [onlyExtra] the
  /// configured relays are skipped. [authRequired] makes the pool answer
  /// NIP-42 AUTH challenges for this subscription. With [straggler], once one
  /// relay has finished answering the others get at most that long before
  /// EOSE is reported: a relay that never answers then costs seconds, not
  /// the whole [eoseTimeout].
  PoolSubscription subscribe(
    List<NostrFilter> filters, {
    Iterable<String> extraRelays = const [],
    bool onlyExtra = false,
    bool authRequired = false,
    Duration? eoseTimeout,
    Duration? straggler,
  }) {
    final id = 'ml${_counter++}';
    final sub = _Sub(id, filters, authRequired, onlyExtra)
      ..straggler = straggler;
    _subs[id] = sub;

    final urls = <String>{if (!onlyExtra) ...readRelays};
    for (final raw in extraRelays) {
      final url = normalizeRelayUrl(raw);
      if (url == null || !isSafeRemoteRelayUrl(url) && !_isConfigured(url)) {
        continue;
      }
      if (!sub.extra.contains(url) && !urls.contains(url)) {
        _retain(url);
        sub.extra.add(url);
      }
      urls.add(url);
    }
    sub.relays.addAll(urls);
    sub.eoseWaiting.addAll(urls);

    sub.eoseTimer = Timer(eoseTimeout ?? this.eoseTimeout, () {
      if (!sub.eose.isCompleted) sub.eose.complete();
    });
    for (final url in urls) {
      _entries[url]?.relay.subscribe(id, filters);
    }
    _checkEose(sub);

    return PoolSubscription._(
      id,
      sub.controller.stream,
      sub.eose.future,
      () => _closeSub(sub),
    );
  }

  bool _isConfigured(String url) => _entries[url]?.config != null;

  void _closeSub(_Sub sub) {
    if (_subs.remove(sub.id) == null) return;
    sub.eoseTimer?.cancel();
    sub.stragglerTimer?.cancel();
    for (final url in sub.relays) {
      _entries[url]?.relay.unsubscribe(sub.id);
    }
    for (final url in sub.extra) {
      _release(url);
    }
    if (!sub.eose.isCompleted) sub.eose.complete();
    if (!sub.controller.isClosed) sub.controller.close();
  }

  static String _fingerprint(NostrEvent event) =>
      sha256.convert(utf8.encode(jsonEncode(event.toJson()))).toString();

  void _onEvent(String subId, NostrEvent event) {
    final sub = _subs[subId];
    if (sub == null || sub.seen.contains(event.id)) return;
    if (event.isExpired()) return;
    if (!sub.filters.any((f) => f.matches(event))) return;
    if (!verifySignatures || _verified[event.id] == _fingerprint(event)) {
      _deliver(sub, event);
      return;
    }
    sub.pending++;
    _queue.add((sub, event));
    _flushTimer ??= Timer(const Duration(milliseconds: 30), _flushQueue);
  }

  void _deliver(_Sub sub, NostrEvent event) {
    if (sub.controller.isClosed || !sub.seen.add(event.id)) return;
    sub.controller.add(event);
  }

  Future<void> _flushQueue() async {
    _flushTimer = null;
    if (_queue.isEmpty || _disposed) return;
    final batch = List.of(_queue);
    _queue.clear();
    final unique = <String, NostrEvent>{};
    for (final (_, e) in batch) {
      unique.putIfAbsent(_fingerprint(e), () => e);
    }
    final toVerify = [
      for (final entry in unique.entries)
        if (_verified[entry.value.id] != entry.key) entry.value,
    ];
    Set<String> good;
    if (toVerify.length <= 3) {
      good = {
        for (final e in toVerify)
          if (verifyEventSignature(e)) _fingerprint(e),
      };
    } else {
      final jsons = [for (final e in toVerify) e.toJson()];
      try {
        good = (await Isolate.run(() => _verifyAll(jsons))).toSet();
      } catch (_) {
        good = {
          for (final e in toVerify)
            if (verifyEventSignature(e)) _fingerprint(e),
        };
      }
    }
    if (_disposed) return;
    final valid = <String>{...good};
    for (final entry in unique.entries) {
      if (_verified[entry.value.id] == entry.key) valid.add(entry.key);
    }
    if (_verified.length > 8000) _verified.clear();
    for (final entry in unique.entries) {
      if (good.contains(entry.key)) _verified[entry.value.id] = entry.key;
    }
    final touched = <_Sub>{};
    for (final (sub, event) in batch) {
      sub.pending--;
      touched.add(sub);
      if (valid.contains(_fingerprint(event)) && _subs.containsKey(sub.id)) {
        _deliver(sub, event);
      }
    }
    for (final sub in touched) {
      _checkEose(sub);
    }
  }

  void _onEose(String url, String subId) {
    final sub = _subs[subId];
    if (sub == null) return;
    sub.eoseWaiting.remove(url);
    _startStragglerGrace(sub);
    _checkEose(sub);
  }

  void _checkEose(_Sub sub) {
    if (sub.eoseWaiting.isEmpty && sub.pending <= 0 && !sub.eose.isCompleted) {
      sub.eose.complete();
      sub.eoseTimer?.cancel();
      sub.stragglerTimer?.cancel();
    }
  }

  void _startStragglerGrace(_Sub sub) {
    final grace = sub.straggler;
    if (grace == null || sub.stragglerTimer != null || sub.eose.isCompleted) {
      return;
    }
    if (sub.eoseWaiting.isEmpty) return; // _checkEose decides
    sub.stragglerTimer = Timer(grace, () {
      if (!sub.eose.isCompleted) sub.eose.complete();
      sub.eoseTimer?.cancel();
    });
  }

  void _onClosed(String url, String subId, String message) {
    final sub = _subs[subId];
    if (sub == null) return;
    if (message.startsWith('auth-required') && authSigner != null) {
      sub.closedByAuth.add(url);
      final relay = _entries[url]?.relay;
      if (relay != null) _authenticate(relay);
      return;
    }
    sub.eoseWaiting.remove(url);
    _startStragglerGrace(sub);
    _checkEose(sub);
  }

  void _onRelayState(String url, RelayConnectionState state) {
    if (state == RelayConnectionState.failed ||
        state == RelayConnectionState.disconnected) {
      for (final sub in _subs.values) {
        if (sub.eoseWaiting.remove(url)) _checkEose(sub);
      }
    }
    _emitStatus();
  }

  void _emitStatus() {
    if (!_statusController.isClosed && _statusController.hasListener) {
      _statusController.add(statuses);
    }
  }

  // ── NIP-42 ──────────────────────────────────────────────────────────

  void _onAuthChallenge(String url) {
    if (authSigner == null) return;
    final wanted = _subs.values.any(
      (s) =>
          s.relays.contains(url) &&
          (s.authRequired || s.closedByAuth.contains(url)),
    );
    final relay = _entries[url]?.relay;
    if (wanted && relay != null) _authenticate(relay);
  }

  Future<bool> _authenticate(Relay relay) =>
      _authInFlight[relay.url] ??= _doAuthenticate(relay).whenComplete(() {
        _authInFlight.remove(relay.url);
      });

  Future<bool> _doAuthenticate(Relay relay) async {
    final signer = authSigner;
    if (signer == null) return false;
    if (relay.authenticated) return true;
    var waited = 0;
    while (relay.authChallenge == null && waited < 3000) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      waited += 100;
    }
    final challenge = relay.authChallenge;
    if (challenge == null) return false;
    try {
      final event = await signer(relay.url, challenge);
      final result = await relay.sendAuth(event);
      if (!result.accepted) return false;
      relay.authenticated = true;
      for (final sub in _subs.values) {
        if (sub.relays.contains(relay.url) &&
            (sub.authRequired || sub.closedByAuth.contains(relay.url))) {
          relay.resubscribe(sub.id);
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── publishing ──────────────────────────────────────────────────────

  /// Publishes to the write relays (plus [extraRelays], e.g. a recipient's
  /// inbox relays; with [onlyExtra] the configured relays are skipped) and
  /// reports each relay's own answer. Returns as soon as
  /// everyone answered, or shortly after the first acceptance.
  Future<PublishReport> publish(
    NostrEvent event, {
    Iterable<String> extraRelays = const [],
    bool onlyExtra = false,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final targets = <String>{if (!onlyExtra) ...writeRelays};
    final retained = <String>[];
    for (final raw in extraRelays) {
      final url = normalizeRelayUrl(raw);
      if (url == null || !isSafeRemoteRelayUrl(url) && !_isConfigured(url)) {
        continue;
      }
      if (!targets.contains(url)) {
        _retain(url);
        retained.add(url);
      }
      targets.add(url);
    }

    final accepted = <String, bool>{};
    final messages = <String, String>{};
    final allDone = Completer<void>();
    final firstAccepted = Completer<void>();
    var pending = targets.length;
    if (pending == 0) allDone.complete();

    for (final url in targets) {
      final entry = _entries[url];
      if (entry == null) {
        accepted[url] = false;
        messages[url] = 'relay unavailable';
        if (--pending == 0) allDone.complete();
        continue;
      }
      () async {
        var result = await entry.relay.publish(event);
        if (!result.accepted &&
            result.message.startsWith('auth-required') &&
            authSigner != null &&
            await _authenticate(entry.relay)) {
          result = await entry.relay.publish(event);
        }
        accepted[url] = result.accepted;
        messages[url] = result.message;
        if (result.accepted && !firstAccepted.isCompleted) {
          firstAccepted.complete();
        }
        if (--pending == 0 && !allDone.isCompleted) allDone.complete();
      }();
    }

    final grace = firstAccepted.future.then(
      (_) => Future<void>.delayed(const Duration(milliseconds: 1500)),
    );
    await Future.any([allDone.future, grace])
        .timeout(timeout, onTimeout: () {});

    for (final url in targets) {
      accepted.putIfAbsent(url, () => false);
      messages.putIfAbsent(url, () => 'no answer');
    }
    for (final url in retained) {
      _release(url);
    }
    return PublishReport(
      event.id,
      Map.of(accepted),
      relayMessages: Map.of(messages),
    );
  }

  // ── teardown ────────────────────────────────────────────────────────

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _flushTimer?.cancel();
    for (final sub in _subs.values.toList()) {
      sub.eoseTimer?.cancel();
      if (!sub.eose.isCompleted) sub.eose.complete();
      if (!sub.controller.isClosed) unawaited(sub.controller.close());
    }
    _subs.clear();
    for (final entry in _entries.values) {
      entry.idleTimer?.cancel();
      await entry.relay.dispose();
    }
    _entries.clear();
    await _statusController.close();
  }
}

/// Isolate entry point: fingerprints of the events whose id and signature are
/// valid. The fingerprint distinguishes a tampered copy with the same id.
List<String> _verifyAll(List<Map<String, dynamic>> jsons) {
  final ok = <String>[];
  for (final json in jsons) {
    try {
      final event = NostrEvent.fromJson(json);
      if (verifyEventSignature(event)) ok.add(RelayPool._fingerprint(event));
    } catch (_) {}
  }
  return ok;
}
