import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth/auth_controller.dart';
import '../core/nostr/nwc_controller.dart';
import '../core/storage/local_cache.dart';
import '../features/create/create_controller.dart';
import '../features/private/close_friends.dart';
import '../features/private/private_posts.dart';
import '../features/settings/settings_controller.dart';
import '../features/social/moderation_controller.dart';
import '../features/stories/stories_controller.dart';
import '../features/stories/story_receipts.dart';
import 'providers.dart';

/// Preferences that belong to an account (they would otherwise be merged into
/// the next account's NIP-51 lists, and published): saved posts, muted
/// people and hashtags, blocks, watched stories, the audience last picked.
const _accountPreferences = [
  'mialuna_audience',
  'mialuna_blocked',
  'mialuna_bookmarks',
  'mialuna_muted',
  'mialuna_muted_hashtags',
  'mialuna_seen_stories',
];

/// Signs out and leaves nothing of the account behind on the phone: the key,
/// the wallet link (a Nostr Wallet Connect secret is the right to spend), the
/// decrypted messages and close-friends posts, the friends list, every cache
/// and draft, and the account's own preferences.
final signOutProvider = Provider<Future<void> Function()>(
  (ref) =>
      () => _signOut(ref),
);

Future<void> _signOut(Ref ref) async {
  final pubkey = ref.read(authProvider).publicKey;
  // Receipts still waiting are never sent, and nothing is written for them
  // once the files below are gone.
  ref.read(storyViewReporterProvider).discard();
  await ref.read(privatePostsProvider.notifier).clear();
  await ref.read(privateMediaProvider).cleanUp(everything: true);
  await ref.read(nwcProvider.notifier).disconnect();
  // The controllers of this account stop (and cancel their pending saves)
  // when the session ends; only then is it safe to delete their files.
  await ref.read(authProvider.notifier).logout();

  final cache = ref.read(localCacheProvider);
  if (pubkey != null) {
    for (final file in LocalCache.accountFiles(pubkey)) {
      await cache.deleteFile(file);
    }
  }
  await cache.clearEvents();
  await cache.deleteFile(LocalCache.draftsFile);

  final prefs = await ref.read(sharedPreferencesLoader)();
  for (final key in _accountPreferences) {
    await prefs.remove(key);
  }
  if (pubkey != null) await prefs.remove('mialuna_story_views_sent_$pubkey');
  await ref.read(settingsProvider.notifier).detachAccount();

  // What was held in memory goes too.
  ref.invalidate(bookmarksProvider);
  ref.invalidate(muteControllerProvider);
  ref.invalidate(blockProvider);
  ref.invalidate(seenStoriesProvider);
  ref.invalidate(audiencePreferenceProvider);
  ref.invalidate(composerProvider);
  ref.invalidate(closeFriendsProvider);
}
