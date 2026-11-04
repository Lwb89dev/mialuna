import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/features/stories/story_cleanup.dart';
import 'package:mialuna/features/stories/story_cleanup_setting.dart';
import 'package:mialuna/l10n/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/story_harness.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

/// Stands in for the cleanup: says how many stories are due, and what pressing
/// the button gets.
class _Cleanup extends StoryCleanup {
  final int due;
  final bool result;
  int asked = 0;
  _Cleanup(this.due, {this.result = true});

  @override
  StoryCleanupState build() => StoryCleanupState(due: due);

  @override
  Future<bool> run({bool ask = false}) async {
    if (ask) asked++;
    return result;
  }
}

void main() {
  late _Cleanup cleanup;
  var locale = 'en';

  setUp(() {
    locale = 'en';
    SharedPreferences.setMockInitialValues({});
  });

  Future<ProviderContainer> pump(
    WidgetTester tester,
    Signer signer, {
    int due = 0,
    bool result = true,
  }) async {
    cleanup = _Cleanup(due, result: result);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => _FixedAuth(signer)),
          storyCleanupProvider.overrideWith(() => cleanup),
        ],
        child: MaterialApp(
          locale: Locale(locale),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const Scaffold(body: StoryCleanupSetting()),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    return ProviderScope.containerOf(tester.element(find.byType(Scaffold)));
  }

  NsecSigner key() => NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
  ScriptedSigner amber() => ScriptedSigner(key(), kind: SignerType.amber);

  testWidgets('a key on the phone gets the switch, and no button', (
    tester,
  ) async {
    await pump(tester, key(), due: 3);

    expect(find.text('Delete my stories when they expire'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
    expect(find.text('Delete now'), findsNothing);
  });

  testWidgets('a guest sees nothing', (tester) async {
    await pump(tester, GuestSigner(), due: 3);

    expect(find.byType(Switch), findsNothing);
  });

  testWidgets(
    'Amber with stories waiting gets a button, and the result is said',
    (tester) async {
      await pump(tester, amber(), due: 2);
      expect(find.textContaining('Expired stories waiting: 2'), findsOneWidget);

      await tester.tap(find.text('Delete now'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(cleanup.asked, 1);
      expect(find.text('Expired stories deleted.'), findsOneWidget);
    },
  );

  testWidgets('says when some could not be deleted yet', (tester) async {
    await pump(tester, amber(), due: 2, result: false);

    await tester.tap(find.text('Delete now'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('will try again'), findsOneWidget);
  });

  testWidgets('Amber with nothing waiting shows only the switch', (
    tester,
  ) async {
    await pump(tester, amber());

    expect(find.byType(Switch), findsOneWidget);
    expect(find.text('Delete now'), findsNothing);
  });

  testWidgets('the switch is on by default and the choice is kept', (
    tester,
  ) async {
    final c = await pump(tester, key());
    expect(tester.widget<Switch>(find.byType(Switch)).value, true);

    await tester.tap(find.byType(Switch));
    await tester.pump(const Duration(milliseconds: 300));

    expect(c.read(deleteExpiredStoriesProvider), false);
    expect(tester.widget<Switch>(find.byType(Switch)).value, false);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('mialuna_delete_expired_stories'), false);
  });

  testWidgets('a saved "off" is read back', (tester) async {
    SharedPreferences.setMockInitialValues({
      'mialuna_delete_expired_stories': false,
    });
    await pump(tester, key());
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.widget<Switch>(find.byType(Switch)).value, false);
  });

  testWidgets('is in Italian too', (tester) async {
    locale = 'it';
    await pump(tester, amber(), due: 1);

    expect(find.text('Elimina le mie storie alla scadenza'), findsOneWidget);
    expect(find.text('Elimina ora'), findsOneWidget);
  });
}
