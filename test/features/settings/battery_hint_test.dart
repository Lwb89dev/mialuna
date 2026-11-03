import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/notify/system_notifier.dart';
import 'package:mialuna/features/settings/system_notifications_tile.dart';
import 'package:mialuna/l10n/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Phone implements SystemNotifier {
  bool restricted = true;
  int opened = 0;
  @override
  Future<bool> batteryRestricted() async => restricted;
  @override
  Future<void> openBatterySettings() async => opened++;
  @override
  Future<bool> show(SystemNotification n) async => true;
  @override
  Future<void> cancelAll() async {}
  @override
  Future<String?> initialRoute() async => null;
  @override
  void onRoute(void Function(String route) listener) {}
}

/// Notifications stop when Android puts the app to sleep (a few minutes after
/// the screen goes off): found on a phone, where a notification sent after two
/// minutes arrived only once the app was taken out of battery optimisation.
/// Settings says so, and points at the place where it is changed.
void main() {
  late _Phone phone;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    phone = _Phone();
  });

  Future<ProviderContainer> pump(WidgetTester tester) async {
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [systemNotifierProvider.overrideWithValue(phone)],
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return MaterialApp(
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: const Scaffold(body: SystemNotificationsTile()),
            );
          },
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    return container;
  }

  Finder hint() => find.byIcon(Icons.battery_alert_outlined);

  testWidgets(
    'a phone that may put the app to sleep says so, and offers the way out',
    (tester) async {
      await pump(tester);
      expect(hint(), findsOneWidget);
      await tester.tap(find.byType(TextButton));
      expect(phone.opened, 1);
    },
  );

  testWidgets('nothing to say when the app is already left alone', (
    tester,
  ) async {
    phone.restricted = false;
    await pump(tester);
    expect(hint(), findsNothing);
  });

  testWidgets('and nothing while notifications are off', (tester) async {
    await pump(tester);
    await tester.tap(find.byType(Switch));
    await tester.pump(const Duration(milliseconds: 100));
    expect(hint(), findsNothing);
  });

  testWidgets('back from the phone\'s settings it asks again', (tester) async {
    final c = await pump(tester);
    expect(hint(), findsOneWidget);

    phone.restricted = false; // the user changed it
    c.read(appForegroundProvider.notifier).state = false;
    await tester.pump();
    c.read(appForegroundProvider.notifier).state = true;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(hint(), findsNothing);
  });
}
