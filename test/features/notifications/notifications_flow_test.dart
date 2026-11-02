import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/notifications/notifications_controller.dart';
import 'package:mialuna/features/social/moderation_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_relay.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

NsecSigner _newSigner() => NsecSigner.fromNsec(NsecSigner.generatePrivateKey());

void main() {
  late FakeRelay relay;
  late NsecSigner me;
  late NsecSigner bob;
  late NsecSigner carol;
  late Directory dir; // survives an "app restart" inside one test
  late int now;

  ProviderContainer app() {
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => _FixedAuth(me)),
        indexerRelaysProvider.overrideWithValue(const []),
        localCacheProvider.overrideWithValue(LocalCache(directory: dir)),
        relayPoolProvider.overrideWith((ref) {
          final pool = RelayPool([RelayConfig(relay.url)]);
          ref.onDispose(pool.dispose);
          return pool;
        }),
      ],
    );
    addTearDown(container.dispose);
    container.listen(notificationsProvider, (_, _) {});
    return container;
  }

  NotificationsState read(ProviderContainer c) => c.read(notificationsProvider);

  Future<NostrEvent> reaction(Signer from, {int? at, String content = '+'}) =>
      signed(
        from,
        kind: NostrKinds.reaction,
        content: content,
        createdAt: at ?? now,
        tags: [
          ['e', 'a' * 64],
          ['p', me.publicKey],
        ],
      );

  Future<NostrEvent> comment(Signer from, String text, {int? at}) => signed(
    from,
    kind: NostrKinds.comment,
    content: text,
    createdAt: at ?? now,
    tags: [
      ['E', 'a' * 64],
      ['p', me.publicKey],
    ],
  );

  Future<NostrEvent> follows(Signer from, {int? at, String? also}) => signed(
    from,
    kind: NostrKinds.followList,
    createdAt: at ?? now,
    tags: [
      ['p', me.publicKey],
      if (also != null) ['p', also],
    ],
  );

  /// Waits until the controller has subscribed (history delivered).
  Future<void> ready(ProviderContainer c, {int items = 0}) async {
    await eventually(() => relay.reqCount >= 1, reason: 'never subscribed');
    await eventually(
      () => read(c).items.length >= items && read(c).seenUpTo > 0,
      reason: 'history never arrived',
    );
    // The first-run bookkeeping runs a moment after the end of the stored events.
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    relay = await FakeRelay().start();
    me = _newSigner();
    bob = _newSigner();
    carol = _newSigner();
    dir = Directory.systemTemp.createTempSync('mialuna_notif_');
    now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  });

  tearDown(() => relay.stop());

  test('on first use everything already there counts as seen', () async {
    relay.add(await reaction(bob, at: now - 3600));
    relay.add(await comment(carol, 'bella!', at: now - 1800));
    relay.add(await follows(bob, at: now - 7200));

    final c = app();
    await ready(c, items: 3);

    expect(read(c).items, hasLength(3));
    expect(read(c).unreadCount, 0);
    expect(read(c).items.map((n) => n.kind), [
      NotificationKind.comment,
      NotificationKind.reaction,
      NotificationKind.follow,
    ], reason: 'newest first');
  });

  test('news raise the count; dislikes and your own actions do not', () async {
    final c = app();
    await ready(c);
    expect(read(c).unreadCount, 0);

    relay.push(await reaction(bob, at: now + 5));
    relay.push(await comment(carol, 'ciao', at: now + 6));
    await eventually(() => read(c).unreadCount == 2);

    relay.push(await reaction(carol, at: now + 7, content: '-'));
    relay.push(await reaction(me, at: now + 8));
    // Both are dropped; wait for a later one to be sure they were handled.
    relay.push(await reaction(carol, at: now + 9));
    await eventually(() => read(c).unreadCount == 3);
    expect(read(c).items, hasLength(3));
  });

  test('opening the screen clears the count, and it stays cleared', () async {
    final c = app();
    await ready(c);
    relay.push(await reaction(bob, at: now + 5));
    await eventually(() => read(c).unreadCount == 1);

    c.read(notificationsProvider.notifier).markAllSeen();
    expect(read(c).unreadCount, 0);
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // The app is closed and opened again: the relay still has the reaction.
    final again = app();
    await ready(again, items: 1);
    expect(read(again).items, hasLength(1));
    expect(read(again).unreadCount, 0, reason: 'it had been seen already');

    relay.push(await reaction(carol, at: now + 20));
    await eventually(() => read(again).unreadCount == 1);
  });

  test('a follower who updates their list is not a new follower', () async {
    relay.add(await follows(bob, at: now - 7200));
    final c = app();
    await ready(c, items: 1);

    // Bob follows somebody else: his follow list is republished.
    relay.push(await follows(bob, at: now + 5, also: carol.publicKey));
    // Carol really does follow us now.
    relay.push(await follows(carol, at: now + 6));
    await eventually(() => read(c).items.length == 2);

    expect(read(c).items.map((n) => n.actor).toSet(), {
      bob.publicKey,
      carol.publicKey,
    }, reason: 'one entry per follower');
    expect(read(c).unreadCount, 1, reason: 'only Carol is new');
  });

  test('someone you block disappears from the list and the count', () async {
    final c = app();
    await ready(c);
    relay.push(await reaction(bob, at: now + 5));
    relay.push(await comment(carol, 'ciao', at: now + 6));
    await eventually(() => read(c).unreadCount == 2);

    await c.read(blockProvider.notifier).block(carol.publicKey);
    await eventually(() => read(c).unreadCount == 1);
    expect(read(c).items.single.actor, bob.publicKey);
  });

  test('a zap is about the person who paid, not the wallet service', () async {
    final wallet = _newSigner();
    final request = await signed(
      bob,
      kind: NostrKinds.zapRequest,
      content: 'grazie',
      tags: [
        ['p', me.publicKey],
        ['amount', '21000'],
      ],
    );
    relay.add(
      await signed(
        wallet,
        kind: NostrKinds.zapReceipt,
        createdAt: now - 60,
        tags: [
          ['p', me.publicKey],
          ['description', jsonEncode(request.toJson())],
        ],
      ),
    );
    final c = app();
    await ready(c, items: 1);

    final zap = read(c).items.single;
    expect(zap.kind, NotificationKind.zap);
    expect(zap.actor, bob.publicKey);
    expect(zap.zap!.amountSats, 21);

    await c.read(blockProvider.notifier).block(bob.publicKey);
    await eventually(() => read(c).items.isEmpty);
  });

  test('a forged zap is not announced as somebody\'s', () async {
    final wallet = _newSigner();
    // Bob's name on a request Bob never signed.
    final forged = {
      'id': 'a' * 64,
      'pubkey': bob.publicKey,
      'created_at': now,
      'kind': NostrKinds.zapRequest,
      'tags': [
        ['p', me.publicKey],
        ['amount', '999000000'],
      ],
      'content': 'sono io',
      'sig': 'b' * 128,
    };
    relay.add(
      await signed(
        wallet,
        kind: NostrKinds.zapReceipt,
        createdAt: now - 60,
        tags: [
          ['p', me.publicKey],
          ['description', jsonEncode(forged)],
        ],
      ),
    );
    final c = app();
    await ready(c, items: 1);
    final item = read(c).items.single;
    expect(item.zap, isNull, reason: 'no amount, no sender is believed');
    expect(item.actor, wallet.publicKey, reason: 'the wallet service, not Bob');
  });
}
