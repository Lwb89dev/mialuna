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

/// Locally muted authors, filtered from every feed, with NIP-51 sync
/// (kind 10000). Muting is silent: the muted author is never notified.
class MuteController extends Notifier<Set<String>> {
  static const _prefsKey = 'mialuna_muted';
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

  Future<void> mute(String pubkey) async {
    final next = {...state, pubkey};
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, next.toList());
    await _publish();
  }

  Future<void> unmute(String pubkey) async {
    final next = {...state}..remove(pubkey);
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, next.toList());
    await _publish();
  }

  bool isMuted(String pubkey) => state.contains(pubkey);

  /// Merges the relay mute list into the local one (once per session).
  Future<void> syncFromRelays(String pubkey) async {
    if (!_synced.add(pubkey)) return;
    try {
      final event = await _fetchNewestList(
        ref.read(relayPoolProvider),
        NostrKinds.muteList,
        pubkey,
      );
      final remote = event == null ? <String>{} : Nip51.mutedPubkeys(event);
      final merged = {...state, ...remote};
      if (merged.length != state.length) {
        state = merged;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_prefsKey, merged.toList());
      }
      if (event != null || state.isNotEmpty) await _publish();
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
        tags: Nip51.muteTags(state),
        content: '',
      );
      await ref.read(relayPoolProvider).publish(event);
    } catch (_) {}
  }
}

final muteProvider = NotifierProvider<MuteController, Set<String>>(
  MuteController.new,
);

/// Triggers the NIP-51 merge whenever a user is (or becomes) signed in.
final listsSyncProvider = Provider<void>((ref) {
  final pub = ref.watch(authProvider).publicKey;
  if (pub == null) return;
  Future.microtask(() {
    ref.read(bookmarksProvider.notifier).syncFromRelays(pub);
    ref.read(muteProvider.notifier).syncFromRelays(pub);
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
