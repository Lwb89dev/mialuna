import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/models/media_event.dart';
import '../social/moderation_controller.dart';

/// Stories published by one creator, newest first.
class StoryGroup {
  final String author;
  final List<MediaPost> stories;
  const StoryGroup({required this.author, required this.stories});

  int get latestTimestamp => stories.isEmpty ? 0 : stories.first.createdAt;
}

class StoriesState {
  final List<StoryGroup> groups;
  final bool isLoading;
  const StoriesState({this.groups = const [], this.isLoading = true});
}

/// Loads story-labeled media events (NIP-40 expiring kind 20/22) and groups
/// them by creator. Expired stories never surface here.
class StoriesController extends Notifier<StoriesState> {
  StreamSubscription? _sub;
  String? _subId;
  final Map<String, MediaPost> _byId = {};

  static const storyWindowSeconds = 86400;

  @override
  StoriesState build() {
    ref.onDispose(() {
      _sub?.cancel();
      if (_subId != null) ref.read(relayPoolProvider).unsubscribe(_subId!);
    });
    _start();
    return const StoriesState();
  }

  void _start() {
    final pool = ref.read(relayPoolProvider);
    pool.connect();
    final since =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 - storyWindowSeconds;
    final (:id, :stream) = pool.subscribe([
      NostrFilter(
        kinds: const [NostrKinds.picture, NostrKinds.shortVideo],
        tagFilters: const {
          '#L': ['mialuna.story'],
        },
        since: since,
        limit: 200,
      ),
    ]);
    _subId = id;
    _sub = stream.listen(_ingest);
  }

  void _ingest(dynamic event) {
    final e = event as NostrEvent;
    if (_byId.containsKey(e.id)) return;
    if (ref.read(blockProvider).contains(e.pubkey) ||
        ref.read(muteProvider).contains(e.pubkey)) {
      return;
    }
    final post = MediaPost.tryParse(e);
    if (post == null || !post.isStory || post.isExpired()) return;
    _byId[e.id] = post;
    _regroup();
  }

  void _regroup() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final byAuthor = <String, List<MediaPost>>{};
    for (final post in _byId.values) {
      if (post.isExpired(now)) continue; // prune expired on regroup
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

  Future<void> refresh() async {
    _byId.clear();
    if (_subId != null) ref.read(relayPoolProvider).unsubscribe(_subId!);
    await _sub?.cancel();
    state = const StoriesState();
    _start();
  }
}

final storiesProvider = NotifierProvider<StoriesController, StoriesState>(
  StoriesController.new,
);
