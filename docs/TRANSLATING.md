# Translating Mialuna

Every word the app shows comes from `lib/l10n/`. English is the template
(`app_en.arb`); Italian is `app_it.arb`. Nothing user-facing is hard-coded in
the Dart code (a test fails if Italian text sneaks back in).

## Add a language

1. Copy `lib/l10n/app_en.arb` to `lib/l10n/app_<code>.arb` (e.g. `app_fr.arb`),
   change `"@@locale"` to the code and translate every value. Keep the
   `{placeholders}` exactly as they are; do not copy the `@key` metadata blocks.
2. Add the code to `appLanguages` and the language's own name to
   `languageEndonyms` in `lib/features/settings/settings_controller.dart`
   (the name, like "Français", is the same in every language). The Settings
   picker is one dropdown, so a new language does not need a new widget.
3. Run `flutter gen-l10n`, then `flutter test test/l10n`. The tests check that
   your file has exactly the English keys and the same placeholders.

## Plurals

Messages with a count use ICU plurals, one branch per form the language needs:

```
"peopleCount": "{count, plural, =1{1 person} other{{count} people}}"
```

## What stays untranslated on purpose

Protocol and technical text (relay messages, NIP names, `imeta` keys, header
names), the brand name "Mialuna" and the exception texts of the Nostr/LNURL
libraries.

## Check your work

Run the app with the language picker in Settings → Appearance → Language. The
layout test (`test/features/ui/layout_test.dart`) already renders every screen
in each supported language at two text sizes, so overflowing translations are
caught before release.
