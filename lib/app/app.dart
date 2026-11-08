import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/mialuna_theme.dart';
import '../features/settings/settings_controller.dart';
import '../features/social/moderation_controller.dart';
import '../features/stories/story_receipts.dart';
import '../features/trust/wot_building_overlay.dart';
import '../l10n/locale_fallback.dart';
import '../l10n/strings.dart';
import 'relay_sync.dart';
import 'router.dart';

Widget buildMialunaApp(WidgetRef ref) {
  final router = ref.watch(routerProvider);
  ref.watch(relaySyncProvider);
  ref.watch(listsSyncProvider);
  // Story receipts left over from the last session are picked up (or, if the
  // user has since said no, thrown away) as soon as the account is known.
  ref.watch(storyViewReporterProvider);
  final language = ref.watch(settingsProvider.select((s) => s.language));
  return MaterialApp.router(
    title: 'Mialuna',
    debugShowCheckedModeBanner: false,
    theme: MialunaTheme.light(),
    darkTheme: MialunaTheme.dark(),
    themeMode: ref.watch(settingsProvider.select((s) => s.themeMode)),
    // null = the phone's language; English when it is not one we translate.
    locale: language == systemLanguage ? null : Locale(language),
    localeListResolutionCallback: resolveAppLocale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    builder: (context, child) {
      // Code without a BuildContext (controllers, services) reads this.
      AppStrings.current = AppLocalizations.of(context);
      return Stack(
        fit: StackFit.expand,
        children: [
          child ?? const SizedBox.shrink(),
          const WotBuildingOverlay(),
        ],
      );
    },
    routerConfig: router,
  );
}
