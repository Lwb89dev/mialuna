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
  final Map<String, MediaPost> _byId = {};
  Timer? _flushTimer;
  Future<void>? _running;
  bool _disposed = false; // a load may end after the provider is gone

  @override
  ReelsState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _flushTimer?.cancel();
    });
    ref.listen(muteProvider, (_, _) => _commit());
    ref.listen(blockProvider, (_, _) => _commit());
    ref.listen(brokenMediaProvider, (_, _) => _commit());
    Future.microtask(_load);
    return const ReelsState();
  }

  Future<void> _load() {
    return _running ??= () async {
      try {
        final sub = ref.read(relayPoolProvider).subscribe([
          const NostrFilter(
            kinds: [NostrKinds.shortVideo, NostrKinds.addressableShortVideo],
            limit: 50,
          ),
        ], eoseTimeout: const Duration(seconds: 12));
        final listener = sub.events.listen(_ingest);
        await sub.eose;
        await Future<void>.delayed(const Duration(milliseconds: 300));
        await listener.cancel();
        sub.close();
        _commit();
      } finally {
        _running = null;
      }
    }();
  }

  void _ingest(NostrEvent event) {
    if (_byId.containsKey(event.id)) return;
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
    final reels = [
      for (final p in _byId.values)
        if (!muted.contains(p.author) &&
            !blocked.contains(p.author) &&
            !broken.contains(p.id))
          p,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = ReelsState(reels: reels, isLoading: false);
  }

  /// Fetches newer reels and merges them in.
  Future<void> refresh() => _load();
}

final reelsProvider = NotifierProvider<ReelsController, ReelsState>(
  ReelsController.new,
);
