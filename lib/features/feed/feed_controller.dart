import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/relay_pool.dart';
import '../../core/storage/local_cache.dart';
import '../../l10n/strings.dart';
import '../private/private_posts.dart';
import '../social/follow_controller.dart';
import '../social/moderation_controller.dart';

/// Which posts a feed shows.
enum FeedMode {
  /// Only people you follow (plus yourself) — the Home feed.
  following,

  /// Everything the relays have — the Discover feed.
  discover,
}

class FeedState {
  final List<MediaPost> posts;

  /// True until the first page arrived (or the first load gave up).
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasMore;

  /// Following feed only: the account follows nobody yet.
  final bool followsNobody;
  final String? error;

  const FeedState({
    this.posts = const [],
    this.isLoading = true,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.followsNobody = false,
    this.error,
  });

  FeedState copyWith({
    List<MediaPost>? posts,
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? hasMore,
    bool? followsNobody,
    String? error,
    bool clearError = false,
  }) => FeedState(
    posts: posts ?? this.posts,
    isLoading: isLoading ?? this.isLoading,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasMore: hasMore ?? this.hasMore,
    followsNobody: followsNobody ?? this.followsNobody,
    error: clearError ? null : (error ?? this.error),
  );
}

/// What one relay round brought back: how many events became posts, how many
/// events there were at all (stories and expired posts count here), and the
/// oldest of them. A page made only of stories still means "there is more".
typedef _Page = ({int added, int raw, int? oldest});
const _Page _noPage = (added: 0, raw: 0, oldest: null);

int? _older(int? a, int? b) => a == null
    ? b
    : b == null
    ? a
    : math.min(a, b);

/// Kind 20/21/22 media posts only; kind 1 never enters here. Stories
/// (NIP-40 expired or story-labeled) are excluded.
///
/// Every load is a bounded request (EOSE-terminated) whose answer is merged
/// into the list; refreshing keeps what is on screen and only adds what is
/// new, so pull-to-refresh can never leave the feed empty or stuck.
///
/// The following feed asks for the followed accounts in chunks (relays refuse
/// huge `authors` filters), on the user's own relays and — outbox model — on
/// the relays each followed account publishes to (NIP-65).
class FeedController extends FamilyNotifier<FeedState, FeedMode> {
  static const _pageSize = 30;
  static const _chunk = 80;
  static const _maxPosts = 400;
  static const _loadTimeout = Duration(seconds: 14);
  static const _spinnerLimit = Duration(seconds: 4);

  final Map<String, MediaPost> _byId = {};
  final List<PoolSubscription> _open = [];
  Timer? _flushTimer;
  Timer? _saveTimer;
  Future<void>? _running;
  bool _cacheRestored = false;
  bool _disposed = false;

  /// Where paging stands: the oldest event any relay handed back so far,
  /// whether or not it became a post. Paging from the oldest *post* instead
  /// stalls when a whole page is stories (`added == 0`).
  int? _cursor;
  static const _maxEmptyPages = 4;

  /// The first load is done; follow-list changes before that are part of it.
  bool _started = false;
  bool _followsChangedWhileLoading = false;
  Set<String> _authors = const {};

  FeedMode get _mode => arg;

  String get _cacheFile => _mode == FeedMode.following
      ? LocalCache.followingEventsFile
      : LocalCache.discoverEventsFile;

  @override
  FeedState build(FeedMode arg) {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      for (final s in _open) {
        s.close();
      }
      _open.clear();
      _flushTimer?.cancel();
      _saveTimer?.cancel();
    });
    // Filters changed by the user apply to what is already loaded.
    ref.listen(muteProvider, (_, _) => _refilter());
    ref.listen(blockProvider, (_, _) => _refilter());
    ref.listen(mutedHashtagsProvider, (_, _) => _refilter());
    ref.listen(brokenMediaProvider, (_, _) => _refilter());
    if (arg == FeedMode.following) {
      // Close-friends posts addressed to you belong in Home too.
      ref.listen(
        privatePostsProvider.select((s) => s.posts),
        (_, posts) => _mergePrivate(posts),
      );
      // Following someone (or unfollowing) changes what belongs here.
      ref.listen(followListProvider, (prev, next) {
        if (prev == null || prev.length == next.length) return;
        // The list saved on the device is used first; the relays' answer may
        // land while the first load is still running.
        if (!_started) {
          _followsChangedWhileLoading = true;
          return;
        }
        refresh();
      });
      ref.listen(authProvider.select((a) => a.publicKey), (prev, next) {
        if (prev != next) {
          _byId.clear();
          _cursor = null;
          _cacheRestored = false;
          _started = false;
          state = const FeedState();
          Future.microtask(_initialLoad);
        }
      });
    }
    Future.microtask(_initialLoad);
    return const FeedState();
  }

  bool _isShown(MediaPost post) => !_isHidden(post);

  bool _isHidden(MediaPost post) =>
      ref.read(muteProvider).contains(post.author) ||
      ref.read(blockProvider).contains(post.author) ||
      ref.read(brokenMediaProvider).contains(post.id) ||
      post.hashtags.any(ref.read(mutedHashtagsProvider).contains) ||
      (_mode == FeedMode.following &&
          !post.isPrivate && // sent to you on purpose, followed or not
          _authors.isNotEmpty &&
          !_authors.contains(post.author));

  /// The accounts whose posts belong in the following feed: the ones you
  /// follow, and you. Waits (bounded) for the follow list.
  Future<Set<String>> _followedAuthors() async {
    final me = ref.read(authProvider).publicKey;
    if (me == null) return const {};
    try {
      await ref
          .read(followListProvider.notifier)
          .usable
          .timeout(const Duration(seconds: 10));
    } on TimeoutException {
      // Use whatever has arrived.
    }
    if (_disposed) return const {}; // the wait outlived the provider
    return {...ref.read(followListProvider), me};
  }

  Future<void> _initialLoad() async {
    // What the last session saved is painted first, before anything is asked
    // of the network (not even the follow list).
    await _restoreCache();
    if (_disposed) return;
    if (_mode == FeedMode.following) {
      _authors = await _followedAuthors();
      if (_disposed) return;
    }
    _mergePrivate(ref.read(privatePostsProvider).posts);
    await _load();
    _started = true;
    if (_followsChangedWhileLoading && !_disposed) {
      _followsChangedWhileLoading = false;
      unawaited(refresh());
    }
  }

  Future<void> _restoreCache() async {
    if (_cacheRestored) return;
    _cacheRestored = true;
    final cache = ref.read(localCacheProvider);
    final List<NostrEvent> cached;
    if (_mode == FeedMode.following) {
      final me = ref.read(authProvider).publicKey;
      if (me == null) return;
      cached = await cache.loadOwnedEvents(me, file: _cacheFile);
    } else {
      cached = await cache.loadEvents(file: _cacheFile);
    }
    if (_disposed) return;
    for (final e in cached) {
      _accept(e, restored: true);
    }
    if (_byId.isNotEmpty) _commit(loading: false);
  }

  void _mergePrivate(List<MediaPost> posts) {
    if (_mode != FeedMode.following || _disposed) return;
    var changed = false;
    for (final p in posts) {
      if (p.isStory || p.isExpired()) continue;
      if (_byId[p.id] == null) changed = true;
      _byId[p.id] = p;
    }
    if (changed) _commit(loading: false);
  }

  /// Parses, filters and stores [event]; true when it is a new post.
  /// [restored] events come from this account's own saved feed, which was
  /// already filtered when it was saved.
  bool _accept(NostrEvent event, {bool restored = false}) {
    if (_byId.containsKey(event.id)) return false;
    if (!restored &&
        _mode == FeedMode.following &&
        !_authors.contains(event.pubkey)) {
      return false; // a relay answered with someone we do not follow
    }
    final post = MediaPost.tryParse(event);
    if (post == null || post.isStory || post.isExpired()) return false;
    _byId[post.id] = post;
    ref.read(eventStoreProvider).add(event);
    return true;
  }

  void _commit({bool? loading, bool? hasMore}) {
    if (_disposed) return;
    final posts = [
      for (final p in _byId.values)
        if (!_isHidden(p)) p,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (posts.length > _maxPosts) {
      for (final dropped in posts.sublist(_maxPosts)) {
        _byId.remove(dropped.id);
      }
      posts.removeRange(_maxPosts, posts.length);
    }
    state = state.copyWith(posts: posts, isLoading: loading, hasMore: hasMore);
    _scheduleSave();
  }

  void _refilter() {
    if (_byId.isEmpty) return;
    _commit();
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 3), persistCache);
  }

  /// Streams one subscription into the list (throttled) until EOSE.
  Future<_Page> _collect(PoolSubscription sub) async {
    _open.add(sub);
    var added = 0;
    var raw = 0;
    int? oldest;
    final listener = sub.events.listen((event) {
      raw++;
      oldest = _older(oldest, event.createdAt);
      if (_accept(event)) {
        added++;
        _flushTimer ??= Timer(const Duration(milliseconds: 250), () {
          _flushTimer = null;
          _commit(loading: false);
        });
      }
    });
    await sub.eose;
    // Relays often deliver their last events right after EOSE.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    await listener.cancel();
    sub.close();
    _open.remove(sub);
    return (added: added, raw: raw, oldest: oldest);
  }

  List<List<String>> _chunks(Iterable<String> authors) {
    final list = authors.toList()..sort();
    return [
      for (var i = 0; i < list.length; i += _chunk)
        list.sublist(i, math.min(i + _chunk, list.length)),
    ];
  }

  /// One bounded request for the whole feed.
  Future<_Page> _request({int? until}) async {
    final pool = ref.read(relayPoolProvider);
    if (_mode == FeedMode.discover) {
      return _collect(
        pool.subscribe([
          NostrFilter(
            kinds: NostrKinds.mediaKinds,
            until: until,
            limit: _pageSize,
          ),
        ], eoseTimeout: _loadTimeout),
      );
    }

    final authors = _authors;
    List<NostrFilter> filtersFor(Iterable<String> subset) => [
      for (final c in _chunks(subset))
        NostrFilter(
          kinds: NostrKinds.mediaKinds,
          authors: c,
          until: until,
          limit: 20,
        ),
    ];

    // The user's own relays answer straight away…
    final own = _collect(
      pool.subscribe(filtersFor(authors), eoseTimeout: _loadTimeout),
    );
    // …while the relays each author publishes to are looked up and asked.
    final outbox = ref.read(outboxProvider);
    final theirs = () async {
      try {
        await outbox.ensure(authors).timeout(const Duration(seconds: 8));
      } on TimeoutException {
        // Plan with what is known.
      }
      if (_disposed) return _noPage;
      final mine = pool.readRelays.toSet();
      final plan = outbox.plan(authors, maxRelays: 6);
      final results = await Future.wait([
        for (final entry in plan.entries)
          if (!mine.contains(entry.key))
            _collect(
              pool.subscribe(
                filtersFor(entry.value),
                extraRelays: [entry.key],
                onlyExtra: true,
                eoseTimeout: _loadTimeout,
              ),
            ),
      ]);
      return results.fold<_Page>(_noPage, _merge);
    }();
    final pages = await Future.wait([own, theirs]);
    return _merge(pages[0], pages[1]);
  }

  static _Page _merge(_Page a, _Page b) => (
    added: a.added + b.added,
    raw: a.raw + b.raw,
    oldest: _older(a.oldest, b.oldest),
  );

  /// Remembers how far back the relays have been read.
  void _noteCursor(_Page page) {
    final oldest = page.oldest;
    if (oldest != null) _cursor = _older(_cursor, oldest);
  }

  /// Asks for the page before everything received so far. `raw == 0` in the
  /// answer means the relays have nothing older (or ignore `until` and would
  /// hand the same events back forever).
  Future<_Page> _olderPage() async {
    final cursor =
        _cursor ?? (state.posts.isEmpty ? null : state.posts.last.createdAt);
    if (cursor == null) return _noPage;
    final page = await _request(until: cursor - 1);
    final oldest = page.oldest;
    if (oldest == null || oldest >= cursor) {
      return (added: page.added, raw: 0, oldest: null);
    }
    _cursor = oldest;
    return page;
  }

  Future<void> _load() {
    final running = _running;
    if (running != null) return running;
    return _running = () async {
      try {
        ref.read(relayPoolProvider).connect();
        if (_mode == FeedMode.following) {
          _authors = await _followedAuthors();
          if (_disposed) return;
          final nobody =
              _authors.length <= 1 && ref.read(followListProvider).isEmpty;
          if (_authors.isEmpty || nobody) {
            state = state.copyWith(
              isLoading: false,
              followsNobody: true,
              hasMore: false,
              clearError: true,
            );
            return;
          }
          state = state.copyWith(followsNobody: false);
        }
        var page = await _request();
        _noteCursor(page);
        // A first page made only of stories or expired posts is not "no
        // posts": look further back before giving up.
        for (var i = 0; i < _maxEmptyPages; i++) {
          if (_disposed || page.raw == 0 || _byId.values.any(_isShown)) break;
          page = await _olderPage();
        }
        if (_disposed) return;
        state = state.copyWith(
          isLoading: false,
          clearError: true,
          error: _byId.isEmpty
              ? (_mode == FeedMode.following
                    ? AppStrings.current.noRecentPostsFromFollowed
                    : AppStrings.current.noMomentsFound)
              : null,
        );
        _commit(loading: false, hasMore: true);
      } catch (e) {
        if (!_disposed) {
          state = state.copyWith(
            isLoading: false,
            error: AppStrings.current.loadFailed,
          );
        }
      } finally {
        _running = null;
      }
    }();
  }

  /// Completes when no load is running (used by tests and refresh logic).
  Future<void> whenIdle() async {
    while (_running != null) {
      await _running;
    }
  }

  /// Pull-to-refresh and "tap Home": fetches the newest posts and merges
  /// them in. Completes when the relays answered (or gave up).
  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, clearError: true);
    final work = _refreshWork().whenComplete(() {
      if (!_disposed) state = state.copyWith(isRefreshing: false);
    });
    // The pull-to-refresh spinner must not outlast the first answers: one
    // slow relay (or a lookup that times out) keeps a load open for many
    // seconds while the new posts have long been on screen. The load goes on
    // in the background; the posts keep arriving.
    await Future.any([work, Future<void>.delayed(_spinnerLimit)]);
  }

  Future<void> _refreshWork() async {
    // A load already in flight asked the relays before whatever made the
    // user refresh: let it finish, then ask again. Several refreshes in a
    // row collapse into a single new load.
    final running = _running;
    if (running != null) await running;
    if (_disposed) return;
    await _load();
  }

  /// Pagination: older posts, using `until` just before the oldest one.
  Future<void> loadMore() async {
    if (state.isLoadingMore ||
        state.isLoading ||
        !state.hasMore ||
        _running != null ||
        state.posts.isEmpty) {
      return;
    }
    state = state.copyWith(isLoadingMore: true);
    try {
      for (var i = 0; i < _maxEmptyPages; i++) {
        final page = await _olderPage();
        if (_disposed) return;
        if (page.raw == 0) return _commit(hasMore: false);
        if (page.added > 0) return _commit(hasMore: true);
      }
      // Several pages of nothing but stories: there is more, keep scrolling.
      _commit(hasMore: true);
    } finally {
      if (!_disposed) state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> persistCache() async {
    if (_disposed) return;
    // Close-friends posts live in their own store, never in this cache.
    final events = [
      for (final p in state.posts.where((p) => !p.isPrivate).take(150)) p.event,
    ];
    final cache = ref.read(localCacheProvider);
    if (_mode == FeedMode.discover) {
      await cache.saveEvents(events, file: _cacheFile);
      return;
    }
    final me = ref.read(authProvider).publicKey;
    if (me != null) await cache.saveOwnedEvents(me, events, file: _cacheFile);
  }
}

final feedProvider =
    NotifierProvider.family<FeedController, FeedState, FeedMode>(
      FeedController.new,
    );
