import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/relay_pool.dart';
import '../private/private_posts.dart';
import '../social/follow_controller.dart';
import '../social/moderation_controller.dart';

/// Stories published by one creator, oldest first (viewing order).
class StoryGroup {
  final String author;
  final List<MediaPost> stories;
  const StoryGroup({required this.author, required this.stories});

  int get latestTimestamp => stories.isEmpty ? 0 : stories.last.createdAt;

  /// Has stories meant for close friends only (green ring).
  bool get hasPrivate => stories.any((s) => s.isPrivate);
}

class StoriesState {
  final List<StoryGroup> groups;
  final bool isLoading;
  const StoriesState({this.groups = const [], this.isLoading = true});
}

/// Loads story-labeled media events (NIP-40 expiring kind 20/22) and groups
/// them by creator. Expired stories never surface here.
class StoriesController extends Notifier<StoriesState> {
  final Map<String, MediaPost> _byId = {};
  Timer? _flushTimer;
  Timer? _expiryTimer;
  Future<void>? _running;

  static const storyWindowSeconds = 86400;

  @override
  StoriesState build() {
    ref.onDispose(() {
      _flushTimer?.cancel();
      _expiryTimer?.cancel();
    });
    ref.listen(followListProvider, (prev, next) {
      if (prev != null && prev.length != next.length) _load();
    });
    ref.listen(privatePostsProvider.select((s) => s.posts), (_, posts) {
      _privateStories = [
        for (final p in posts)
          if (p.isStory) p,
      ];
      _regroup();
    });
    _privateStories = [
      for (final p in ref.read(privatePostsProvider).posts)
        if (p.isStory) p,
    ];
    ref.listen(blockProvider, (_, _) => _regroup());
    ref.listen(muteProvider, (_, _) => _regroup());
    // Stories vanish by themselves once their 24 hours are over.
    _expiryTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _regroup(),
    );
    Future.microtask(_load);
    return const StoriesState();
  }

  /// People whose stories belong in the rail: whoever you follow, and you.
  /// Guests (who follow nobody) see everyone's.
  Set<String>? _allowed;

  /// Close-friends stories (they arrived in gift wraps, not from a relay).
  List<MediaPost> _privateStories = const [];

  Future<Set<String>?> _followedAuthors() async {
    final me = ref.read(authProvider).publicKey;
    if (me == null) return null;
    try {
      await ref
          .read(followListProvider.notifier)
          .ready
          .timeout(const Duration(seconds: 10));
    } on TimeoutException {
      // Use whatever has arrived.
    }
    return {...ref.read(followListProvider), me};
  }

  Future<void> _load() {
    return _running ??= () async {
      try {
        final pool = ref.read(relayPoolProvider);
        final since =
            DateTime.now().millisecondsSinceEpoch ~/ 1000 - storyWindowSeconds;
        final authors = await _followedAuthors();
        _allowed = authors;

        List<NostrFilter> filtersFor(Iterable<String>? subset) {
          if (subset == null) {
            return [
              NostrFilter(
                kinds: const [NostrKinds.picture, NostrKinds.shortVideo],
                tagFilters: const {
                  '#L': ['mialuna.story'],
                },
                since: since,
                limit: 200,
              ),
            ];
          }
          final list = subset.toList()..sort();
          return [
            for (var i = 0; i < list.length; i += 80)
              NostrFilter(
                kinds: const [NostrKinds.picture, NostrKinds.shortVideo],
                authors: list.sublist(i, math.min(i + 80, list.length)),
                tagFilters: const {
                  '#L': ['mialuna.story'],
                },
                since: since,
                limit: 100,
              ),
          ];
        }

        Future<void> collect(PoolSubscription sub) async {
          final listener = sub.events.listen(_ingest);
          await sub.eose;
          await Future<void>.delayed(const Duration(milliseconds: 300));
          await listener.cancel();
          sub.close();
        }

        final jobs = <Future<void>>[
          collect(
            pool.subscribe(
              filtersFor(authors),
              eoseTimeout: const Duration(seconds: 10),
            ),
          ),
        ];
        if (authors != null && authors.length > 1) {
          // Stories live on the relays their authors publish to.
          jobs.add(() async {
            final outbox = ref.read(outboxProvider);
            try {
              await outbox.ensure(authors).timeout(const Duration(seconds: 8));
            } on TimeoutException {
              // Plan with what is known.
            }
            final mine = pool.readRelays.toSet();
            await Future.wait([
              for (final e in outbox.plan(authors, maxRelays: 6).entries)
                if (!mine.contains(e.key))
                  collect(
                    pool.subscribe(
                      filtersFor(e.value),
                      extraRelays: [e.key],
                      onlyExtra: true,
                      eoseTimeout: const Duration(seconds: 10),
                    ),
                  ),
            ]);
          }());
        }
        await Future.wait(jobs);
        _regroup();
      } finally {
        _running = null;
      }
    }();
  }

  void _ingest(NostrEvent e) {
    if (_byId.containsKey(e.id)) return;
    final post = MediaPost.tryParse(e);
    if (post == null || !post.isStory || post.isExpired()) return;
    _byId[e.id] = post;
    _flushTimer ??= Timer(const Duration(milliseconds: 300), () {
      _flushTimer = null;
      _regroup();
    });
  }

  void _regroup() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final blocked = ref.read(blockProvider);
    final muted = ref.read(muteProvider);
    final byAuthor = <String, List<MediaPost>>{};
    _byId.removeWhere((_, p) => p.isExpired(now));
    final allowed = _allowed;
    for (final post in _privateStories) {
      if (post.isExpired(now)) continue;
      if (blocked.contains(post.author) || muted.contains(post.author)) {
        continue;
      }
      byAuthor.putIfAbsent(post.author, () => []).add(post);
    }
    for (final post in _byId.values) {
      if (blocked.contains(post.author) || muted.contains(post.author)) {
        continue;
      }
      if (allowed != null && !allowed.contains(post.author)) continue;
      byAuthor.putIfAbsent(post.author, () => []).add(post);
    }
    final groups = [
      for (final entry in byAuthor.entries)
        StoryGroup(
          author: entry.key,
          stories: entry.value
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
        ),
    ]..sort((a, b) => b.latestTimestamp.compareTo(a.latestTimestamp));
    state = StoriesState(groups: groups, isLoading: false);
  }

  /// Fetches newer stories and merges them in.
  Future<void> refresh() => _load();
}

final storiesProvider = NotifierProvider<StoriesController, StoriesState>(
  StoriesController.new,
);

/// Stories already watched, kept on this device only (no viewer tracking
/// ever leaves it).
class SeenStories extends Notifier<Set<String>> {
  static const _key = 'mialuna_seen_stories';

  @override
  Set<String> build() {
    _load();
    return {};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = {...state, ...?prefs.getStringList(_key)};
  }

  Future<void> markSeen(String storyId) async {
    if (state.contains(storyId)) return;
    var next = {...state, storyId};
    if (next.length > 600) next = next.skip(next.length - 600).toSet();
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, next.toList());
  }
}

final seenStoriesProvider = NotifierProvider<SeenStories, Set<String>>(
  SeenStories.new,
);
