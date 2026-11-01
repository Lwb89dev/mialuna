import 'dart:async';
import 'dart:math' as math;

import 'event.dart';
import 'filter.dart';
import 'nip65.dart';
import 'relay.dart';
import 'relay_pool.dart';

/// NIP-65 "outbox model": finds the relays each author publishes to, so
/// their posts can be read from where they actually live instead of hoping
/// the user's own relays happen to carry them.
class OutboxResolver {
  final RelayPool pool;
  final List<String> indexers;

  final Map<String, List<String>> _write = {};
  final Map<String, List<String>> _read = {};
  final Map<String, int> _createdAt = {};
  final Map<String, DateTime> _checkedAt = {};
  final Map<String, Future<void>> _inflight = {};

  static const refreshAfter = Duration(hours: 12);
  static const chunkSize = 80;

  OutboxResolver(this.pool, {this.indexers = const []});

  /// Relays [pubkey] writes to (cached; call [ensure] first).
  List<String> writeRelays(String pubkey, {int max = 3}) =>
      _safe(_write[pubkey], max);

  /// Relays [pubkey] reads from: where to deliver things addressed to them.
  List<String> readRelays(String pubkey, {int max = 3}) =>
      _safe(_read[pubkey], max);

  List<String> _safe(List<String>? urls, int max) => [
    for (final u in urls ?? const <String>[])
      if (isSafeRemoteRelayUrl(u)) u,
  ].take(max).toList();

  /// Loads the relay lists of [pubkeys] that are missing or stale.
  Future<void> ensure(Iterable<String> pubkeys) {
    final now = DateTime.now();
    final needed = <String>{
      for (final pk in pubkeys)
        if (pk.length == 64 &&
            (_checkedAt[pk] == null ||
                now.difference(_checkedAt[pk]!) > refreshAfter))
          pk,
    };
    if (needed.isEmpty) return Future.value();
    // A follow list can have hundreds of keys: ask in chunks, relays refuse
    // huge `authors` filters.
    final list = needed.toList()..sort();
    return Future.wait([
      for (var i = 0; i < list.length; i += chunkSize)
        _ensureChunk(
          list.sublist(i, math.min(i + chunkSize, list.length)).toSet(),
        ),
    ]).then((_) {});
  }

  Future<void> _ensureChunk(Set<String> needed) {
    final key = (needed.toList()..sort()).join(',');
    return _inflight[key] ??= _fetch(needed).whenComplete(() {
      _inflight.remove(key);
    });
  }

  Future<void> _fetch(Set<String> pubkeys) async {
    final sub = pool.subscribe(
      [
        NostrFilter(
          kinds: const [NostrKinds.relayList],
          authors: pubkeys.toList(),
          limit: pubkeys.length * 2,
        ),
      ],
      extraRelays: indexers,
      eoseTimeout: const Duration(seconds: 6),
    );
    final listener = sub.events.listen(ingest);
    await sub.eose;
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await listener.cancel();
    sub.close();
    final now = DateTime.now();
    for (final pk in pubkeys) {
      _checkedAt[pk] = now;
    }
  }

  /// Registers a kind 10002 event (also used when it arrives elsewhere).
  void ingest(NostrEvent event) {
    if (event.kind != NostrKinds.relayList) return;
    if ((_createdAt[event.pubkey] ?? -1) >= event.createdAt) return;
    _createdAt[event.pubkey] = event.createdAt;
    _write[event.pubkey] = writeRelaysOf(event);
    _read[event.pubkey] = readRelaysOf(event);
  }

  /// Greedy cover: for [authors], picks up to [maxRelays] relays so that each
  /// author is reachable through as many of their own relays as possible.
  /// Returns relay → authors served by it.
  Map<String, Set<String>> plan(Iterable<String> authors, {int maxRelays = 8}) {
    final remaining = {...authors};
    final byRelay = <String, Set<String>>{};
    for (final a in authors) {
      for (final r in writeRelays(a, max: 4)) {
        byRelay.putIfAbsent(r, () => {}).add(a);
      }
    }
    final result = <String, Set<String>>{};
    while (remaining.isNotEmpty &&
        byRelay.isNotEmpty &&
        result.length < maxRelays) {
      final best = byRelay.entries.reduce(
        (a, b) =>
            a.value.where(remaining.contains).length >=
                b.value.where(remaining.contains).length
            ? a
            : b,
      );
      final served = best.value.where(remaining.contains).toSet();
      if (served.isEmpty) break;
      result[best.key] = served;
      remaining.removeAll(served);
      byRelay.remove(best.key);
    }
    return result;
  }

  Map<String, dynamic> toJson() => {
    for (final e in _createdAt.entries)
      e.key: {
        'c': e.value,
        'w': _write[e.key] ?? const [],
        'r': _read[e.key] ?? const [],
      },
  };

  void load(Object? json) {
    if (json is! Map) return;
    json.forEach((k, v) {
      if (k is! String || v is! Map) return;
      _createdAt[k] = (v['c'] as num?)?.toInt() ?? 0;
      _write[k] = [for (final u in (v['w'] as List? ?? const [])) '$u'];
      _read[k] = [for (final u in (v['r'] as List? ?? const [])) '$u'];
      // Cached lists are shown immediately but refreshed on first use.
    });
  }
}
