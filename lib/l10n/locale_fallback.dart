import 'package:flutter/widgets.dart';

/// The phone's language when the app is translated into it, English otherwise.
///
/// [basicLocaleListResolution] returns the first supported locale when nothing
/// matches. That first locale is not English.
Locale resolveAppLocale(List<Locale>? preferred, Iterable<Locale> supported) {
  final match = basicLocaleListResolution(preferred, supported);
  final codes = <String>{
    for (final locale in preferred ?? const <Locale>[]) locale.languageCode,
  };
  if (codes.contains(match.languageCode)) return match;
  return const Locale('en');
}
