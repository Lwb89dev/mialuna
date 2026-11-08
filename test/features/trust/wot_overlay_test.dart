import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/theme/mialuna_theme.dart';
import 'package:mialuna/features/trust/web_of_trust_controller.dart';
import 'package:mialuna/features/trust/wot_building_overlay.dart';
import 'package:mialuna/l10n/strings.dart';

class _FixedWot extends WebOfTrustController {
  final WotState fixed;
  _FixedWot(this.fixed);

  @override
  WotState build() => fixed;
}

Future<void> _pump(WidgetTester tester, ThemeData theme, WotState state) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [webOfTrustProvider.overrideWith(() => _FixedWot(state))],
      child: MaterialApp(
        theme: theme,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const Scaffold(body: WotBuildingOverlay()),
      ),
    ),
  );
}

void main() {
  const building = WotState(
    enabled: true,
    phase: WotPhase.discovering,
    fetched: 2,
    total: 8,
  );

  for (final theme in [MialunaTheme.light(), MialunaTheme.dark()]) {
    final name = theme.brightness.name;
    testWidgets('the building card follows the $name theme', (tester) async {
      await _pump(tester, theme, building);
      expect(find.text('Building your Discover feed'), findsOneWidget);
      expect(
        find.text('Checking who your follows follow… 2 of 8'),
        findsOneWidget,
      );
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, theme.colorScheme.surface);
      expect(card.color, isNot(theme.colorScheme.primary));
    });
  }

  testWidgets('a finished network shows no card', (tester) async {
    await _pump(
      tester,
      MialunaTheme.light(),
      const WotState(enabled: true, phase: WotPhase.complete, computedAt: 1),
    );
    expect(find.byType(Card), findsNothing);
    expect(find.text('Building your Discover feed'), findsNothing);
  });
}
