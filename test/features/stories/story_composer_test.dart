import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/models/story_text.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/create/create_controller.dart';
import 'package:mialuna/features/private/close_friends.dart';
import 'package:mialuna/features/stories/story_composer_screen.dart';
import 'package:mialuna/l10n/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

Uint8List _jpeg() {
  final image = img.Image(width: 40, height: 30);
  img.fill(image, color: img.ColorRgb8(220, 90, 50));
  return Uint8List.fromList(img.encodeJpg(image));
}

PickedMedia _picked() {
  final bytes = _jpeg();
  return PickedMedia(
    file: XFile.fromData(bytes, name: 'a.jpg'),
    bytes: bytes,
    mimeType: 'image/jpeg',
  );
}

/// A composer that does not touch the network: it hands back a picture and
/// remembers what it was asked to publish.
class _Composer extends ComposerController {
  final List<ComposerState> published = [];
  final bool withPicture;
  final bool fails;
  _Composer({this.withPicture = true, this.fails = false});

  @override
  ComposerState build() => ComposerState(
    mode: ComposerMode.story,
    media: withPicture ? [_picked()] : const [],
  );

  @override
  Future<({Uint8List? bytes, double? aspect})> storyBackdrop() async =>
      (bytes: _jpeg(), aspect: 40 / 30);

  @override
  Future<bool> publish() async {
    published.add(state);
    if (fails) {
      state = state.copyWith(error: 'No relay accepted the story.');
      return false;
    }
    state = ComposerState(published: true, audience: state.audience);
    return true;
  }
}

class _Friends extends CloseFriendsController {
  final List<String> members;
  _Friends(this.members);
  @override
  CloseFriendsState build() =>
      CloseFriendsState(members: members, synced: true);

  @override
  Future<void> sync() async {}
}

final _me = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());

void main() {
  late Directory tmp;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    tmp = Directory.systemTemp.createTempSync('mialuna_composer_');
  });

  late _Composer composer;

  Future<ProviderContainer> open(
    WidgetTester tester, {
    _Composer? with_,
    List<String> friends = const [],
    Signer? as,
  }) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    composer = with_ ?? _Composer();
    final scope = ProviderScope(
      overrides: [
        indexerRelaysProvider.overrideWithValue(const []),
        relayPoolProvider.overrideWithValue(RelayPool(const [])),
        localCacheProvider.overrideWithValue(LocalCache(directory: tmp)),
        authProvider.overrideWith(() => _FixedAuth(as ?? _me)),
        composerProvider.overrideWith(() => composer),
        closeFriendsProvider.overrideWith(() => _Friends(friends)),
      ],
      child: MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => const StoryComposerScreen(fresh: false),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(scope);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(
      tester.element(find.byType(StoryComposerScreen)),
    );
  }

  ComposerState state(ProviderContainer c) => c.read(composerProvider);

  testWidgets('the picture opens with the tools around it', (tester) async {
    await open(tester);

    expect(find.byType(Image), findsOneWidget);
    expect(find.byTooltip('Add text'), findsOneWidget);
    expect(find.byTooltip('Edit photo'), findsOneWidget);
    expect(find.byTooltip('Caption'), findsOneWidget);
    expect(find.text('Public'), findsOneWidget);
    expect(find.text('Close friends'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Share'), findsOneWidget);
  });

  testWidgets('words are written on the picture and kept for the story', (
    tester,
  ) async {
    final c = await open(tester);

    await tester.tap(find.byTooltip('Add text'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    await tester.enterText(find.byType(TextField), 'Tramonto #mare');
    await tester.tap(find.widgetWithText(TextButton, 'Done'));
    await tester.pumpAndSettle();

    expect(state(c).overlays.map((t) => t.text), ['Tramonto #mare']);
    expect(
      find.text('Tramonto #mare', findRichText: true),
      findsOneWidget,
      reason: 'it is on the picture',
    );
  });

  testWidgets('sharing publishes the story and returns to where it began', (
    tester,
  ) async {
    final c = await open(tester);
    c.read(composerProvider.notifier).setOverlays(const [
      StoryText(text: 'ciao'),
    ]);
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Share'));
    await tester.pumpAndSettle();

    expect(composer.published, hasLength(1));
    expect(composer.published.single.overlays.single.text, 'ciao');
    expect(composer.published.single.mode, ComposerMode.story);
    expect(find.text('open'), findsOneWidget, reason: 'back on the home');
    expect(find.text('Story shared'), findsOneWidget);
  });

  testWidgets('a story that fails to publish stays, with the reason', (
    tester,
  ) async {
    await open(tester, with_: _Composer(fails: true));

    await tester.tap(find.widgetWithText(FilledButton, 'Share'));
    await tester.pumpAndSettle();

    expect(find.text('No relay accepted the story.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Share'), findsOneWidget);
  });

  testWidgets('close friends need friends before anything can be shared', (
    tester,
  ) async {
    await open(tester);

    await tester.tap(find.text('Close friends'));
    await tester.pumpAndSettle();

    final share = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Share'),
    );
    expect(share.onPressed, isNull);
    expect(find.text('Add friends'), findsOneWidget);
  });

  testWidgets('with friends the story can go to them', (tester) async {
    final c = await open(tester, friends: ['ab' * 32]);

    await tester.tap(find.text('Close friends'));
    await tester.pumpAndSettle();
    expect(state(c).audience, Audience.closeFriends);

    final share = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Share'),
    );
    expect(share.onPressed, isNotNull);
  });

  testWidgets('a guest cannot share', (tester) async {
    await open(tester, as: GuestSigner());

    final share = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Share'),
    );
    expect(share.onPressed, isNull);
  });

  testWidgets('leaving asks first, and keeping the story keeps it', (
    tester,
  ) async {
    final c = await open(tester);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Discard this story?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Discard this story?'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Share'), findsOneWidget);
    expect(state(c).media, isNotEmpty);
  });

  testWidgets('Back asks first too, and discarding throws the story away', (
    tester,
  ) async {
    final c = await open(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Discard this story?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Discard'));
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
    expect(state(c).media, isEmpty);
    expect(state(c).overlays, isEmpty);
  });

  testWidgets('with nothing chosen the three sources are offered', (
    tester,
  ) async {
    await open(tester, with_: _Composer(withPicture: false));

    expect(
      find.text('Choose a photo or a video for your story'),
      findsOneWidget,
    );
    expect(find.text('From gallery'), findsOneWidget);
    expect(find.text('Camera'), findsOneWidget);
    expect(find.byType(CloseButton), findsOneWidget);
  });

  testWidgets('the caption is set from the top bar', (tester) async {
    final c = await open(tester);

    await tester.tap(find.byTooltip('Caption'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'dalla spiaggia #estate');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(state(c).caption, 'dalla spiaggia #estate');
    expect(
      find.text('dalla spiaggia #estate'),
      findsOneWidget,
      reason: 'what goes with the story is shown, not hidden',
    );
  });
}
