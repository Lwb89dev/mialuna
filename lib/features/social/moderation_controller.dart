import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/nip51.dart';
import '../../core/nostr/relay_pool.dart';

/// Fetches the author's newest list event of [kind] from the pool.
Future<NostrEvent?> _fetchNewestList(
  RelayPool pool,
  int kind,
  String pubkey, {
  Duration timeout = const Duration(seconds: 4),
}) async {
  pool.connect();
  final (:id, :stream) = pool.subscribe([
    NostrFilter(kinds: [kind], authors: [pubkey], limit: 3),
  ]);
  NostrEvent? newest;
  final sub = stream.listen((event) {
    if (newest == null || event.createdAt > newest!.createdAt) {
      newest = event;
    }
  });
  await Future<void>.delayed(timeout);
  await sub.cancel();
  pool.unsubscribe(id);
  return newest;
}

/// Local-first bookmarks with NIP-51 sync (kind 10003): the local set is
/// merged with the relay list on sign-in (union, never losing either side)
/// and published back on every change for signed-in users.
class BookmarksController extends Notifier<Set<String>> {
  static const _prefsKey = 'mialuna_bookmarks';
  final Set<String> _synced = {};

  @override
  Set<String> build() {
    _load();
    return {};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = (prefs.getStringList(_prefsKey) ?? []).toSet();
  }

  Future<void> toggle(String eventId) async {
    final next = {...state};
    next.contains(eventId) ? next.remove(eventId) : next.add(eventId);
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, next.toList());
    await _publish();
  }

  bool isSaved(String eventId) => state.contains(eventId);

  /// Merges the relay bookmark list into the local one (once per session
  /// per account). Local bookmarks are never deleted by the merge.
  Future<void> syncFromRelays(String pubkey) async {
    if (!_synced.add(pubkey)) return;
    try {
      final event = await _fetchNewestList(
        ref.read(relayPoolProvider),
        NostrKinds.bookmarks,
        pubkey,
      );
      final remote = event == null ? <String>{} : Nip51.bookmarkIds(event);
      final merged = {...state, ...remote};
      if (merged.length != state.length) {
        state = merged;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_prefsKey, merged.toList());
      }
      if (event != null || state.isNotEmpty) await _publish();
    } catch (_) {
      _synced.remove(pubkey); // allow retry
    }
  }

  Future<void> _publish() async {
    final signer = ref.read(authProvider).signer;
    if (!signer.canSign) return;
    try {
      final event = await signer.signEvent(
        kind: NostrKinds.bookmarks,
        tags: Nip51.bookmarkTags(state),
        content: '',
      );
      await ref.read(relayPoolProvider).publish(event);
    } catch (_) {}
  }
}

final bookmarksProvider = NotifierProvider<BookmarksController, Set<String>>(
  BookmarksController.new,
);

/// The user's mute list: authors whose posts are hidden and hashtags whose
/// posts are filtered out. Synced through NIP-51 kind 10000 (`p`/`t` tags).
class MuteList {
  final Set<String> pubkeys;
  final Set<String> hashtags;
  const MuteList({this.pubkeys = const {}, this.hashtags = const {}});

  MuteList copyWith({Set<String>? pubkeys, Set<String>? hashtags}) => MuteList(
    pubkeys: pubkeys ?? this.pubkeys,
    hashtags: hashtags ?? this.hashtags,
  );
}

/// Locally muted authors and hashtags, filtered from every feed, with
/// NIP-51 sync (kind 10000). Muting is silent: the muted author is never
/// notified.
class MuteController extends Notifier<MuteList> {
  static const _pubkeysKey = 'mialuna_muted';
  static const _hashtagsKey = 'mialuna_muted_hashtags';
  final Set<String> _synced = {};

  @override
  MuteList build() {
    _load();
    return const MuteList();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = MuteList(
      pubkeys: (prefs.getStringList(_pubkeysKey) ?? []).toSet(),
      hashtags: (prefs.getStringList(_hashtagsKey) ?? []).toSet(),
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_pubkeysKey, state.pubkeys.toList());
    await prefs.setStringList(_hashtagsKey, state.hashtags.toList());
    await _publish();
  }

  Future<void> mute(String pubkey) async {
    state = state.copyWith(pubkeys: {...state.pubkeys, pubkey});
    await _save();
  }

  Future<void> unmute(String pubkey) async {
    state = state.copyWith(pubkeys: {...state.pubkeys}..remove(pubkey));
    await _save();
  }

  Future<void> muteHashtag(String hashtag) async {
    final tag = hashtag.toLowerCase().replaceFirst(RegExp('^#'), '').trim();
    if (tag.isEmpty) return;
    state = state.copyWith(hashtags: {...state.hashtags, tag});
    await _save();
  }

  Future<void> unmuteHashtag(String hashtag) async {
    state = state.copyWith(hashtags: {...state.hashtags}..remove(hashtag));
    await _save();
  }

  bool isMuted(String pubkey) => state.pubkeys.contains(pubkey);

  /// Merges the relay mute list into the local one (once per session).
  Future<void> syncFromRelays(String pubkey) async {
    if (!_synced.add(pubkey)) return;
    try {
      final event = await _fetchNewestList(
        ref.read(relayPoolProvider),
        NostrKinds.muteList,
        pubkey,
      );
      if (event == null) {
        if (state.pubkeys.isNotEmpty || state.hashtags.isNotEmpty) {
          await _publish();
        }
        return;
      }
      final mergedPubkeys = {...state.pubkeys, ...Nip51.mutedPubkeys(event)};
      final mergedHashtags = {...state.hashtags, ...Nip51.mutedHashtags(event)};
      if (mergedPubkeys.length != state.pubkeys.length ||
          mergedHashtags.length != state.hashtags.length) {
        state = MuteList(pubkeys: mergedPubkeys, hashtags: mergedHashtags);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_pubkeysKey, mergedPubkeys.toList());
        await prefs.setStringList(_hashtagsKey, mergedHashtags.toList());
      }
      await _publish();
    } catch (_) {
      _synced.remove(pubkey);
    }
  }

  Future<void> _publish() async {
    final signer = ref.read(authProvider).signer;
    if (!signer.canSign) return;
    try {
      final event = await signer.signEvent(
        kind: NostrKinds.muteList,
        tags: Nip51.muteTags(state.pubkeys, hashtags: state.hashtags),
        content: '',
      );
      await ref.read(relayPoolProvider).publish(event);
    } catch (_) {}
  }
}

final muteControllerProvider = NotifierProvider<MuteController, MuteList>(
  MuteController.new,
);

/// Muted author pubkeys (feed, reels, explore filtering).
final muteProvider = Provider<Set<String>>(
  (ref) => ref.watch(muteControllerProvider).pubkeys,
);

/// Muted hashtags (posts carrying any of them are filtered out).
final mutedHashtagsProvider = Provider<Set<String>>(
  (ref) => ref.watch(muteControllerProvider).hashtags,
);

/// Locally blocked authors, hidden everywhere: feed, reels, stories,
/// comments and notifications. Blocking stays on the device — there is no
/// standard public block list, and publishing one would leak it.
class BlockController extends Notifier<Set<String>> {
  static const _prefsKey = 'mialuna_blocked';

  @override
  Set<String> build() {
    _load();
    return {};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = (prefs.getStringList(_prefsKey) ?? []).toSet();
  }

  Future<void> block(String pubkey) async {
    state = {...state, pubkey};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, state.toList());
  }

  Future<void> unblock(String pubkey) async {
    state = {...state}..remove(pubkey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, state.toList());
  }

  bool isBlocked(String pubkey) => state.contains(pubkey);
}

final blockProvider = NotifierProvider<BlockController, Set<String>>(
  BlockController.new,
);

/// Triggers the NIP-51 merge whenever a user is (or becomes) signed in.
final listsSyncProvider = Provider<void>((ref) {
  final pub = ref.watch(authProvider).publicKey;
  if (pub == null) return;
  Future.microtask(() {
    ref.read(bookmarksProvider.notifier).syncFromRelays(pub);
    ref.read(muteControllerProvider.notifier).syncFromRelays(pub);
  });
});

/// NIP-56 report (kind 1984).
Future<bool> reportEvent(
  WidgetRef ref, {
  required String eventId,
  required String authorPubkey,
  required String reason,
}) async {
  final signer = ref.read(authProvider).signer;
  if (!signer.canSign) return false;
  try {
    final event = await signer.signEvent(
      kind: 1984,
      tags: [
        ['e', eventId, '', reason],
        ['p', authorPubkey],
      ],
      content: '',
    );
    final report = await ref.read(relayPoolProvider).publish(event);
    return report.publishedSomewhere;
  } catch (_) {
    return false;
  }
}
