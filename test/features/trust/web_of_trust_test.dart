import 'dart:io';

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
import 'package:mialuna/features/notifications/notifications_controller.dart';
import 'package:mialuna/features/private/private_posts.dart';
import 'package:mialuna/features/social/follow_controller.dart';
import 'package:mialuna/features/social/interactions_controller.dart';
import 'package:mialuna/features/trust/web_of_trust_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_relay.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

NsecSigner newSigner() => NsecSigner.fromNsec(NsecSigner.generatePrivateKey());

/// Web of trust: you follow 12 people. Everybody of them follows `target`
/// (12 ≥ 10: trusted), 5 of them follow `weak` (not enough). `stranger`
/// follows nobody and nobody follows them.
void main() {
  late FakeRelay relay;
  late NsecSigner me;
  late List<NsecSigner> follows;
  late NsecSigner target;
  late NsecSigner weak;
  late NsecSigner stranger;
  late Directory dir;

  ProviderContainer app({Directory? cacheDir}) {
    final c = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => _FixedAuth(me)),
        indexerRelaysProvider.overrideWithValue(const []),
        localCacheProvider.overrideWithValue(
          LocalCache(directory: cacheDir ?? dir),
        ),
        relayPoolProvider.overrideWith((ref) {
          final pool = RelayPool([RelayConfig(relay.url)]);
          pool.authSigner = (url, challenge) => me.signEvent(
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
    addTearDown(c.dispose);
    return c;
  }

  Future<NostrEvent> kind3(Signer s, List<String> pubkeys) => signed(
    s,
    kind: NostrKinds.followList,
    tags: [
      for (final p in pubkeys) ['p', p],
    ],
  );

  Future<ProviderContainer> trustedApp() async {
    final c = app();
    c.listen(webOfTrustProvider, (_, _) {});
    c.listen(followListProvider, (_, _) {});
    await c.read(webOfTrustProvider.notifier).setEnabled(true);
    expect(c.read(webOfTrustProvider).filtering, true);
    return c;
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    relay = await FakeRelay(authKinds: {1059}).start();
    me = newSigner();
    follows = [for (var i = 0; i < 12; i++) newSigner()];
    target = newSigner();
    weak = newSigner();
    stranger = newSigner();
    dir = Directory.systemTemp.createTempSync('mialuna_wot_');
    relay.add(await kind3(me, [for (final f in follows) f.publicKey]));
    for (var i = 0; i < follows.length; i++) {
      relay.add(
        await kind3(follows[i], [target.publicKey, if (i < 5) weak.publicKey]),
      );
    }
  });

  tearDown(() => relay.stop());

  group('the network', () {
    test('is off by default: everybody passes', () async {
      final c = app();
      c.listen(webOfTrustProvider, (_, _) {});
      expect(c.read(trustFilterProvider).allows(stranger.publicKey), true);
      expect(c.read(webOfTrustProvider).enabled, false);
    });

    test(
      'turning it on builds it: your follows and whoever 10 of them follow',
      () async {
        final c = await trustedApp();
        final wot = c.read(webOfTrustProvider);
        expect(wot.phase, WotPhase.complete);
        expect(wot.directCount, 12);
        expect(wot.qualified, {target.publicKey});

        final trust = c.read(trustFilterProvider);
        expect(trust.active, true);
        expect(trust.allows(me.publicKey), true, reason: 'you');
        expect(trust.allows(follows.first.publicKey), true, reason: 'followed');
        expect(
          trust.allows(target.publicKey),
          true,
          reason: '12 of your follows',
        );
        expect(trust.allows(weak.publicKey), false, reason: 'only 5 of them');
        expect(trust.allows(stranger.publicKey), false);
      },
    );

    test('on, but never computed: nothing is hidden meanwhile', () async {
      relay.stored.clear(); // no follow list anywhere: nothing can be built
      await LocalCache(directory: dir).writeJson('wot_${me.publicKey}.json', {
        'enabled': true,
        'at': 0,
        'q': <String>[],
      });
      final c = app();
      c.listen(webOfTrustProvider, (_, _) {});
      await eventually(() => c.read(webOfTrustProvider).enabled);
      expect(c.read(webOfTrustProvider).filtering, false);
      expect(c.read(trustFilterProvider).allows(stranger.publicKey), true);
    });

    test(
      'follows nobody: says why instead of silently hiding everyone',
      () async {
        relay.stored.clear();
        final c = app();
        c.listen(webOfTrustProvider, (_, _) {});
        c.listen(followListProvider, (_, _) {});
        await c.read(webOfTrustProvider.notifier).setEnabled(true);
        final wot = c.read(webOfTrustProvider);
        expect(wot.phase, WotPhase.failed);
        expect(wot.error, isNotEmpty);
        expect(wot.filtering, false);
      },
    );

    test(
      'is remembered per account, and works with no network at all',
      () async {
        await trustedApp();
        await Future<void>.delayed(const Duration(milliseconds: 300));

        relay.silent = true;
        final again = app();
        again.listen(webOfTrustProvider, (_, _) {});
        again.listen(followListProvider, (_, _) {});
        await eventually(() => again.read(webOfTrustProvider).filtering);
        expect(again.read(webOfTrustProvider).qualified, {target.publicKey});
        expect(again.read(trustFilterProvider).allows(target.publicKey), true);
      },
    );

    test('a person you follow stays trusted when the network is old', () async {
      final c = await trustedApp();
      final newFriend = newSigner();
      // Following somebody takes effect at once, without recomputing.
      expect(c.read(trustFilterProvider).allows(newFriend.publicKey), false);
      relay.push(
        await signed(
          me,
          kind: NostrKinds.followList,
          createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 5,
          tags: [
            for (final f in follows) ['p', f.publicKey],
            ['p', newFriend.publicKey],
          ],
        ),
      );
      await eventually(
        () => c.read(trustFilterProvider).allows(newFriend.publicKey),
      );
    });
  });

  group('what it filters', () {
    test(
      'notifications: reactions and comments from strangers, not from friends',
      () async {
        final c = await trustedApp();
        c.listen(notificationsProvider, (_, _) {});
        await eventually(() => relay.reqCount >= 1);
        await Future<void>.delayed(const Duration(milliseconds: 600));

        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        Future<NostrEvent> comment(Signer from, String text, int at) => signed(
          from,
          kind: NostrKinds.comment,
          content: text,
          createdAt: at,
          tags: [
            ['E', 'a' * 64],
            ['p', me.publicKey],
          ],
        );
        relay.push(await comment(stranger, 'buy my coin', now + 5));
        relay.push(await comment(follows.first, 'bella!', now + 6));
        relay.push(await comment(target, 'ciao', now + 7));

        await eventually(
          () => c.read(notificationsProvider).items.length == 2,
          reason: 'the friends\' comments never arrived',
        );
        final authors = c.read(notificationsProvider).items.map((n) => n.actor);
        expect(
          authors,
          containsAll([follows.first.publicKey, target.publicKey]),
        );
        expect(authors, isNot(contains(stranger.publicKey)));
      },
    );

    test('notifications: a new follower is shown even if a stranger', () async {
      final c = await trustedApp();
      c.listen(notificationsProvider, (_, _) {});
      await eventually(() => relay.reqCount >= 1);
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      relay.push(
        await signed(
          stranger,
          kind: NostrKinds.followList,
          createdAt: now + 5,
          tags: [
            ['p', me.publicKey],
          ],
        ),
      );
      await eventually(() => c.read(notificationsProvider).items.isNotEmpty);
      expect(
        c.read(notificationsProvider).items.single.kind,
        NotificationKind.follow,
      );
    });

    Future<NostrEvent> dm(Signer from, String text, int at) => GiftWrap.wrap(
      signer: from,
      rumor: Rumor.create(
        pubkey: from.publicKey!,
        kind: NostrKinds.chatMessage,
        tags: [
          ['p', me.publicKey],
        ],
        content: text,
        createdAt: at,
      ),
      recipient: me.publicKey,
    );

    test(
      'messages from strangers wait as requests and are not counted unread',
      () async {
        relay.add(
          await signed(
            me,
            kind: NostrKinds.dmRelayList,
            tags: [
              ['relay', relay.url],
            ],
          ),
        );
        final c = await trustedApp();
        c.listen(dmProvider, (_, _) {});
        await eventually(() {
          final s = c.read(dmProvider);
          return !s.loading && s.inboxConfigured == true;
        });

        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        relay.push(await dm(stranger, 'airdrop!!!', now + 5));
        relay.push(await dm(follows.first, 'ciao', now + 6));
        await eventually(() => c.read(dmProvider).conversations.length == 2);

        final state = c.read(dmProvider);
        expect(state.sorted.map((x) => x.peer), [follows.first.publicKey]);
        expect(state.requests.map((x) => x.peer), [stranger.publicKey]);
        expect(state.unreadCount, 1, reason: 'only the friend\'s message');
      },
    );

    test('answering a request makes it a normal conversation', () async {
      relay.add(
        await signed(
          me,
          kind: NostrKinds.dmRelayList,
          tags: [
            ['relay', relay.url],
          ],
        ),
      );
      relay.add(
        await signed(
          stranger,
          kind: NostrKinds.dmRelayList,
          tags: [
            ['relay', relay.url],
          ],
        ),
      );
      final c = await trustedApp();
      c.listen(dmProvider, (_, _) {});
      await eventually(() {
        final s = c.read(dmProvider);
        return !s.loading && s.inboxConfigured == true;
      });
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      relay.push(await dm(stranger, 'hello', now + 5));
      await eventually(() => c.read(dmProvider).requests.isNotEmpty);

      await c.read(dmProvider.notifier).send(stranger.publicKey, 'chi sei?');
      expect(c.read(dmProvider).requests, isEmpty);
      expect(c.read(dmProvider).sorted.single.peer, stranger.publicKey);
    });

    test(
      'private posts from strangers stay out of Home and the rail',
      () async {
        final c = await trustedApp();
        c.listen(privatePostsProvider, (_, _) {});
        Rumor privatePost(Signer from, String text) => Rumor.create(
          pubkey: from.publicKey!,
          kind: NostrKinds.picture,
          createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          content: text,
          tags: [
            [
              'imeta',
              'url https://cdn.example.com/${text.hashCode.abs()}.jpg',
              'm image/jpeg',
            ],
            ['audience', 'close-friends'],
            ['p', me.publicKey],
          ],
        );
        final notifier = c.read(privatePostsProvider.notifier);
        expect(notifier.ingest(privatePost(stranger, 'spam')), true);
        expect(notifier.ingest(privatePost(follows.first, 'amici')), true);

        expect(c.read(privatePostsProvider).posts.map((p) => p.caption), [
          'amici',
        ]);

        // Turn the filter off and the stranger's post is there after all.
        await c.read(webOfTrustProvider.notifier).setEnabled(false);
        await eventually(() => c.read(privatePostsProvider).posts.length == 2);
      },
    );

    test('comments: strangers are filtered, likes are still counted', () async {
      final c = await trustedApp();
      final repo = InteractionsRepository(c.read(relayPoolProvider));
      addTearDown(repo.dispose);
      final trust = c.read(trustFilterProvider);
      repo.request('p' * 64);
      Future<NostrEvent> commentBy(Signer s, String text) => signed(
        s,
        kind: NostrKinds.comment,
        content: text,
        tags: [
          ['E', 'p' * 64],
          ['K', '20'],
          ['P', follows.first.publicKey],
          ['e', 'p' * 64],
          ['k', '20'],
          ['p', follows.first.publicKey],
        ],
      );
      repo.ingest(await commentBy(stranger, 'spam'), ['p' * 64]);
      repo.ingest(await commentBy(follows[1], 'bello'), ['p' * 64]);
      repo.ingest(
        await signed(
          stranger,
          kind: NostrKinds.reaction,
          content: '+',
          tags: [
            ['e', 'p' * 64],
          ],
        ),
      );

      final shown = repo.snapshot('p' * 64, allowCommenter: trust.allows);
      expect(shown.comments.map((x) => x.text), ['bello']);
      expect(shown.likeCount, 1);
      expect(repo.snapshot('p' * 64).comments, hasLength(2));
    });
  });
}
