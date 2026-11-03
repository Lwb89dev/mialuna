import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/relay_pool.dart';
import '../../core/notify/system_notifier.dart';
import '../private/private_posts.dart';
import '../settings/settings_controller.dart';
import '../social/deleted_posts.dart';
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
/// them by creator. Stories that are over (their 24 hours, or an earlier
/// NIP-40 expiration) never surface here, and vanish by themselves while the
/// app stays open.
class StoriesController extends Notifier<StoriesState> {
  final Map<String, MediaPost> _byId = {};
  Timer? _flushTimer;
  Timer? _expiryTimer;
  String _shown = '';

  /// Bumped on every rebuild (another account) and on dispose. Loads finish
  /// on their own schedule: one that ends after either must not touch the
  /// state, nor `ref`.
  int _generation = 0;

  Completer<void>? _loading;

  /// Somebody asked for a (new) load: set by every request, cleared when a
  /// load starts, so a request that arrives mid-load makes another one.
  bool _reloadWanted = false;

  static const storyWindowSeconds = MediaPost.storyWindowSeconds;

  @override
  StoriesState build() {
    final generation = ++_generation;
    ref.onDispose(() {
      _generation++;
      _flushTimer?.cancel();
      _flushTimer = null;
      _expiryTimer?.cancel();
    });
    // Another account starts from nothing: nobody else's stories, follows or
    // half-finished load carry over.
    ref.watch(authProvider.select((a) => a.publicKey));
    _byId.clear();
    _allowed = null;
    _shown = '';
    _loading = null;
    _reloadWanted = false;
    // The people you follow changed — not merely how many: swapping one
    // account for another leaves the count as it was.
    ref.listen(followListProvider, (prev, next) {
      if (prev != null && !_sameSet(prev, next)) _load();
    });
    // New relays may carry the stories of people already followed.
    ref.listen(settingsProvider.select((s) => s.relays), (prev, next) {
      if (prev != null && !listEquals(prev, next)) _load();
    });
    ref.listen(privatePostsProvider.select((s) => s.posts), (_, posts) {
      _privateStories = _storiesIn(posts);
      _regroup();
    });
    _privateStories = _storiesIn(ref.read(privatePostsProvider).posts);
    ref.listen(blockProvider, (_, _) => _regroup());
    ref.listen(deletedPostsProvider, (_, _) => _regroup());
    ref.listen(muteProvider, (_, _) => _regroup());
    // Timers sleep with the app: when it wakes up, what expired goes at once.
    ref.listen(appForegroundProvider, (_, front) {
      if (front) dropExpired();
    });
    // Stories vanish by themselves once their 24 hours are over.
    _expiryTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => dropExpired(),
    );
    Future.microtask(() {
      if (generation == _generation) _load();
    });
    return const StoriesState();
  }

  static bool _sameSet(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);

  static List<MediaPost> _storiesIn(List<MediaPost> posts) => [
    for (final p in posts)
      if (p.isStory) p,
  ];

  int _now() => ref.read(unixClockProvider)();

  /// People whose stories belong in the rail: whoever you follow, and you.
  /// Guests (who follow nobody) see everyone's.
  Set<String>? _allowed;

  /// Close-friends stories (they arrived in gift wraps, not from a relay).
  List<MediaPost> _privateStories = const [];

  Future<Set<String>?> _followedAuthors(int generation) async {
    final me = ref.read(authProvider).publicKey;
    if (me == null) return null;
    try {
      await ref
          .read(followListProvider.notifier)
          .usable
          .timeout(const Duration(seconds: 10));
    } on TimeoutException {
      // Use whatever has arrived.
    }
    if (generation != _generation) return null; // the wait outlived its account
    return {...ref.read(followListProvider), me};
  }

  /// Loads the stories now. A request that comes in while a load is running
  /// is not absorbed by it (it may have started from an older follow list):
  /// another load follows, and the future completes when the newest is done.
  Future<void> _load() {
    _reloadWanted = true;
    final running = _loading;
    if (running != null) return running.future;
    final done = _loading = Completer<void>();
    unawaited(_loadWhileWanted(done, _generation));
    return done.future;
  }

  Future<void> _loadWhileWanted(Completer<void> done, int generation) async {
    try {
      while (_reloadWanted && generation == _generation) {
        _reloadWanted = false;
        await _loadOnce(generation);
      }
    } catch (_) {
      // A relay that misbehaves leaves the rail as it was.
    } finally {
      if (identical(_loading, done)) _loading = null;
      done.complete();
    }
  }

  Future<void> _loadOnce(int generation) async {
    final pool = ref.read(relayPoolProvider);
    final since = _now() - storyWindowSeconds;
    final authors = await _followedAuthors(generation);
    if (generation != _generation) return;
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
      final listener = sub.events.listen((e) => _ingest(e, generation));
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
        if (generation != _generation) return;
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
    if (generation == _generation) _regroup();
  }

  /// A story you have just published shows up in the rail at once, without
  /// waiting for a relay to hand it back.
  void addPublished(NostrEvent e) {
    _ingest(e, _generation);
    _flushTimer?.cancel();
    _flushTimer = null;
    _regroup();
  }

  void _ingest(NostrEvent e, int generation) {
    if (generation != _generation || _byId.containsKey(e.id)) return;
    final post = MediaPost.tryParse(e);
    if (post == null || !post.isStory || post.isExpired(_now())) return;
    _byId[e.id] = post;
    _flushTimer ??= Timer(const Duration(milliseconds: 300), () {
      _flushTimer = null;
      _regroup();
    });
  }

  /// Takes out the stories whose time is up. Called every minute, and when
  /// the app returns to the foreground.
  void dropExpired() => _regroup();

  void _regroup() {
    final now = _now();
    final blocked = ref.read(blockProvider);
    final muted = ref.read(muteProvider);
    final deleted = ref.read(deletedPostsProvider);
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
      if (deleted.contains(post.id)) continue;
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
    // Every minute this runs; the rail is only redrawn when it changed.
    final shown = groups
        .map((g) => '${g.author}:${g.stories.map((s) => s.id).join(',')}')
        .join('|');
    if (shown == _shown && !state.isLoading) return;
    _shown = shown;
    state = StoriesState(groups: groups, isLoading: false);
  }

  /// Fetches newer stories and merges them in.
  Future<void> refresh() => _load();
}

final storiesProvider = NotifierProvider<StoriesController, StoriesState>(
  StoriesController.new,
);

/// Your own stories that are still live (public and close-friends), by id,
/// with the time each was published. A story view receipt is only believed
/// for one of these: anybody can name any id in a message to you.
final ownStoriesProvider = Provider<Map<String, int>>((ref) {
  final me = ref.watch(authProvider.select((a) => a.publicKey));
  if (me == null) return const {};
  final groups = ref.watch(storiesProvider.select((s) => s.groups));
  return {
    for (final g in groups)
      if (g.author == me)
        for (final s in g.stories) s.id: s.createdAt,
  };
});

/// Stories already watched, kept on this device, for the account that
/// watched them (guests have a list of their own). Whether the author hears
/// about it is a separate, opt-out matter (see `story_receipts.dart`).
class SeenStories extends Notifier<Set<String>> {
  static const _keyPrefix = 'mialuna_seen_stories_';

  /// The one list every account used to share. Adopted by the first account
  /// that signs in after the update, then removed.
  static const _legacyKey = 'mialuna_seen_stories';
  static const _maxKept = 600;

  int _generation = 0;
  String _key = '${_keyPrefix}guest';
  Future<void> _ready = Future.value();

  /// Where [pubkey]'s list is kept.
  static String keyFor(String? pubkey) => '$_keyPrefix${pubkey ?? 'guest'}';

  @override
  Set<String> build() {
    final pub = ref.watch(authProvider.select((a) => a.publicKey));
    final generation = ++_generation;
    ref.onDispose(() => _generation++);
    _key = keyFor(pub);
    _ready = _load(generation, pub);
    return {};
  }

  Future<void> _load(int generation, String? pub) async {
    final key = _key;
    final Set<String> saved;
    try {
      final prefs = await ref.read(sharedPreferencesLoader)();
      saved = {...?prefs.getStringList(key)};
      final legacy = pub == null ? null : prefs.getStringList(_legacyKey);
      if (legacy != null) {
        saved.addAll(legacy);
        await prefs.setStringList(key, _newest(saved));
        await prefs.remove(_legacyKey);
      }
    } catch (_) {
      return; // nothing readable: everything looks new, which is harmless
    }
    // Whoever signed in meanwhile has a list of their own: this one is not it.
    if (generation != _generation) return;
    // What was marked while this was being read stays marked.
    state = {...saved, ...state};
  }

  static List<String> _newest(Iterable<String> ids) {
    final all = ids.toList();
    return all.length > _maxKept ? all.sublist(all.length - _maxKept) : all;
  }

  Future<void> markSeen(String storyId) async {
    if (state.contains(storyId)) return;
    state = {
      ..._newest({...state, storyId}),
    };
    final key = _key;
    final load = ref.read(sharedPreferencesLoader);
    await _ready;
    // Read-modify-write on the list of the account that watched, even if
    // another has signed in since: it is theirs to keep.
    try {
      final prefs = await load();
      await prefs.setStringList(
        key,
        _newest({...?prefs.getStringList(key), storyId}),
      );
    } catch (_) {
      // Not saved: it will look new again next time, which is harmless.
    }
  }
}

final seenStoriesProvider = NotifierProvider<SeenStories, Set<String>>(
  SeenStories.new,
);
