import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'event.dart';
import 'filter.dart';

enum RelayConnectionState { disconnected, connecting, connected, failed }

/// Canonical form of a relay URL (lowercase scheme/host, no trailing slash).
/// Returns null when [raw] is not a usable ws:// or wss:// URL.
String? normalizeRelayUrl(String raw) {
  var s = raw.trim();
  if (s.isEmpty) return null;
  if (!s.contains('://')) s = 'wss://$s';
  final uri = Uri.tryParse(s);
  if (uri == null || uri.host.isEmpty) return null;
  final scheme = uri.scheme.toLowerCase();
  if (scheme != 'wss' && scheme != 'ws') return null;
  final path = uri.path == '/' ? '' : uri.path.replaceAll(RegExp(r'/+$'), '');
  final port = uri.hasPort && uri.port != 0 ? ':${uri.port}' : '';
  return '$scheme://${uri.host.toLowerCase()}$port$path';
}

/// True for relay URLs learned from other people's events (NIP-65 hints):
/// only encrypted transport to public hosts is ever contacted automatically,
/// so a malicious relay list cannot make the app probe the local network.
bool isSafeRemoteRelayUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.scheme != 'wss') return false;
  return isPublicHost(uri.host);
}

/// A relay address worth connecting to: encrypted (`wss://`), or — for a
/// relay on the user's own network — plain `ws://` to a host that is not on
/// the public internet (`localhost`, `192.168.x.x`, `relay.local`). A
/// `ws://` address on the open internet would send everything in the clear.
bool isAcceptableRelayUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return false;
  if (uri.scheme == 'wss') return true;
  return uri.scheme == 'ws' && !isPublicHost(uri.host);
}

/// Rejects loopback, link-local and private-range hosts.
bool isPublicHost(String host) {
  final h = host.toLowerCase();
  if (h.isEmpty || h == 'localhost' || h.endsWith('.local')) return false;
  if (h.endsWith('.internal') || h.endsWith('.localhost')) return false;
  final v4 = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$')
      .firstMatch(h);
  if (v4 != null) {
    final a = int.parse(v4.group(1)!);
    final b = int.parse(v4.group(2)!);
    if (a == 10 || a == 127 || a == 0) return false;
    if (a == 169 && b == 254) return false;
    if (a == 172 && b >= 16 && b <= 31) return false;
    if (a == 192 && b == 168) return false;
    if (a == 100 && b >= 64 && b <= 127) return false; // CGNAT
    return true;
  }
  if (h.contains(':')) {
    // IPv6 literal: only allow global unicast (2000::/3).
    return h.startsWith('2') || h.startsWith('3');
  }
  return h.contains('.');
}

/// Outcome of a single relay's answer to a published event.
class RelayPublishResult {
  final bool accepted;
  final String message;
  const RelayPublishResult(this.accepted, this.message);
}

/// A single relay WebSocket connection with automatic reconnect and
/// exponential backoff. Reconnection only happens while something needs the
/// connection (an open subscription), so idle relays cost no battery.
class Relay {
  final String url;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  RelayConnectionState _state = RelayConnectionState.disconnected;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  Future<void>? _connecting;
  bool _disposed = false;
  String? _authChallenge;

  /// True once a NIP-42 AUTH was accepted on the current connection.
  bool authenticated = false;

  /// A relay message longer than this (in characters) is dropped unread: the
  /// biggest honest ones are follow lists of a few hundred KB.
  static const maxMessageChars = 6 * 1024 * 1024;

  final Map<String, List<NostrFilter>> _activeSubscriptions = {};
  final Map<String, Completer<RelayPublishResult>> _pendingOk = {};

  /// When the relay last said anything (or the socket opened).
  DateTime _lastHeard = DateTime.fromMillisecondsSinceEpoch(0);

  /// The liveness question in flight, if any (see [checkAlive]).
  String? _probeId;
  Completer<void>? _probe;
  static int _probes = 0;

  void Function(RelayConnectionState state)? onStateChanged;
  void Function(String subscriptionId, NostrEvent event)? onEvent;
  void Function(String subscriptionId)? onEose;
  void Function(String subscriptionId, String message)? onClosed;
  void Function(String challenge)? onAuthChallenge;
  void Function(String message)? onNotice;

  Relay(this.url);

  RelayConnectionState get state => _state;
  bool get isConnected => _state == RelayConnectionState.connected;
  String? get authChallenge => _authChallenge;
  bool get hasSubscriptions => _activeSubscriptions.isNotEmpty;

  /// Opens the socket. Safe to call repeatedly: concurrent callers share the
  /// same attempt.
  Future<void> connect() {
    if (_disposed || isConnected) return Future.value();
    return _connecting ??= _doConnect().whenComplete(() => _connecting = null);
  }

  Future<void> _doConnect() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _setState(RelayConnectionState.connecting);
    try {
      final channel = IOWebSocketChannel.connect(
        Uri.parse(url),
        connectTimeout: const Duration(seconds: 8),
        pingInterval: const Duration(seconds: 25),
      );
      await channel.ready;
      if (_disposed) {
        await channel.sink.close();
        return;
      }
      _channel = channel;
      _authChallenge = null;
      authenticated = false;
      _reconnectAttempts = 0;
      _lastHeard = DateTime.now();
      _subscription = channel.stream.listen(
        _handleMessage,
        onError: (_) => _handleDisconnect(),
        onDone: _handleDisconnect,
        cancelOnError: true,
      );
      _setState(RelayConnectionState.connected);
      // Restore subscriptions after a (re)connect.
      for (final entry in _activeSubscriptions.entries) {
        _send(['REQ', entry.key, ...entry.value.map((f) => f.toJson())]);
      }
    } catch (_) {
      _channel = null;
      _setState(RelayConnectionState.failed);
      _scheduleReconnect();
    }
  }

  /// Resolves true once the relay is connected, false on failure/timeout.
  Future<bool> waitUntilConnected({
    Duration timeout = const Duration(seconds: 6),
  }) async {
    if (isConnected) return true;
    try {
      await connect().timeout(timeout);
    } catch (_) {}
    return isConnected;
  }

  void subscribe(String subscriptionId, List<NostrFilter> filters) {
    _activeSubscriptions[subscriptionId] = filters;
    if (isConnected) {
      _send(['REQ', subscriptionId, ...filters.map((f) => f.toJson())]);
    } else {
      connect();
    }
  }

  /// Re-sends the REQ of an already registered subscription (after AUTH).
  void resubscribe(String subscriptionId) {
    final filters = _activeSubscriptions[subscriptionId];
    if (filters != null && isConnected) {
      _send(['REQ', subscriptionId, ...filters.map((f) => f.toJson())]);
    }
  }

  void unsubscribe(String subscriptionId) {
    if (_activeSubscriptions.remove(subscriptionId) != null && isConnected) {
      _send(['CLOSE', subscriptionId]);
    }
  }

  /// Sends [event] and resolves with the relay's OK answer. Never throws:
  /// connection problems and timeouts become a rejected result.
  Future<RelayPublishResult> publish(
    NostrEvent event, {
    Duration timeout = const Duration(seconds: 8),
  }) async {
    if (!await waitUntilConnected(timeout: const Duration(seconds: 6))) {
      return const RelayPublishResult(false, 'not connected');
    }
    final completer = Completer<RelayPublishResult>();
    _pendingOk[event.id] = completer;
    _send(['EVENT', event.toJson()]);
    try {
      return await completer.future.timeout(
        timeout,
        onTimeout: () => const RelayPublishResult(false, 'timeout'),
      );
    } finally {
      _pendingOk.remove(event.id);
    }
  }

  /// NIP-42: answers an AUTH challenge with a signed kind 22242 event.
  Future<RelayPublishResult> sendAuth(NostrEvent authEvent) async {
    if (!isConnected) return const RelayPublishResult(false, 'not connected');
    final completer = Completer<RelayPublishResult>();
    _pendingOk[authEvent.id] = completer;
    _send(['AUTH', authEvent.toJson()]);
    try {
      return await completer.future.timeout(
        const Duration(seconds: 8),
        onTimeout: () => const RelayPublishResult(false, 'timeout'),
      );
    } finally {
      _pendingOk.remove(authEvent.id);
    }
  }

  void _handleMessage(dynamic raw) {
    _lastHeard = DateTime.now();
    try {
      if (raw is! String || raw.length > maxMessageChars) return;
      final msg = jsonDecode(raw) as List;
      if (msg.length > 1 && msg[1] == _probeId) return _answerProbe(msg[0]);
      switch (msg[0]) {
        case 'EVENT':
          final event = NostrEvent.fromJson(msg[2] as Map<String, dynamic>);
          onEvent?.call(msg[1] as String, event);
        case 'EOSE':
          onEose?.call(msg[1] as String);
        case 'OK':
          final completer = _pendingOk[msg[1] as String];
          if (completer != null && !completer.isCompleted) {
            completer.complete(
              RelayPublishResult(
                msg[2] as bool,
                msg.length > 3 ? '${msg[3]}' : '',
              ),
            );
          }
        case 'CLOSED':
          onClosed?.call(msg[1] as String, msg.length > 2 ? '${msg[2]}' : '');
        case 'AUTH':
          _authChallenge = msg[1] as String;
          onAuthChallenge?.call(_authChallenge!);
        case 'NOTICE':
          onNotice?.call(msg.length > 1 ? '${msg[1]}' : '');
      }
    } catch (_) {
      // Malformed relay message: ignore.
    }
  }

  void _send(List<dynamic> payload) {
    try {
      _channel?.sink.add(jsonEncode(payload));
    } catch (_) {
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    if (_disposed) return;
    _dropSocket();
    _scheduleReconnect();
  }

  void _dropSocket() {
    _subscription?.cancel();
    _subscription = null;
    final channel = _channel;
    _channel = null;
    try {
      channel?.sink.close();
    } catch (_) {}
    _probeId = null;
    final probe = _probe;
    _probe = null;
    if (probe != null && !probe.isCompleted) probe.complete();
    // Fail every publish still waiting for an OK.
    for (final c in _pendingOk.values) {
      if (!c.isCompleted) {
        c.complete(const RelayPublishResult(false, 'disconnected'));
      }
    }
    _setState(RelayConnectionState.disconnected);
  }

  /// Makes sure the connection still works, before something important is
  /// asked of it (a refresh, the app coming back to the foreground).
  ///
  /// After the phone has slept, or the network changed, a socket often dies
  /// without either side noticing: the app keeps sending requests into it
  /// and the WebSocket ping only finds out tens of seconds later. A relay
  /// that has been [quiet] for a while is therefore asked a question with a
  /// known, instant answer (a `REQ` for an id that does not exist, which
  /// any relay ends with `EOSE` or `CLOSED`). No answer within [timeout]:
  /// the socket is replaced at once, and the open subscriptions are sent
  /// again on the new one.
  Future<void> checkAlive({
    Duration quiet = const Duration(seconds: 15),
    Duration timeout = const Duration(seconds: 3),
  }) async {
    if (_disposed) return;
    if (!isConnected) {
      // Down, maybe waiting out a long back-off: try now.
      if (_activeSubscriptions.isNotEmpty || _connecting != null) {
        await connect();
      }
      return;
    }
    if (DateTime.now().difference(_lastHeard) < quiet) return;
    final probe = _probe ??= _sendProbe();
    var answered = true;
    await probe.future.timeout(timeout, onTimeout: () => answered = false);
    if (answered || _disposed || !identical(_probe, probe)) return;
    _dropSocket();
    _reconnectAttempts = 0;
    await connect();
  }

  Completer<void> _sendProbe() {
    final id = 'alive${_probes++}';
    _probeId = id;
    _send([
      'REQ',
      id,
      {
        'ids': ['0' * 64],
        'limit': 1,
      },
    ]);
    return Completer<void>();
  }

  void _answerProbe(Object? type) {
    final id = _probeId;
    if (type == 'EOSE' && id != null) _send(['CLOSE', id]);
    if (type != 'EOSE' && type != 'CLOSED') return; // a stray EVENT
    _probeId = null;
    final probe = _probe;
    _probe = null;
    if (probe != null && !probe.isCompleted) probe.complete();
  }

  void _scheduleReconnect() {
    if (_disposed || _reconnectTimer != null) return;
    if (_activeSubscriptions.isEmpty) return; // nothing needs the socket
    final delay = Duration(seconds: 1 << _reconnectAttempts.clamp(0, 6));
    _reconnectAttempts++;
    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;
      connect();
    });
  }

  void _setState(RelayConnectionState s) {
    if (_state == s) return;
    _state = s;
    onStateChanged?.call(s);
  }

  /// Drops the socket but keeps the relay reusable.
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _subscription?.cancel();
    _subscription = null;
    final channel = _channel;
    _channel = null;
    _setState(RelayConnectionState.disconnected);
    try {
      await channel?.sink.close();
    } catch (_) {}
  }

  Future<void> dispose() async {
    _disposed = true;
    _reconnectTimer?.cancel();
    _activeSubscriptions.clear();
    for (final c in _pendingOk.values) {
      if (!c.isCompleted) {
        c.complete(const RelayPublishResult(false, 'closed'));
      }
    }
    await _subscription?.cancel();
    try {
      await _channel?.sink.close();
    } catch (_) {}
  }
}
