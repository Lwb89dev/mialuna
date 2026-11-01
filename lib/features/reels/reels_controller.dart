import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/models/media_event.dart';
import '../social/moderation_controller.dart';

class ReelsState {
  final List<MediaPost> reels;
  final bool isLoading;
  const ReelsState({this.reels = const [], this.isLoading = true});
}

/// Loads kind 22 (and 34236) short videos for the vertical Reels viewer.
class ReelsController extends Notifier<ReelsState> {
  StreamSubscription? _sub;
  String? _subId;
  final Set<String> _seen = {};

  @override
  ReelsState build() {
    ref.onDispose(() {
      _sub?.cancel();
      if (_subId != null) ref.read(relayPoolProvider).unsubscribe(_subId!);
    });
    _start();
    return const ReelsState();
  }

  void _start() {
    final pool = ref.read(relayPoolProvider);
    pool.connect();
    final (:id, :stream) = pool.subscribe([
      const NostrFilter(
        kinds: [NostrKinds.shortVideo, NostrKinds.addressableShortVideo],
        limit: 50,
      ),
    ]);
    _subId = id;
    _sub = stream.listen((event) {
      if (_seen.contains(event.id)) return;
      if (ref.read(muteProvider).contains(event.pubkey) ||
          ref.read(blockProvider).contains(event.pubkey)) {
        return;
      }
      final post = MediaPost.tryParse(event);
      if (post == null || post.isStory || post.isExpired()) return;
      if (post.media.isEmpty || !post.media.first.isVideo) return;
      _seen.add(event.id);
      final reels = [...state.reels, post]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = ReelsState(reels: reels, isLoading: false);
    });
  }

  Future<void> refresh() async {
    _seen.clear();
    if (_subId != null) ref.read(relayPoolProvider).unsubscribe(_subId!);
    await _sub?.cancel();
    state = const ReelsState();
    _start();
  }
}

final reelsProvider = NotifierProvider<ReelsController, ReelsState>(
  ReelsController.new,
);
