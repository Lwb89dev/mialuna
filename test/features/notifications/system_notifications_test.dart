import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/notification_routes.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/app/router.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/nip59.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/notify/system_notifier.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/messages/chat_screen.dart';
import 'package:mialuna/features/messages/dm_controller.dart';
import 'package:mialuna/features/notifications/notification_settings.dart';
import 'package:mialuna/features/notifications/notifications_controller.dart';
import 'package:mialuna/features/notifications/notifications_screen.dart';
import 'package:mialuna/features/notifications/system_notifications.dart';
import 'package:mialuna/features/social/follow_controller.dart';
import 'package:mialuna/features/social/moderation_controller.dart';
import 'package:mialuna/features/trust/web_of_trust_controller.dart';
import 'package:mialuna/l10n/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_relay.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

/// Records what would be shown on the phone.
class _FakeNotifier implements SystemNotifier {
  final List<SystemNotification> shown = [];
  bool allowed = true;
  int cancelled = 0;
  @override
  Future<bool> show(SystemNotification n) async {
    if (!allowed) return false;
    shown.add(n);
    return true;
  }

  @override
  Future<void> cancelAll() async => cancelled++;
  @override
  Future<String?> initialRoute() async => null;
  @override
  void onRoute(void Function(String route) listener) {}
}

NsecSigner newSigner() => NsecSigner.fromNsec(NsecSigner.generatePrivateKey());

/// What reaches the phone's notification shade, and what must not.
void main() {
  late FakeRelay relay;
  late NsecSigner me;
  late NsecSigner bob;
  late NsecSigner carol;
  late _FakeNotifier phone;
  late Directory dir;
  late int now;

  ProviderContainer app({bool foreground = false}) {
    final c = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => _FixedAuth(me)),
        indexerRelaysProvider.overrideWithValue(const []),
        localCacheProvider.overrideWithValue(LocalCache(directory: dir)),
        systemNotifierProvider.overrideWithValue(phone),
        appForegroundProvider.overrideWith((ref) => foreground),
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

  Future<ProviderContainer> running({bool foreground = false}) async {
    final c = app(foreground: foreground);
    c.listen(notificationsProvider, (_, _) {});
    await eventually(() => relay.reqCount >= 1);
    // The stored events are delivered, then what arrives is news.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return c;
  }

  Future<NostrEvent> reaction(Signer from, {int? at, String content = '+'}) =>
      signed(
        from,
        kind: NostrKinds.reaction,
        content: content,
        createdAt: at ?? now + 5,
        tags: [
          ['e', 'a' * 64],
          ['p', me.publicKey],
        ],
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    relay = await FakeRelay(authKinds: {1059}).start();
    me = newSigner();
    bob = newSigner();
    carol = newSigner();
    phone = _FakeNotifier();
    dir = Directory.systemTemp.createTempSync('mialuna_sysnotif_');
    now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    for (final s in [bob, carol]) {
      relay.add(
        await signed(
          s,
          kind: 0,
          content: jsonEncode({'name': s == bob ? 'bob' : 'carol'}),
        ),
      );
    }
    for (final s in [me, bob, carol]) {
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

  group('reactions, comments, zaps and followers', () {
    test('what was already waiting at start-up is not announced', () async {
      relay.add(await reaction(bob, at: now - 3600));
      relay.add(await reaction(carol, at: now - 1800));
      final c = await running();
      await eventually(() => c.read(notificationsProvider).items.length == 2);
      expect(phone.shown, isEmpty);
    });

    test('news arriving while the app is in the background is', () async {
      final c = await running();
      relay.push(await reaction(bob));
      await eventually(() => phone.shown.isNotEmpty);

      final n = phone.shown.single;
      expect(n.channel, NotifyChannel.social);
      expect(n.title, 'bob');
      expect(n.body, AppStrings.current.reactedToYourMoment);
      expect(n.route, 'notifications');
      // The badge in Home counts it too.
      expect(c.read(notificationsProvider).unreadCount, 1);
      // The lock screen only says that something came.
      expect(n.publicTitle, 'Mialuna');
      expect(n.publicBody, isNot(contains('bob')));
    });

    test('a comment says what it says', () async {
      await running();
      relay.push(
        await signed(
          bob,
          kind: NostrKinds.comment,
          content: 'che bel tramonto',
          createdAt: now + 5,
          tags: [
            ['E', 'a' * 64],
            ['p', me.publicKey],
          ],
        ),
      );
      await eventually(() => phone.shown.isNotEmpty);
      expect(phone.shown.single.body, contains('che bel tramonto'));
    });

    test('with the app in front of the user, the badge is enough', () async {
      final c = await running(foreground: true);
      relay.push(await reaction(bob));
      await eventually(() => c.read(notificationsProvider).unreadCount == 1);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(phone.shown, isEmpty);
    });

    test('the user can turn them off', () async {
      final c = await running();
      await c.read(systemNotificationsSettingProvider.notifier).set(false);
      relay.push(await reaction(bob));
      await eventually(() => c.read(notificationsProvider).unreadCount == 1);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(phone.shown, isEmpty);
    });

    test(
      'nothing for dislikes, your own actions, or people you blocked',
      () async {
        final c = await running();
        await c.read(blockProvider.notifier).block(carol.publicKey);
        relay.push(await reaction(bob, content: '-'));
        relay.push(await reaction(me));
        relay.push(await reaction(carol));
        // Once Bob's real one shows, the others were already dealt with.
        relay.push(await reaction(bob, at: now + 9));
        await eventually(() => phone.shown.isNotEmpty);
        await Future<void>.delayed(const Duration(milliseconds: 300));
        expect(phone.shown, hasLength(1));
        expect(phone.shown.single.title, 'bob');
      },
    );

    test('with the web of trust on, strangers do not ring the phone', () async {
      final friend = newSigner();
      relay.add(
        await signed(
          me,
          kind: NostrKinds.followList,
          tags: [
            ['p', friend.publicKey],
          ],
        ),
      );
      relay.add(
        await signed(
          friend,
          kind: NostrKinds.followList,
          tags: [
            ['p', bob.publicKey],
          ],
        ),
      );
      final c = app();
      c.listen(notificationsProvider, (_, _) {});
      c.listen(followListProvider, (_, _) {});
      await c.read(webOfTrustProvider.notifier).setEnabled(true);
      await eventually(() => relay.reqCount >= 3);
      await Future<void>.delayed(const Duration(milliseconds: 700));

      relay.push(await reaction(carol)); // a stranger
      relay.push(
        await signed(
          carol,
          kind: NostrKinds.followList,
          createdAt: now + 6,
          tags: [
            ['p', me.publicKey],
          ],
        ),
      ); // a new follower: still news
      await eventually(() => phone.shown.isNotEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(phone.shown, hasLength(1));
      expect(phone.shown.single.body, AppStrings.current.startedFollowingYou);
    });

    test('a flood becomes one notification that counts', () async {
      await running();
      for (var i = 0; i < 9; i++) {
        final s = newSigner();
        relay.push(await reaction(s, at: now + 5 + i));
      }
      await eventually(
        () => phone.shown.length >= 9,
        timeout: const Duration(seconds: 15),
      );

      final single = phone.shown.where((n) => n.id < 0x7ffffff0).toList();
      final summaries = phone.shown.where((n) => n.id >= 0x7ffffff0).toList();
      expect(single, hasLength(SystemNotifications.perMinute));
      expect(summaries, isNotEmpty);
      expect(
        summaries.map((n) => n.id).toSet(),
        hasLength(1),
        reason: 'one summary, replaced as it grows',
      );
      expect(summaries.last.body, AppStrings.current.notificationsNew(9));
    });
  });

  group('new followers', () {
    Future<NostrEvent> follow(Signer from) => signed(
      from,
      kind: NostrKinds.followList,
      createdAt: now + 5,
      tags: [
        ['p', me.publicKey],
      ],
    );

    List<NotificationKind> kinds(ProviderContainer c) => [
      for (final n in c.read(notificationsProvider).items) n.kind,
    ];

    test('are shown, counted and announced by default', () async {
      final c = await running();
      expect(c.read(newFollowersNotificationsProvider), true);
      relay.push(await follow(bob));
      await eventually(() => phone.shown.isNotEmpty);
      expect(kinds(c), [NotificationKind.follow]);
      expect(c.read(notificationsProvider).unreadCount, 1);
      expect(phone.shown.single.body, AppStrings.current.startedFollowingYou);
    });

    test('switched off: not listed, not counted, not on the phone', () async {
      final c = await running();
      await c.read(newFollowersNotificationsProvider.notifier).set(false);
      relay.push(await follow(bob));
      relay.push(await follow(carol));
      // A like still comes through: once it is here, the follows were seen.
      relay.push(await reaction(bob, at: now + 9));
      await eventually(() => phone.shown.isNotEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(kinds(c), [NotificationKind.reaction]);
      expect(c.read(notificationsProvider).unreadCount, 1);
      expect(phone.shown, hasLength(1));
      expect(phone.shown.single.body, AppStrings.current.reactedToYourMoment);
    });

    test(
      'switched off after they arrived, they go; back on, they return',
      () async {
        final c = await running();
        relay.push(await follow(bob));
        await eventually(() => kinds(c).contains(NotificationKind.follow));

        await c.read(newFollowersNotificationsProvider.notifier).set(false);
        await eventually(() => kinds(c).isEmpty);
        expect(c.read(notificationsProvider).unreadCount, 0);

        await c.read(newFollowersNotificationsProvider.notifier).set(true);
        await eventually(() => kinds(c).contains(NotificationKind.follow));
      },
    );

    test('the choice is remembered', () async {
      final c = app();
      await c.read(newFollowersNotificationsProvider.notifier).set(false);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('mialuna_notify_new_followers'), false);

      final again = app();
      again.read(newFollowersNotificationsProvider);
      await eventually(
        () => again.read(newFollowersNotificationsProvider) == false,
      );
    });
  });

  group('private messages', () {
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

    Future<ProviderContainer> inboxReady({bool foreground = false}) async {
      final c = app(foreground: foreground);
      c.listen(dmProvider, (_, _) {});
      await eventually(() {
        final s = c.read(dmProvider);
        return !s.loading && s.inboxConfigured == true;
      });
      return c;
    }

    test('a new message rings the phone without its text or its sender on the lock screen', () async {
      await inboxReady();
      relay.push(await dm(bob, 'la password del wifi è luna1234', now + 5));
      await eventually(() => phone.shown.isNotEmpty);

      final n = phone.shown.single;
      expect(n.channel, NotifyChannel.messages);
      expect(n.title, 'bob');
      expect(n.route, 'chat:${bob.publicKey}');
      expect(n.body, AppStrings.current.systemNotificationMessage);
      for (final text in [n.title, n.body, n.publicTitle, n.publicBody]) {
        expect(text, isNot(contains('wifi')));
      }
      expect(n.publicTitle, 'Mialuna');
      expect(n.publicBody, AppStrings.current.systemNotificationNewMessage);
      expect(n.publicTitle, isNot(contains('bob')));
    });

    test(
      'one notification per conversation, replaced by the next message',
      () async {
        await inboxReady();
        relay.push(await dm(bob, 'uno', now + 5));
        await eventually(() => phone.shown.length == 1);
        relay.push(await dm(bob, 'due', now + 6));
        await eventually(() => phone.shown.length == 2);
        expect(phone.shown.first.id, phone.shown.last.id);
      },
    );

    test(
      'old messages, your own, and messages you already read are not announced',
      () async {
        relay.add(await dm(bob, 'vecchio', now - 3600));
        final c = await inboxReady();
        await eventually(() => c.read(dmProvider).conversations.isNotEmpty);
        // Your own message in another conversation.
        relay.push(
          await GiftWrap.wrap(
            signer: me,
            rumor: Rumor.create(
              pubkey: me.publicKey,
              kind: NostrKinds.chatMessage,
              tags: [
                ['p', carol.publicKey],
              ],
              content: 'ciao Carol',
              createdAt: now + 5,
            ),
            recipient: me.publicKey,
          ),
        );
        relay.push(await dm(carol, 'ehi', now + 6)); // the one that counts
        await eventually(() => phone.shown.isNotEmpty);
        await Future<void>.delayed(const Duration(milliseconds: 300));
        expect(phone.shown, hasLength(1));
        expect(phone.shown.single.title, 'carol');
      },
    );

    test('a stranger\'s message waits as a request, silently', () async {
      final friend = newSigner();
      relay.add(
        await signed(
          me,
          kind: NostrKinds.followList,
          tags: [
            ['p', friend.publicKey],
          ],
        ),
      );
      relay.add(
        await signed(
          friend,
          kind: NostrKinds.followList,
          tags: [
            ['p', carol.publicKey],
          ],
        ),
      );
      final c = app();
      c.listen(dmProvider, (_, _) {});
      c.listen(followListProvider, (_, _) {});
      await c.read(webOfTrustProvider.notifier).setEnabled(true);
      await eventually(() {
        final s = c.read(dmProvider);
        return !s.loading && s.inboxConfigured == true;
      });
      relay.push(await dm(bob, 'airdrop!!!', now + 5)); // a stranger
      await eventually(() => c.read(dmProvider).requests.isNotEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(phone.shown, isEmpty);
    });

    test(
      'with the app in front, nothing (the paper plane has the number)',
      () async {
        final c = await inboxReady(foreground: true);
        relay.push(await dm(bob, 'ciao', now + 5));
        await eventually(() => c.read(dmProvider).unreadCount == 1);
        expect(phone.shown, isEmpty);
      },
    );
  });

  group('tapping one', () {
    testWidgets('opens the screen it is about', (tester) async {
      late WidgetRef captured;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => _FixedAuth(me)),
            indexerRelaysProvider.overrideWithValue(const []),
            relayPoolProvider.overrideWithValue(RelayPool(const [])),
            localCacheProvider.overrideWithValue(LocalCache(directory: dir)),
          ],
          child: MaterialApp(
            navigatorKey: rootNavigatorKey,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Consumer(
              builder: (context, ref, _) {
                captured = ref;
                return const Scaffold(body: Text('home'));
              },
            ),
          ),
        ),
      );
      openNotificationRoute(captured, 'notifications');
      await tester.pumpAndSettle();
      expect(find.byType(NotificationsScreen), findsOneWidget);
      rootNavigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      openNotificationRoute(captured, 'chat:${bob.publicKey}');
      await tester.pumpAndSettle();
      expect(find.byType(ChatScreen), findsOneWidget);
      rootNavigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      // Garbage, or a key that is not one, opens nothing.
      openNotificationRoute(captured, 'chat:nonsense');
      openNotificationRoute(captured, 'somewhere/else');
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('home'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 40));
    });
  });

  test('showing them is on unless the user says otherwise', () async {
    final c = app();
    expect(c.read(systemNotificationsSettingProvider), true);
    await c.read(systemNotificationsSettingProvider.notifier).set(false);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('mialuna_system_notifications'), false);
  });
}
