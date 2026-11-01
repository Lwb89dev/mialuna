import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

/// `context.l10n.someKey` — the strings of the language the user chose.
extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Strings for code that has no [BuildContext] (controllers, services,
/// exceptions). The app root keeps [current] in step with the active locale,
/// so a message produced here is in the language the user is reading.
class AppStrings {
  AppStrings._();

  static AppLocalizations current = lookupAppLocalizations(const Locale('en'));

  static void use(Locale locale) {
    current = lookupAppLocalizations(locale);
  }
}
