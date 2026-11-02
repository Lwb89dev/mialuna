import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/nip59.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/messages/dm_controller.dart';
import 'package:mialuna/features/social/moderation_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_relay.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

ProviderContainer _app(Signer signer, FakeRelay relay, Directory dir) {
  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWith(() => _FixedAuth(signer)),
      indexerRelaysProvider.overrideWithValue(const []),
      localCacheProvider.overrideWithValue(LocalCache(directory: dir)),
      relayPoolProvider.overrideWith((ref) {
        final pool = RelayPool([RelayConfig(relay.url)]);
        pool.authSigner = (url, challenge) => signer.signEvent(
          kind: NostrKinds.clientAuth,
          tags: [
            ['relay', url],
            ['challenge', challenge],
          ],
          content: '',
        );
        ref.onDispose(pool.dispose);
        return pool;
      }),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// The number on the paper-plane of Home: it must only ever count messages
/// that arrived after this device first synced.
void main() {
  late FakeRelay relay;
  late NsecSigner alice;
  late NsecSigner bob;

  Future<NostrEvent> message(String text, {required int at, Signer? from}) {
    final sender = from ?? bob;
    return GiftWrap.wrap(
      signer: sender,
      rumor: Rumor.create(
        pubkey: sender.publicKey!,
        kind: NostrKinds.chatMessage,
        tags: [
          ['p', alice.publicKey],
        ],
        content: text,
        createdAt: at,
      ),
      recipient: alice.publicKey,
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    relay = await FakeRelay(authKinds: {1059}).start();
    alice = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
    bob = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
    for (final s in [alice, bob]) {
      relay.add(
        await signed(
          s,
          kind: NostrKinds.dmRelayList,
          tags: [
            ['relay', relay.url],
          ],
        ),
      );
    }
  });

  tearDown(() => relay.stop());

  test(
    'old messages are never unread, not even while the first sync runs',
    () async {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      for (var i = 0; i < 3; i++) {
        relay.add(await message('old $i', at: now - 3600 + i));
      }

      final app = _app(
        alice,
        relay,
        Directory.systemTemp.createTempSync('mialuna_unread_'),
      );
      var worst = 0;
      app.listen(dmProvider, (_, s) {
        worst = math.max(worst, s.unreadCount);
      }, fireImmediately: true);

      await eventually(() {
        final s = app.read(dmProvider);
        return !s.loading &&
            (s.conversations[bob.publicKey]?.messages.length ?? 0) == 3;
      }, reason: 'the history never arrived');

      expect(app.read(dmProvider).unreadCount, 0);
      expect(worst, 0, reason: 'the badge flashed while the inbox filled up');
    },
  );

  test(
    'a message that arrives later is unread until the chat is opened',
    () async {
      final app = _app(
        alice,
        relay,
        Directory.systemTemp.createTempSync('mialuna_unread_'),
      );
      app.listen(dmProvider, (_, _) {});
      await eventually(() {
        final s = app.read(dmProvider);
        return !s.loading && s.inboxConfigured == true;
      });

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      relay.push(await message('ciao Alice', at: now + 5));
      relay.push(await message('ci sei?', at: now + 6));

      await eventually(
        () => app.read(dmProvider).unreadCount == 2,
        reason: 'the new messages did not raise the badge',
      );

      app.read(dmProvider.notifier).markRead(bob.publicKey);
      expect(app.read(dmProvider).unreadCount, 0);
    },
  );

  test('messages from someone you blocked never raise the badge', () async {
    final carol = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
    final app = _app(
      alice,
      relay,
      Directory.systemTemp.createTempSync('mialuna_unread_'),
    );
    app.listen(dmProvider, (_, _) {});
    await eventually(() {
      final s = app.read(dmProvider);
      return !s.loading && s.inboxConfigured == true;
    });
    await app.read(blockProvider.notifier).block(bob.publicKey);

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    relay.push(await message('spam', at: now + 5));
    // Messages are handled in order: once Carol's is counted, Bob's was seen.
    relay.push(await message('ciao', at: now + 6, from: carol));
    await eventually(() => app.read(dmProvider).unreadCount == 1);

    final conversations = app.read(dmProvider).conversations;
    expect(conversations.keys, [carol.publicKey]);
  });
}
