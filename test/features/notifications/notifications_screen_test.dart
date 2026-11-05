import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/event_store.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/feed/widgets/nostr_image.dart';
import 'package:mialuna/features/feed/widgets/post_card.dart';
import 'package:mialuna/features/notifications/notifications_controller.dart';
import 'package:mialuna/features/notifications/notifications_screen.dart';
import 'package:mialuna/l10n/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_relay.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);

  @override
  AuthState build() => AuthState(signer);
}

class _FakeNotifications extends NotificationsController {
  final NotificationsState fixed;
  _FakeNotifications(this.fixed);

  @override
  NotificationsState build() => fixed;
}

void main() {
  late FakeRelay relay;
  late NsecSigner me;
  late NsecSigner bob;
  late Directory dir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    relay = await FakeRelay().start();
    me = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
    bob = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
    dir = Directory.systemTemp.createTempSync('mialuna_notification_screen_');
  });

  tearDown(() => relay.stop());

  testWidgets('a moment notification shows its thumbnail and opens the post', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 1136);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final post = await signed(
      me,
      createdAt: now - 3600,
      tags: [
        ['imeta', 'url https://cdn.example.com/moment.jpg', 'm image/jpeg'],
      ],
    );
    relay.add(post);
    final comment = await signed(
      bob,
      kind: NostrKinds.comment,
      content: 'bella!',
      createdAt: now,
      tags: [
        ['E', post.id],
        ['p', me.publicKey],
      ],
    );
    final item = NotificationItem(
      event: comment,
      kind: NotificationKind.comment,
      actor: bob.publicKey,
      isNew: false,
    );
    late ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => _FixedAuth(me)),
          indexerRelaysProvider.overrideWithValue(const []),
          eventStoreProvider.overrideWithValue(EventStore()..add(post)),
          localCacheProvider.overrideWithValue(LocalCache(directory: dir)),
          relayPoolProvider.overrideWith((ref) {
            final pool = RelayPool([RelayConfig(relay.url)]);
            ref.onDispose(pool.dispose);
            return pool;
          }),
          notificationsProvider.overrideWith(
            () => _FakeNotifications(
              NotificationsState(items: [item], seenUpTo: now),
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Consumer(
            builder: (context, ref, _) {
              container = ProviderScope.containerOf(context);
              return const NotificationsScreen();
            },
          ),
        ),
      ),
    );
    await tester.pump();
    for (
      var i = 0;
      i < 50 && !container.read(notificationPostProvider(post.id)).hasValue;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump();

    expect(find.byType(NostrImage), findsOneWidget);
    expect(tester.getSize(find.byType(ClipRRect)), const Size(48, 48));
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(ListTile));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(PostScreen), findsOneWidget);
    expect(find.byType(PostCard), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 40));
  });
}
