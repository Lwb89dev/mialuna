import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/relay_pool.dart';
import '../social/deleted_posts.dart';
import '../social/moderation_controller.dart';
import '../trust/web_of_trust_controller.dart';

class ReelsState {
  final List<MediaPost> reels;
  final bool isLoading;
  const ReelsState({this.reels = const [], this.isLoading = true});
}

/// Loads kind 22 (and 34236) short videos for the vertical Reels viewer, from
/// the same people Discover shows: you, the people you follow, and your web of
/// trust. Newest first. Strangers' videos never enter, so the open firehose of
/// the relays stays out of the viewer.
class ReelsController extends Notifier<ReelsState> {
  final Map<String, MediaPost> _byId = {};
  Timer? _flushTimer;
  Future<void>? _running;
  final List<PoolSubscription> _open = [];
  bool _disposed = false; // a load may end after the provider is gone

  /// The people changed while a load was asking for the old ones.
  bool _again = false;
  static const _chunk = 80;
  static const _perChunk = 30;
  static const _timeout = Duration(seconds: 12);
  static const _maxReels = 300;

  /// A post dated further ahead than this is a clock gone wrong, or someone
  /// trying to stay pinned at the top: it is left out.
  static const _maxClockSkew = Duration(minutes: 15);

  @override
  ReelsState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _flushTimer?.cancel();
      for (final s in _open) {
        s.close();
      }
      _open.clear();
    });
    ref.listen(muteProvider, (_, _) => _commit());
    ref.listen(blockProvider, (_, _) => _commit());
    ref.listen(brokenMediaProvider, (_, _) => _commit());
    ref.listen(deletedPostsProvider, (_, _) => _commit());
    ref.listen(mutedHashtagsProvider, (_, _) => _commit());
    // Following someone, or a network that just finished building, changes
    // who belongs here.
    ref.listen(wotAuthorsProvider, (prev, next) {
      if (prev != null &&
          prev.length == next.length &&
          prev.containsAll(next)) {
        return;
      }
      _byId.removeWhere((_, p) => !next.contains(p.author));
      _commit();
      if (next.isEmpty) return;
      if (_running != null) {
        _again = true; // asked once the running load ends
      } else {
        unawaited(_load());
      }
    });
    Future.microtask(_load);
    return const ReelsState();
  }

  Future<void> _load() {
    return _running ??= () async {
      try {
        // Wait (bounded) for the network, so the first answer already holds
        // the people it brings in.
        try {
          await ref
              .read(webOfTrustProvider.notifier)
              .ready
              .timeout(const Duration(seconds: 20));
        } on TimeoutException {
          // Ask for whoever is known so far.
        }
        if (_disposed) return;
        final authors = ref.read(wotAuthorsProvider);
        if (authors.isEmpty) {
          _commit();
          return;
        }
        final pool = ref.read(relayPoolProvider);
        List<NostrFilter> filtersFor(Iterable<String> subset) {
          final list = subset.toList()..sort();
          return [
            for (var i = 0; i < list.length; i += _chunk)
              NostrFilter(
                kinds: const [
                  NostrKinds.shortVideo,
                  NostrKinds.addressableShortVideo,
                ],
                authors: list.sublist(i, math.min(i + _chunk, list.length)),
                limit: _perChunk,
              ),
          ];
        }

        // The user's own relays answer straight away, while the relays each
        // author publishes to (NIP-65) are looked up and asked as well.
        final outbox = ref.read(outboxProvider);
        final theirs = () async {
          try {
            await outbox.ensure(authors).timeout(const Duration(seconds: 8));
          } on TimeoutException {
            // Plan with what is known.
          }
          if (_disposed) return;
          final mine = pool.readRelays.toSet();
          final plan = outbox.plan(authors, maxRelays: 6);
          await Future.wait([
            for (final entry in plan.entries)
              if (!mine.contains(entry.key))
                _collect(
                  pool.subscribe(
                    filtersFor(entry.value),
                    extraRelays: [entry.key],
                    onlyExtra: true,
                    eoseTimeout: _timeout,
                  ),
                ),
          ]);
        }();
        await Future.wait([
          _collect(pool.subscribe(filtersFor(authors), eoseTimeout: _timeout)),
          theirs,
        ]);
        _commit();
      } catch (_) {
        _commit(); // show what arrived
      } finally {
        _running = null;
        if (_again && !_disposed) {
          _again = false;
          unawaited(_load());
        }
      }
    }();
  }

  Future<void> _collect(PoolSubscription sub) async {
    if (_disposed) {
      sub.close();
      return;
    }
    _open.add(sub);
    final listener = sub.events.listen(_ingest);
    await sub.eose;
    // Relays often deliver their last events right after EOSE.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await listener.cancel();
    sub.close();
    _open.remove(sub);
  }

  void _ingest(NostrEvent event) {
    if (_byId.containsKey(event.id)) return;
    if (_disposed) return;
    if (!ref.read(wotAuthorsProvider).contains(event.pubkey)) return;
    final latest =
        DateTime.now().add(_maxClockSkew).millisecondsSinceEpoch ~/ 1000;
    if (event.createdAt > latest) return;
    final post = MediaPost.tryParse(event);
    if (post == null || post.isStory || post.isExpired()) return;
    if (post.media.isEmpty || !post.media.first.isVideo) return;
    _byId[event.id] = post;
    _flushTimer ??= Timer(const Duration(milliseconds: 300), () {
      _flushTimer = null;
      _commit();
    });
  }

  void _commit() {
    if (_disposed) return;
    final muted = ref.read(muteProvider);
    final blocked = ref.read(blockProvider);
    final broken = ref.read(brokenMediaProvider);
    final deleted = ref.read(deletedPostsProvider);
    final hashtags = ref.read(mutedHashtagsProvider);
    final reels = [
      for (final p in _byId.values)
        if (!muted.contains(p.author) &&
            !blocked.contains(p.author) &&
            !broken.contains(p.id) &&
            !deleted.contains(p.id) &&
            !p.hashtags.any(hashtags.contains))
          p,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    // The oldest go once there are many: a session of refreshes must not
    // keep every reel ever seen in memory.
    if (reels.length > _maxReels) {
      for (final dropped in reels.sublist(_maxReels)) {
        _byId.remove(dropped.id);
      }
      reels.removeRange(_maxReels, reels.length);
    }
    state = ReelsState(reels: reels, isLoading: false);
  }

  /// Fetches newer reels and merges them in.
  Future<void> refresh() => _load();
}

final reelsProvider = NotifierProvider<ReelsController, ReelsState>(
  ReelsController.new,
);
