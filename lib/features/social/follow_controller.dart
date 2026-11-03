import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/relay_pool.dart';

/// NIP-02 follow list (kind 3). Changing it preserves everything else in the
/// event — relay hints and petnames of other follows, non-`p` tags and the
/// legacy `content` — and never publishes before the current list is known,
/// so a slow relay cannot make a single follow overwrite the whole list.
class FollowListController extends Notifier<Set<String>> {
  NostrEvent? _latest;
  PoolSubscription? _sub;
  late Completer<void> _loaded;
  late Completer<void> _usable;

  @override
  Set<String> build() {
    _latest = null;
    _loaded = Completer<void>();
    _usable = Completer<void>();
    ref.onDispose(() => _sub?.close());
    final pub = ref.watch(authProvider).publicKey;
    if (pub != null) {
      _loadSaved(pub);
      _load(pub);
    }
    return {};
  }

  String _fileFor(String pub) => 'follows_$pub.json';

  /// The list as of the last session, so the feed does not have to wait for
  /// a relay to learn whom to show. Never used to edit the list (that needs
  /// the real event, see [toggleFollow]).
  Future<void> _loadSaved(String pub) async {
    final json = await ref.read(localCacheProvider).readJson(_fileFor(pub));
    if (_latest != null || json is! Map) return; // the relays were faster
    final saved = {
      for (final p in (json['p'] as List? ?? const []))
        if (p is String && p.length == 64) p,
    };
    if (saved.isEmpty) return;
    state = saved;
    if (!_usable.isCompleted) _usable.complete();
  }

  void _saveList(String pub) {
    ref.read(localCacheProvider).writeJson(_fileFor(pub), {
      'p': state.toList(),
    });
  }

  Future<void> _load(String pubkey) async {
    // The completers of *this* account: a later account has new ones, and the
    // end of this load must not release anything waiting for the next list.
    final loaded = _loaded;
    final usable = _usable;
    final sub = ref
        .read(relayPoolProvider)
        .subscribe(
          [
            NostrFilter(
              kinds: const [NostrKinds.followList],
              authors: [pubkey],
              limit: 3,
            ),
          ],
          extraRelays: ref.read(indexerRelaysProvider),
          eoseTimeout: const Duration(seconds: 7),
        );
    _sub = sub;
    sub.events.listen((event) {
      final latest = _latest;
      if (latest != null && latest.createdAt >= event.createdAt) return;
      _latest = event;
      state = {
        for (final t in event.tags)
          if (t.length >= 2 && t[0] == 'p') t[1],
      };
      _saveList(pubkey);
    });
    await sub.eose;
    if (!loaded.isCompleted) loaded.complete();
    if (!usable.isCompleted) usable.complete();
  }

  /// Completes once the follow list has been read from the relays (or the
  /// relays answered that there is none).
  Future<void> get ready => _loaded.future;

  /// Completes as soon as there is a list to show things by: the one saved on
  /// this device, or the relays' answer, whichever comes first. Reading is
  /// fine with this; editing the list waits for [ready].
  Future<void> get usable => _usable.future;

  /// Follows or unfollows [pubkey]. Returns false when it could not be
  /// published (guest, list not loaded yet, signer or relay failure).
  Future<bool> toggleFollow(String pubkey) async {
    final signer = ref.read(authProvider).signer;
    if (!signer.canSign) return false;
    try {
      await _loaded.future.timeout(const Duration(seconds: 10));
    } on TimeoutException {
      return false;
    }
    final previous = state;
    final following = previous.contains(pubkey);
    final base = _latest;
    final tags = <List<String>>[
      for (final t in base?.tags ?? const <List<String>>[])
        if (!(following && t.length >= 2 && t[0] == 'p' && t[1] == pubkey)) t,
      if (!following) ['p', pubkey],
    ];
    state = {
      for (final t in tags)
        if (t.length >= 2 && t[0] == 'p') t[1],
    }; // optimistic
    try {
      final event = await signer.signEvent(
        kind: NostrKinds.followList,
        tags: tags,
        content: base?.content ?? '',
      );
      final report = await ref
          .read(relayPoolProvider)
          .publish(event, extraRelays: ref.read(indexerRelaysProvider));
      if (!report.publishedSomewhere) {
        state = previous;
        return false;
      }
      _latest = event;
      return true;
    } catch (_) {
      state = previous;
      return false;
    }
  }

  bool isFollowing(String pubkey) => state.contains(pubkey);
}

final followListProvider = NotifierProvider<FollowListController, Set<String>>(
  FollowListController.new,
);
