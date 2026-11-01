import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/branding/app_info.dart';
import 'package:mialuna/features/settings/settings_controller.dart';
import 'package:mialuna/l10n/strings.dart';

Map<String, dynamic> arb(String code) =>
    jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> keysOf(Map<String, dynamic> m) =>
    m.keys.where((k) => !k.startsWith('@')).toSet();

/// `{name}` placeholders of a message, ignoring the ICU plural/select syntax
/// (`{count, plural, =1{…} other{…}}`) around them.
Set<String> placeholders(String message) {
  final found = <String>{};
  for (final m in RegExp(r'(?<![\w=])\{(\w+)(?=[,}])').allMatches(message)) {
    found.add(m.group(1)!);
  }
  return found;
}

void main() {
  final languages = Directory('lib/l10n')
      .listSync()
      .map((f) => RegExp(r'app_(\w+)\.arb$').firstMatch(f.path)?.group(1))
      .whereType<String>()
      .toList();

  test('English is the template and every language has its ARB file', () {
    expect(languages, containsAll(['en', 'it']));
    expect(languages.toSet(), appLanguages.toSet(), reason: 'appLanguages');
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
      languages.toSet(),
    );
  });

  for (final code in languages.where((c) => c != 'en')) {
    test('$code translates exactly the English keys', () {
      final en = keysOf(arb('en'));
      final tr = keysOf(arb(code));
      expect(en.difference(tr), isEmpty, reason: 'missing in app_$code.arb');
      expect(tr.difference(en), isEmpty, reason: 'unknown in app_$code.arb');
    });

    test('$code keeps every placeholder of the English message', () {
      final en = arb('en');
      final tr = arb(code);
      for (final key in keysOf(en)) {
        expect(
          placeholders(tr[key] as String),
          placeholders(en[key] as String),
          reason: '$key in app_$code.arb',
        );
      }
    });
  }

  test('no message is empty', () {
    for (final code in languages) {
      final m = arb(code);
      for (final key in keysOf(m)) {
        expect((m[key] as String).trim(), isNotEmpty, reason: '$key/$code');
      }
    }
  });

  test('plurals follow each language', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final it = lookupAppLocalizations(const Locale('it'));
    expect(en.sentToCloseFriends(1), contains('1 close friend '));
    expect(en.sentToCloseFriends(3), contains('3 close friends'));
    expect(it.sentToCloseFriends(1), contains('1 amico più stretto'));
    expect(it.sentToCloseFriends(3), contains('3 amici più stretti'));
    expect(en.peopleCount(1), '1 person');
    expect(en.peopleCount(2), '2 people');
    expect(it.peopleCount(1), '1 persona');
  });

  test('messages with arguments fill them in', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final it = lookupAppLocalizations(const Locale('it'));
    expect(en.uploadingProgress(2, 5), 'Uploading 2 of 5…');
    expect(it.uploadingProgress(2, 5), 'Caricamento 2 di 5…');
    expect(en.minutesAgo(5), '5 min ago');
    expect(it.minutesAgo(5), '5 min fa');
    expect(en.weekdayShort('mon'), 'Mon');
    expect(it.weekdayShort('mon'), 'lun');
    expect(en.aboutText('9.9.9'), contains('Mialuna 9.9.9'));
  });

  test('AppStrings follows the active locale and starts in English', () {
    final before = AppStrings.current;
    addTearDown(() => AppStrings.current = before);
    AppStrings.use(const Locale('it'));
    expect(AppStrings.current.cancel, 'Annulla');
    AppStrings.use(const Locale('en'));
    expect(AppStrings.current.cancel, 'Cancel');
  });

  test('the version shown in Settings is the one in pubspec.yaml', () {
    final line = File('pubspec.yaml')
        .readAsLinesSync()
        .firstWhere((l) => l.startsWith('version:'));
    expect(line.split(':')[1].trim().split('+').first, appVersion);
  });

  test('no Italian is left hard-coded in the app code', () {
    // Anything the user reads must come from lib/l10n. The accent-folding
    // table of the people search is data, not text.
    final accented = RegExp("['\"][^'\"\\n]*[àèéìòù][^'\"\\n]*['\"]");
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      if (f.path.startsWith('lib/l10n/')) continue;
      if (f.path.endsWith('people_search.dart')) continue;
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        if (accented.hasMatch(line)) offenders.add('${f.path}:${i + 1}');
      }
    }
    expect(offenders, isEmpty);
  });
}
