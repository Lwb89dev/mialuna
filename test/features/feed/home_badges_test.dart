import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/feed/feed_screen.dart';
import 'package:mialuna/features/feed/widgets/count_badge.dart';
import 'package:mialuna/features/messages/dm_controller.dart';
import 'package:mialuna/features/notifications/notifications_controller.dart';
import 'package:mialuna/l10n/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

class _FakeDm extends DmController {
  final DmState fixed;
  _FakeDm(this.fixed);
  @override
  DmState build() => fixed;
}

class _FakeNotifications extends NotificationsController {
  final NotificationsState fixed;
  _FakeNotifications(this.fixed);
  @override
  NotificationsState build() => fixed;
}

final _peer = 'ab' * 32;

NotificationsState notifications(int count, {int seenUpTo = 0}) =>
    NotificationsState(
      seenUpTo: seenUpTo,
      items: [
        for (var i = 0; i < count; i++)
          NotificationItem(
            event: NostrEvent(
              id: '$i'.padLeft(64, '0'),
              pubkey: _peer,
              createdAt: 1700000000 + i,
              kind: NostrKinds.reaction,
              tags: const [],
              content: '+',
              sig: '',
            ),
            kind: NotificationKind.reaction,
            actor: _peer,
          ),
      ],
    );

DmState messages(int unread) => DmState(
  conversations: {
    _peer: Conversation(_peer, [
      for (var i = 0; i < unread; i++)
        DmMessage(
          id: 'm$i',
          peer: _peer,
          fromMe: false,
          createdAt: 1700000000 + i,
          text: 'ciao $i',
        ),
    ], 0),
  },
  inboxConfigured: true,
);

void main() {
  late Directory tmp;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    tmp = Directory.systemTemp.createTempSync('mialuna_badges_');
  });

  Future<void> pumpHome(
    WidgetTester tester, {
    required NotificationsState notes,
    required DmState dm,
    Signer? signer,
  }) async {
    tester.view.physicalSize = const Size(822, 1846);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          indexerRelaysProvider.overrideWithValue(const []),
          relayPoolProvider.overrideWithValue(RelayPool(const [])),
          localCacheProvider.overrideWithValue(LocalCache(directory: tmp)),
          authProvider.overrideWith(
            () => _FixedAuth(
              signer ?? NsecSigner.fromNsec(NsecSigner.generatePrivateKey()),
            ),
          ),
          dmProvider.overrideWith(() => _FakeDm(dm)),
          notificationsProvider.overrideWith(() => _FakeNotifications(notes)),
        ],
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const FeedScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// The badge on the icon of the Home bar, and its text.
  Finder badgeOn(IconData icon) =>
      find.ancestor(of: find.byIcon(icon), matching: find.byType(Badge));

  Future<void> tearDownTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 40));
  }

  testWidgets('the bell and the paper plane show how many are waiting', (
    tester,
  ) async {
    await pumpHome(tester, notes: notifications(3), dm: messages(2));

    final bell = tester.widget<Badge>(badgeOn(Icons.notifications_outlined));
    final plane = tester.widget<Badge>(badgeOn(Icons.send_outlined));
    expect(bell.isLabelVisible, true);
    expect((bell.label as Text).data, '3');
    expect(plane.isLabelVisible, true);
    expect((plane.label as Text).data, '2');

    // Spoken too, not only drawn.
    expect(find.byTooltip('3 new notifications'), findsOneWidget);
    expect(find.byTooltip('2 unread messages'), findsOneWidget);
    await tearDownTree(tester);
  });

  testWidgets('nothing waiting: no badge, plain tooltips', (tester) async {
    await pumpHome(tester, notes: notifications(0), dm: messages(0));

    expect(
      tester
          .widget<Badge>(badgeOn(Icons.notifications_outlined))
          .isLabelVisible,
      false,
    );
    expect(
      tester.widget<Badge>(badgeOn(Icons.send_outlined)).isLabelVisible,
      false,
    );
    expect(find.byTooltip('Notifications'), findsOneWidget);
    expect(find.byTooltip('Messages'), findsOneWidget);
    await tearDownTree(tester);
  });

  testWidgets('what was already seen does not count', (tester) async {
    // seenUpTo is later than every item.
    await pumpHome(
      tester,
      notes: notifications(5, seenUpTo: 1800000000),
      dm: messages(0),
    );
    expect(
      tester
          .widget<Badge>(badgeOn(Icons.notifications_outlined))
          .isLabelVisible,
      false,
    );
    await tearDownTree(tester);
  });

  testWidgets('a guest has no private messages to be told about', (
    tester,
  ) async {
    await pumpHome(
      tester,
      notes: notifications(0),
      dm: messages(4), // even if the store had something
      signer: GuestSigner(),
    );
    expect(
      tester.widget<Badge>(badgeOn(Icons.send_outlined)).isLabelVisible,
      false,
    );
    await tearDownTree(tester);
  });

  test('the number is capped at 99+', () {
    expect(CountBadge.labelFor(0), '0');
    expect(CountBadge.labelFor(99), '99');
    expect(CountBadge.labelFor(100), '99+');
    expect(CountBadge.labelFor(12345), '99+');
  });
}
