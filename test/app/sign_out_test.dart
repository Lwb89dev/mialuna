import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/app/sign_out.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/nwc_controller.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/settings/settings_controller.dart';
import 'package:mialuna/features/social/moderation_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A real session ends with the secure storage; tests have none, so only the
/// state change is kept.
class _Auth extends AuthController {
  final Signer signer;
  _Auth(this.signer);
  @override
  AuthState build() => AuthState(signer);
  @override
  Future<void> logout() async => state = AuthState(GuestSigner());
}

void main() {
  late Directory dir;
  late LocalCache cache;
  late NsecSigner me;
  late NsecSigner other;

  setUp(() {
    me = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
    other = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
    dir = Directory.systemTemp.createTempSync('mialuna_signout_');
    cache = LocalCache(directory: dir);
    FlutterSecureStorage.setMockInitialValues({});
  });

  Future<ProviderContainer> signedIn() async {
    final wallet =
        'nostr+walletconnect://${'ab' * 32}?relay=wss%3A%2F%2Frelay.example&secret=${'cd' * 32}';
    FlutterSecureStorage.setMockInitialValues({'mialuna_nwc_uri': wallet});
    final c = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => _Auth(me)),
        indexerRelaysProvider.overrideWithValue(const []),
        relayPoolProvider.overrideWithValue(RelayPool(const [])),
        localCacheProvider.overrideWithValue(cache),
      ],
    );
    addTearDown(c.dispose);
    c.listen(nwcProvider, (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return c;
  }

  test('nothing of the account stays on the phone', () async {
    SharedPreferences.setMockInitialValues({
      'mialuna_bookmarks': ['a' * 64],
      'mialuna_muted': ['b' * 64],
      'mialuna_muted_hashtags': ['spam'],
      'mialuna_blocked': ['c' * 64],
      'mialuna_seen_stories': ['d' * 64],
      'mialuna_audience': 'closeFriends',
      'mialuna_story_views_sent_${me.publicKey}': ['e' * 64],
      // Device settings are not the account's.
      'mialuna_theme_mode': 'dark',
      'mialuna_language': 'it',
      'mialuna_send_story_views': false,
      'mialuna_system_notifications': false,
    });
    for (final f in LocalCache.accountFiles(me.publicKey)) {
      await cache.writeJson(f, {'secret': 'decrypted'});
    }
    await cache.writeJson('events_following.json', {
      'owner': me.publicKey,
      'events': [],
    });
    await cache.writeJson(LocalCache.draftsFile, {
      'composer_draft': {'caption': 'bozza privata'},
    });
    // Somebody else's files are not ours to delete.
    await cache.writeJson('dm_${other.publicKey}.json', {'keep': true});

    final c = await signedIn();
    expect(c.read(nwcProvider), isNotNull, reason: 'the wallet was linked');
    await c.read(signOutProvider)();

    for (final f in LocalCache.accountFiles(me.publicKey)) {
      expect(File('${dir.path}/$f').existsSync(), false, reason: f);
    }
    expect(File('${dir.path}/events_following.json').existsSync(), false);
    expect(File('${dir.path}/drafts.json').existsSync(), false);
    expect(File('${dir.path}/dm_${other.publicKey}.json').existsSync(), true);

    final prefs = await SharedPreferences.getInstance();
    for (final k in [
      'mialuna_bookmarks',
      'mialuna_muted',
      'mialuna_muted_hashtags',
      'mialuna_blocked',
      'mialuna_seen_stories',
      'mialuna_audience',
      'mialuna_story_views_sent_${me.publicKey}',
    ]) {
      expect(prefs.containsKey(k), false, reason: k);
    }
    expect(prefs.getString('mialuna_theme_mode'), 'dark');
    expect(prefs.getString('mialuna_language'), 'it');
    expect(prefs.getBool('mialuna_send_story_views'), false);
    expect(prefs.getBool('mialuna_system_notifications'), false);

    expect(c.read(nwcProvider), isNull, reason: 'the wallet link is gone');
    expect(
      await const FlutterSecureStorage().read(key: 'mialuna_nwc_uri'),
      isNull,
    );
    expect(c.read(authProvider).isGuest, true);
    expect(c.read(bookmarksProvider), isEmpty);
    expect(c.read(muteControllerProvider).pubkeys, isEmpty);
    expect(c.read(blockProvider), isEmpty);
  });

  test(
    'the next account does not inherit the relay list edits of this one',
    () async {
      SharedPreferences.setMockInitialValues({
        'mialuna_relay_list_owner': me.publicKey,
        'mialuna_relay_list_dirty': true,
        'mialuna_relay_list_created_at': 1700000000,
      });
      final c = await signedIn();
      c.read(settingsProvider);
      await c.read(signOutProvider)();
      final s = c.read(settingsProvider);
      expect(s.relayListOwner, isNull);
      expect(s.relayListDirty, false);
      expect(s.relayListCreatedAt, 0);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('mialuna_relay_list_owner'), false);
      expect(prefs.getBool('mialuna_relay_list_dirty'), false);
    },
  );
}
