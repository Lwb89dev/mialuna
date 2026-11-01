import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';

/// Local bookmarks (option only; NIP-51 sync is a later iteration).
class BookmarksController extends Notifier<Set<String>> {
  static const _prefsKey = 'mialuna_bookmarks';

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
  }

  bool isSaved(String eventId) => state.contains(eventId);
}

final bookmarksProvider = NotifierProvider<BookmarksController, Set<String>>(
  BookmarksController.new,
);

/// Locally muted authors: filtered from every feed. Public block lists
/// (NIP-51) arrive in a later iteration; local muting never leaks.
class MuteController extends Notifier<Set<String>> {
  static const _prefsKey = 'mialuna_muted';

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
  }

  Future<void> unmute(String pubkey) async {
    final next = {...state}..remove(pubkey);
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, next.toList());
  }

  bool isMuted(String pubkey) => state.contains(pubkey);
}

final muteProvider = NotifierProvider<MuteController, Set<String>>(
  MuteController.new,
);

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
