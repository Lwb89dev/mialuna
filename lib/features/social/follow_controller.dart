import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';

/// NIP-02 follow list (kind 3). Preserves existing entries — including
/// unknown non-`p` tags — when modified.
class FollowListController extends Notifier<Set<String>> {
  List<List<String>> _otherTags = [];
  StreamSubscription? _sub;
  String? _subId;

  @override
  Set<String> build() {
    ref.onDispose(() {
      _sub?.cancel();
      if (_subId != null) ref.read(relayPoolProvider).unsubscribe(_subId!);
    });
    final pub = ref.watch(authProvider).publicKey;
    if (pub != null) _load(pub);
    return {};
  }

  void _load(String pubkey) {
    final pool = ref.read(relayPoolProvider);
    pool.connect();
    final (:id, :stream) = pool.subscribe([
      NostrFilter(
        kinds: const [NostrKinds.followList],
        authors: [pubkey],
        limit: 1,
      ),
    ]);
    _subId = id;
    _sub = stream.listen((event) {
      final followed = <String>{
        for (final t in event.tags)
          if (t.length >= 2 && t[0] == 'p') t[1],
      };
      _otherTags = [
        for (final t in event.tags)
          if (t.isEmpty || t[0] != 'p') t,
      ];
      state = followed;
    });
  }

  Future<void> toggleFollow(String pubkey) async {
    final signer = ref.read(authProvider).signer;
    if (!signer.canSign) return;
    final followed = {...state};
    if (followed.contains(pubkey)) {
      followed.remove(pubkey);
    } else {
      followed.add(pubkey);
    }
    state = followed; // optimistic
    try {
      final event = await signer.signEvent(
        kind: NostrKinds.followList,
        tags: [
          ..._otherTags,
          for (final p in followed) ['p', p],
        ],
        content: '',
      );
      await ref.read(relayPoolProvider).publish(event);
    } catch (_) {}
  }

  bool isFollowing(String pubkey) => state.contains(pubkey);
}

final followListProvider = NotifierProvider<FollowListController, Set<String>>(
  FollowListController.new,
);
