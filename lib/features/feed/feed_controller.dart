import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/models/media_event.dart';

class FeedState {
  final List<MediaPost> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  const FeedState({
    this.posts = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.error,
  });

  FeedState copyWith({
    List<MediaPost>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
  }) => FeedState(
    posts: posts ?? this.posts,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    error: error,
  );
}

/// Home feed: kind 20/21/22 media posts only. Kind 1 never enters here.
/// Stories (NIP-40 expired or story-labeled) are excluded from the feed.
class FeedController extends Notifier<FeedState> {
  static const _pageSize = 30;
  StreamSubscription? _sub;
  String? _subId;
  final Set<String> _postIds = {};

  @override
  FeedState build() {
    ref.onDispose(() {
      _sub?.cancel();
      if (_subId != null) ref.read(relayPoolProvider).unsubscribe(_subId!);
    });
    _start();
    return const FeedState();
  }

  void _start() {
    final pool = ref.read(relayPoolProvider);
    pool.connect();
    final (:id, :stream) = pool.subscribe([
      const NostrFilter(kinds: NostrKinds.mediaKinds, limit: _pageSize),
    ]);
    _subId = id;
    _sub = stream.listen(_ingest);
    _restoreCache();
  }

  Future<void> _restoreCache() async {
    final cached = await ref.read(localCacheProvider).loadEvents();
    for (final e in cached) {
      _ingest(e);
    }
  }

  void _ingest(NostrEvent event) {
    if (_postIds.contains(event.id)) return;
    final post = MediaPost.tryParse(event);
    if (post == null || post.isStory || post.isExpired()) return;
    _postIds.add(event.id);
    ref.read(eventStoreProvider).add(event);
    final posts = [...state.posts, post]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = state.copyWith(posts: posts, isLoading: false);
  }

  Future<void> refresh() async {
    final posts = <MediaPost>[];
    _postIds.clear();
    state = const FeedState();
    if (_subId != null) ref.read(relayPoolProvider).unsubscribe(_subId!);
    await _sub?.cancel();
    _start();
    state = state.copyWith(posts: posts);
  }

  /// Pagination: request older events using `until`.
  Future<void> loadMore() async {
    if (state.isLoadingMore || state.posts.isEmpty) return;
    state = state.copyWith(isLoadingMore: true);
    final oldest = state.posts.last.createdAt;
    final pool = ref.read(relayPoolProvider);
    final (:id, :stream) = pool.subscribe([
      NostrFilter(
        kinds: NostrKinds.mediaKinds,
        until: oldest - 1,
        limit: _pageSize,
      ),
    ]);
    final sub = stream.listen(_ingest);
    // Historical queries close after a grace period; EOSE-based closing is
    // relay-dependent, so we use a timeout.
    await Future.delayed(const Duration(seconds: 8));
    await sub.cancel();
    pool.unsubscribe(id);
    state = state.copyWith(isLoadingMore: false);
  }

  Future<void> persistCache() async {
    final events = ref
        .read(eventStoreProvider)
        .query(kinds: NostrKinds.mediaKinds);
    await ref.read(localCacheProvider).saveEvents(events);
  }
}

final feedProvider = NotifierProvider<FeedController, FeedState>(
  FeedController.new,
);
