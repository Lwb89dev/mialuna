import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/create/create_controller.dart';
import 'package:mialuna/features/create/create_screen.dart';
import 'package:mialuna/l10n/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

/// The caption box of the Create tab shows what the composer holds. A story
/// shared from the Home rail left the box full of its text while the composer
/// was empty: the next post looked captioned, and the first key typed put the
/// old words back.
void main() {
  late Directory tmp;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    tmp = Directory.systemTemp.createTempSync('mialuna_caption_');
  });

  Future<ProviderContainer> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(822, 1846);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          indexerRelaysProvider.overrideWithValue(const []),
          relayPoolProvider.overrideWithValue(RelayPool(const [])),
          localCacheProvider.overrideWithValue(LocalCache(directory: tmp)),
          authProvider.overrideWith(
            () => _FixedAuth(
              NsecSigner.fromNsec(NsecSigner.generatePrivateKey()),
            ),
          ),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return MaterialApp(
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: const CreateScreen(),
            );
          },
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    return container;
  }

  String fieldText(WidgetTester tester) {
    final field = tester.widget<TextField>(
      find.byWidgetPredicate((w) => w is TextField && w.maxLength == 2200),
    );
    return field.controller!.text;
  }

  testWidgets('a caption set elsewhere shows, and so does its removal', (
    tester,
  ) async {
    final c = await pump(tester);
    final composer = c.read(composerProvider.notifier);

    composer.startStory();
    composer.setCaption('una storia dal cerchio della Home');
    await tester.pump();
    expect(fieldText(tester), 'una storia dal cerchio della Home');

    // The story is shared (or abandoned): the composer starts over.
    composer.startStory();
    await tester.pump();
    expect(
      fieldText(tester),
      isEmpty,
      reason: 'the old words stayed in the box',
    );
    expect(c.read(composerProvider).caption, isEmpty);
  });

  testWidgets('typing still works, and keeps its place', (tester) async {
    final c = await pump(tester);
    final box = find.byWidgetPredicate(
      (w) => w is TextField && w.maxLength == 2200,
    );
    await tester.enterText(box, 'ciao');
    await tester.pump();
    expect(c.read(composerProvider).caption, 'ciao');
    expect(fieldText(tester), 'ciao');

    await tester.enterText(box, 'ciao luna');
    await tester.pump();
    expect(c.read(composerProvider).caption, 'ciao luna');
  });

  testWidgets('a draft read late fills the box', (tester) async {
    final c = await pump(tester);
    c.read(composerProvider.notifier).setCaption('bozza');
    await tester.pump();
    expect(fieldText(tester), 'bozza');
  });
}
