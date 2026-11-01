import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/messages/dm_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_relay.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

/// One app instance for [signer] talking to [relay].
ProviderContainer appFor(Signer signer, FakeRelay relay, Directory dir) {
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

void main() {
  late FakeRelay relay;
  late NsecSigner alice;
  late NsecSigner bob;
  late Directory tmp;

  Directory newDir() => Directory.systemTemp.createTempSync('mialuna_dm_');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // Like a DM relay: gift wraps need NIP-42 authentication.
    relay = await FakeRelay(authKinds: {1059}).start();
    alice = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
    bob = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
    tmp = newDir();
    // Both people have turned private messages on (kind 10050).
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

  tearDown(() async {
    await relay.stop();
  });

  test('Alice writes to Bob, Bob reads it and answers', () async {
    final bobApp = appFor(bob, relay, newDir());
    final aliceApp = appFor(alice, relay, tmp);

    // Both apps are open: the inbox subscriptions are live.
    bobApp.listen(dmProvider, (_, _) {});
    aliceApp.listen(dmProvider, (_, _) {});
    await eventually(
      () =>
          bobApp.read(dmProvider).inboxConfigured == true &&
          aliceApp.read(dmProvider).inboxConfigured == true,
      reason: 'inbox relays were not discovered',
    );

    await aliceApp.read(dmProvider.notifier).send(bob.publicKey, 'ciao Bob!');

    // Alice sees her own message straight away…
    final mine = aliceApp.read(dmProvider).conversations[bob.publicKey]!;
    expect(mine.messages.single.text, 'ciao Bob!');
    expect(mine.messages.single.fromMe, true);
    expect(mine.messages.single.status, DmStatus.sent);

    // …and Bob receives it, decrypted, through the AUTH-protected relay.
    await eventually(
      () =>
          bobApp
              .read(dmProvider)
              .conversations[alice.publicKey]
              ?.messages
              .isNotEmpty ??
          false,
      reason: 'Bob never received the message',
    );
    final received = bobApp
        .read(dmProvider)
        .conversations[alice.publicKey]!
        .messages
        .single;
    expect(received.text, 'ciao Bob!');
    expect(received.fromMe, false);

    // The relay only ever stored gift wraps: no plaintext, no real authors.
    final wraps = relay.stored.where((e) => e.kind == NostrKinds.giftWrap);
    expect(wraps, isNotEmpty);
    for (final w in wraps) {
      expect(w.content, isNot(contains('ciao Bob')));
      expect(w.pubkey, isNot(anyOf(alice.publicKey, bob.publicKey)));
    }

    // Bob replies.
    await bobApp.read(dmProvider.notifier).send(alice.publicKey, 'ciao Alice');
    await eventually(
      () =>
          (aliceApp
                  .read(dmProvider)
                  .conversations[bob.publicKey]
                  ?.messages
                  .length ??
              0) ==
          2,
      reason: 'Alice never received the reply',
    );
    final thread = aliceApp
        .read(dmProvider)
        .conversations[bob.publicKey]!
        .messages;
    expect(thread.map((m) => m.text), ['ciao Bob!', 'ciao Alice']);
    expect(thread.map((m) => m.fromMe), [true, false]);
  });

  test(
    'the same message is not duplicated by the sender\'s own copy',
    () async {
      final aliceApp = appFor(alice, relay, tmp);
      aliceApp.listen(dmProvider, (_, _) {});
      await eventually(() => aliceApp.read(dmProvider).inboxConfigured == true);
      await aliceApp
          .read(dmProvider.notifier)
          .send(bob.publicKey, 'una volta sola');
      // Let the self-copy come back through the inbox subscription.
      await Future<void>.delayed(const Duration(seconds: 2));
      expect(
        aliceApp.read(dmProvider).conversations[bob.publicKey]!.messages,
        hasLength(1),
      );
    },
  );

  test('sharing a post sends a nostr: reference', () async {
    final aliceApp = appFor(alice, relay, tmp);
    aliceApp.listen(dmProvider, (_, _) {});
    await eventually(() => aliceApp.read(dmProvider).inboxConfigured == true);
    const ref =
        'nostr:nevent1qqs0000000000000000000000000000000000000000000000000000000q9ed5';
    await aliceApp
        .read(dmProvider.notifier)
        .send(bob.publicKey, 'guarda!\n$ref');
    final last = aliceApp.read(dmProvider).conversations[bob.publicKey]!.last!;
    expect(last.text, contains(ref));
  });

  test(
    'writing to someone who never enabled private messages fails clearly',
    () async {
      final carol = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
      final aliceApp = appFor(alice, relay, tmp);
      aliceApp.listen(dmProvider, (_, _) {});
      await eventually(() => aliceApp.read(dmProvider).inboxConfigured == true);
      await expectLater(
        aliceApp.read(dmProvider.notifier).send(carol.publicKey, 'ci sei?'),
        throwsA(isA<DmException>()),
      );
      final msg = aliceApp
          .read(dmProvider)
          .conversations[carol.publicKey]!
          .messages
          .single;
      expect(msg.status, DmStatus.failed);
    },
  );

  test(
    'history that predates the first sync does not count as unread',
    () async {
      final aliceApp = appFor(alice, relay, tmp);
      aliceApp.listen(dmProvider, (_, _) {});
      await eventually(() => aliceApp.read(dmProvider).inboxConfigured == true);
      await aliceApp
          .read(dmProvider.notifier)
          .send(bob.publicKey, 'vecchio messaggio');
      await Future<void>.delayed(const Duration(milliseconds: 300));

      // Bob opens the app for the first time afterwards.
      final bobApp = appFor(bob, relay, newDir());
      bobApp.listen(dmProvider, (_, _) {});
      await eventually(
        () => bobApp.read(dmProvider).conversations[alice.publicKey] != null,
      );
      await eventually(() => !bobApp.read(dmProvider).loading);
      expect(bobApp.read(dmProvider).unreadCount, 0);
    },
  );

  test('guests get no inbox', () {
    final guest = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => _FixedAuth(GuestSigner())),
        indexerRelaysProvider.overrideWithValue(const []),
        localCacheProvider.overrideWithValue(LocalCache(directory: tmp)),
        relayPoolProvider.overrideWithValue(RelayPool(const [])),
      ],
    );
    addTearDown(guest.dispose);
    expect(guest.read(dmProvider).conversations, isEmpty);
  });
}
