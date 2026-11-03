import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/features/feed/widgets/post_card.dart';
import 'package:mialuna/l10n/strings.dart';

/// "2 min ago" must not stay "2 min ago" while the post is on screen.
void main() {
  testWidgets('the label keeps up with the clock', (tester) async {
    var now = 1700000000;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [unixClockProvider.overrideWithValue(() => now)],
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) {
            AppStrings.current = AppLocalizations.of(context);
            return child!;
          },
          home: Scaffold(body: PostTime(createdAt: now - 130)),
        ),
      ),
    );
    final l10n = AppStrings.current;
    expect(find.text(l10n.minutesAgo(2)), findsOneWidget);

    now += 5 * 60;
    await tester.pump(const Duration(seconds: 31));
    expect(find.text(l10n.minutesAgo(7)), findsOneWidget);

    now += 2 * 3600;
    await tester.pump(const Duration(seconds: 31));
    expect(find.text(l10n.hoursAgo(2)), findsOneWidget);
  });

  test('formatPostTime can be given the time it is now', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    AppStrings.current = l10n;
    expect(formatPostTime(1000, nowSeconds: 1030), l10n.now);
    expect(formatPostTime(1000, nowSeconds: 1000 + 3 * 60), l10n.minutesAgo(3));
    expect(formatPostTime(1000, nowSeconds: 1000 + 25 * 3600), l10n.daysAgo(1));
  });
}
