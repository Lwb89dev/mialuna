import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/models/media_event.dart';
import 'package:mialuna/core/nostr/models/story_text.dart';
import 'package:mialuna/features/stories/story_text_editor.dart';
import 'package:mialuna/features/stories/story_text_view.dart';
import 'package:mialuna/l10n/strings.dart';

NostrEvent storyEvent(List<List<String>> extraTags, {String content = ''}) =>
    NostrEvent(
      id: 'a' * 64,
      pubkey: 'b' * 64,
      createdAt: 1700000000,
      kind: NostrKinds.picture,
      tags: [
        ['imeta', 'url https://cdn.example.com/s.jpg', 'm image/jpeg'],
        ['L', 'mialuna.story'],
        ['l', 'story', 'mialuna.story'],
        ...extraTags,
      ],
      content: content,
      sig: 'c' * 128,
    );

Widget app(Widget home) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  group('StoryText', () {
    test('survives a trip through its tag', () {
      const original = StoryText(
        text: 'Domenica #città',
        x: 0.25,
        y: 0.8,
        scale: 1.5,
        rotation: -0.3,
        color: 0xFF3B30,
        font: StoryTextFont.serif,
        background: StoryTextBackground.solid,
      );
      final tag = original.toTag();
      expect(tag.first, 'story-text');
      expect(StoryText.fromTag(tag), original);
    });

    test('a hostile tag is clamped, never trusted', () {
      final tag = [
        'story-text',
        jsonEncode({
          't': 'x' * 5000,
          'x': 99,
          'y': -7,
          's': 1e9,
          'r': 1e9,
          'c': 'zzzzzz',
          'f': 'comic-sans',
          'b': 'neon',
        }),
      ];
      final t = StoryText.fromTag(tag)!;
      expect(t.text.length, StoryText.maxLength);
      expect(t.x, 1);
      expect(t.y, 0);
      expect(t.scale, StoryText.maxScale);
      expect(t.rotation.abs(), lessThanOrEqualTo(6.2832));
      expect(t.color, 0xFFFFFF, reason: 'unreadable colour → white');
      expect(t.font, StoryTextFont.classic);
      expect(t.background, StoryTextBackground.none);
    });

    test('garbage and empty texts are dropped', () {
      expect(StoryText.fromTag(['story-text', 'not json']), isNull);
      expect(StoryText.fromTag(['story-text', '[1,2]']), isNull);
      expect(StoryText.fromTag(['story-text', '{"t":"   "}']), isNull);
      expect(StoryText.fromTag(['story-text', '{"t":5}']), isNull);
      expect(StoryText.fromTag(['story-text']), isNull);
      expect(StoryText.fromTag(['other', '{"t":"hi"}']), isNull);
    });

    test('control characters are removed but line breaks stay', () {
      expect(StoryText.cleanText('a\u0000b\u0007\nc\u007f'), 'ab\nc');
    });

    test('at most maxTexts are read from an event', () {
      final tags = [
        for (var i = 0; i < 20; i++) StoryText(text: 'n$i').toTag(),
      ];
      expect(StoryText.fromTags(tags), hasLength(StoryText.maxTexts));
    });
  });

  group('in events', () {
    test('a story carries its texts', () {
      final post = MediaPost.tryParse(
        storyEvent([
          const StoryText(text: 'ciao #mare', y: 0.3).toTag(),
          const StoryText(text: 'due').toTag(),
        ]),
      )!;
      expect(post.isStory, true);
      expect(post.overlays.map((t) => t.text), ['ciao #mare', 'due']);
    });

    test('a plain photo ignores story-text tags', () {
      final event = NostrEvent(
        id: 'a' * 64,
        pubkey: 'b' * 64,
        createdAt: 1700000000,
        kind: NostrKinds.picture,
        tags: [
          ['imeta', 'url https://cdn.example.com/s.jpg', 'm image/jpeg'],
          const StoryText(text: 'sneaky').toTag(),
        ],
        content: '',
        sig: 'c' * 128,
      );
      expect(MediaPost.tryParse(event)!.overlays, isEmpty);
    });

    test('publishing writes the texts and their hashtags', () {
      final tags = MediaPost.buildTags(
        media: const [MediaItem(url: 'https://cdn.example.com/s.jpg')],
        caption: 'didascalia #uno',
        isStory: true,
        overlays: const [
          StoryText(text: 'Sul #lago con #città'),
          StoryText(text: 'senza tag'),
        ],
      );
      final texts = tags.where((t) => t[0] == 'story-text').toList();
      expect(texts, hasLength(2));
      expect(tags.where((t) => t[0] == 't').map((t) => t[1]), [
        'uno',
        'lago',
        'città',
      ]);
      expect(StoryText.fromTag(texts.first)!.text, 'Sul #lago con #città');
    });

    test('texts are only written for stories', () {
      final tags = MediaPost.buildTags(
        media: const [MediaItem(url: 'https://cdn.example.com/s.jpg')],
        caption: '',
        overlays: const [StoryText(text: 'no')],
      );
      expect(tags.where((t) => t[0] == 'story-text'), isEmpty);
    });
  });

  group('storyMediaRect', () {
    test('letterboxes a wide picture in a tall box', () {
      final r = storyMediaRect(const Size(400, 800), 2);
      expect(r.width, 400);
      expect(r.height, 200);
      expect(r.top, 300);
    });

    test('pillarboxes a tall picture in a wide box', () {
      final r = storyMediaRect(const Size(800, 400), 0.5);
      expect(r.height, 400);
      expect(r.width, 200);
      expect(r.left, 300);
    });

    test('an unknown shape uses the whole box', () {
      expect(
        storyMediaRect(const Size(300, 600), null),
        Offset.zero & const Size(300, 600),
      );
    });
  });

  group('StoryOverlayLayer', () {
    testWidgets('puts a text on the spot of the picture it points at', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        app(
          const Scaffold(
            body: StoryOverlayLayer(
              mediaAspect: 2, // letterboxed: 400x200 at y=300
              texts: [StoryText(text: 'Centro', x: 0.5, y: 0.5)],
            ),
          ),
        ),
      );
      final center = tester.getCenter(find.text('Centro'));
      expect(center.dx, closeTo(200, 1));
      expect(center.dy, closeTo(400, 1)); // 300 + 0.5 * 200
    });

    testWidgets('a hashtag is tappable and does not advance the story', (
      tester,
    ) async {
      final tapped = <String>[];
      var parentTaps = 0;
      await tester.pumpWidget(
        app(
          Scaffold(
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => parentTaps++,
              child: StoryOverlayLayer(
                texts: const [StoryText(text: '#città')],
                onHashtagTap: tapped.add,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(RichText).first);
      await tester.pump(const Duration(milliseconds: 400));
      expect(tapped, ['città']);
      expect(parentTaps, 0);

      // Elsewhere on the screen the parent still gets its taps.
      await tester.tapAt(const Offset(5, 5));
      expect(parentTaps, 1);
    });

    testWidgets('plain words are not links', (tester) async {
      final tapped = <String>[];
      await tester.pumpWidget(
        app(
          Scaffold(
            body: StoryOverlayLayer(
              texts: const [StoryText(text: 'solo parole')],
              onHashtagTap: tapped.add,
            ),
          ),
        ),
      );
      await tester.tap(find.text('solo parole'));
      expect(tapped, isEmpty);
    });

    testWidgets('the user\'s font-size setting does not move the text', (
      tester,
    ) async {
      Future<Size> sizeAt(double scale) async {
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: app(
              const Scaffold(
                body: StoryOverlayLayer(texts: [StoryText(text: 'Stesso')]),
              ),
            ),
          ),
        );
        return tester.getSize(find.text('Stesso'));
      }

      expect(await sizeAt(1), await sizeAt(2));
    });
  });

  group('StoryTextEditorScreen', () {
    Future<void> open(
      WidgetTester tester,
      List<StoryText> initial,
      void Function(List<StoryText>?) onResult,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async => onResult(
                  await StoryTextEditorScreen.show(
                    context,
                    mediaAspect: 0.5,
                    initial: initial,
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    Finder addButton() => find.byTooltip('Add text');
    Finder doneInEditor() => find.widgetWithText(TextButton, 'Done');

    /// The words being typed over the picture.
    Finder writer() => find.byType(TextField);

    testWidgets('dragging a text moves it', (tester) async {
      List<StoryText>? result;
      await open(tester, const [StoryText(text: 'ciao')], (r) => result = r);

      await tester.drag(find.text('ciao'), const Offset(0, -200));
      await tester.pump();
      await tester.tap(doneInEditor());
      await tester.pumpAndSettle();

      expect(result, hasLength(1));
      expect(result!.single.y, lessThan(0.45));
      expect(result!.single.x, closeTo(0.5, 0.01));
    });

    testWidgets('a text dropped on the bin is deleted', (tester) async {
      List<StoryText>? result;
      await open(tester, const [StoryText(text: 'ciao')], (r) => result = r);

      await tester.drag(find.text('ciao'), const Offset(0, 750));
      await tester.pump();
      await tester.tap(doneInEditor());
      await tester.pumpAndSettle();

      expect(result, isEmpty);
    });

    testWidgets('the text is written on the picture, not in a sheet', (
      tester,
    ) async {
      List<StoryText>? result;
      await open(tester, const [], (r) => result = r);
      expect(writer(), findsNothing);

      await tester.tap(addButton());
      await tester.pumpAndSettle();
      expect(writer(), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      // The tools sit around the words, over the same screen.
      expect(find.text('Bold'), findsOneWidget);
      expect(find.byTooltip('Text background'), findsOneWidget);

      await tester.enterText(writer(), 'Ciao #mare');
      await tester.tap(doneInEditor());
      await tester.pumpAndSettle();
      expect(writer(), findsNothing);
      expect(find.text('Ciao #mare', findRichText: true), findsOneWidget);

      await tester.tap(doneInEditor());
      await tester.pumpAndSettle();
      expect(result!.single.text, 'Ciao #mare');
    });

    testWidgets('tapping the picture starts a text, as on Instagram', (
      tester,
    ) async {
      await open(tester, const [], (_) {});

      await tester.tapAt(const Offset(400, 300));
      await tester.pumpAndSettle();

      expect(writer(), findsOneWidget);
    });

    testWidgets('the look chosen while typing is the look of the text', (
      tester,
    ) async {
      List<StoryText>? result;
      await open(tester, const [], (r) => result = r);

      await tester.tap(addButton());
      await tester.pumpAndSettle();
      await tester.enterText(writer(), 'Ciao');
      await tester.tap(find.text('Serif'));
      await tester.tap(find.byTooltip('Text background'));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Text colour').at(2));
      await tester.pump();
      // Tapping the dimmed picture around the words finishes, too.
      await tester.tapAt(const Offset(400, 1000));
      await tester.pumpAndSettle();
      expect(writer(), findsNothing);

      await tester.tap(doneInEditor());
      await tester.pumpAndSettle();
      final text = result!.single;
      expect(text.font, StoryTextFont.serif);
      expect(text.background, StoryTextBackground.solid);
      expect(text.color, 0xFF3B30);
    });

    testWidgets('hashtags are underlined as they are typed', (tester) async {
      await open(tester, const [], (_) {});
      await tester.tap(addButton());
      await tester.pumpAndSettle();
      await tester.enterText(writer(), 'Ciao #mare blu');

      final field = tester.widget<EditableText>(find.byType(EditableText));
      final span = field.controller.buildTextSpan(
        context: tester.element(find.byType(EditableText)),
        style: const TextStyle(),
        withComposing: false,
      );
      final underlined = [
        for (final c in span.children!.cast<TextSpan>())
          if (c.style?.decoration == TextDecoration.underline) c.text,
      ];
      expect(underlined, ['#mare']);
    });

    testWidgets('a text is edited in place by tapping it', (tester) async {
      List<StoryText>? result;
      await open(tester, const [
        StoryText(text: 'ciao', x: 0.3, y: 0.6, scale: 1.5),
      ], (r) => result = r);

      await tester.tap(find.text('ciao'));
      await tester.pumpAndSettle();
      expect(writer(), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.widgetWithText(TextField, 'ciao'), findsOneWidget);

      await tester.enterText(writer(), 'ciao #sole');
      await tester.tap(doneInEditor());
      await tester.pumpAndSettle();
      await tester.tap(doneInEditor());
      await tester.pumpAndSettle();

      final text = result!.single;
      expect(text.text, 'ciao #sole');
      expect(text.x, 0.3, reason: 'it stays where it was');
      expect(text.y, 0.6);
      expect(text.scale, 1.5);
    });

    testWidgets('a text emptied while editing is deleted', (tester) async {
      List<StoryText>? result;
      await open(tester, const [StoryText(text: 'ciao')], (r) => result = r);

      await tester.tap(find.text('ciao'));
      await tester.pumpAndSettle();
      await tester.enterText(writer(), '');
      await tester.tap(doneInEditor());
      await tester.pumpAndSettle();
      await tester.tap(doneInEditor());
      await tester.pumpAndSettle();

      expect(result, isEmpty);
    });

    testWidgets('Back finishes the text instead of leaving the editor', (
      tester,
    ) async {
      List<StoryText>? result;
      await open(tester, const [], (r) => result = r);
      await tester.tap(addButton());
      await tester.pumpAndSettle();
      await tester.enterText(writer(), 'ancora qui');

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(writer(), findsNothing);
      expect(find.text('ancora qui', findRichText: true), findsOneWidget);
      expect(result, isNull, reason: 'still in the editor');
    });

    testWidgets('an empty text is not added', (tester) async {
      List<StoryText>? result;
      await open(tester, const [], (r) => result = r);

      await tester.tap(addButton());
      await tester.pumpAndSettle();
      await tester.tap(doneInEditor());
      await tester.pumpAndSettle();
      await tester.tap(doneInEditor());
      await tester.pumpAndSettle();

      expect(result, isEmpty);
    });

    testWidgets('closing the editor applies nothing', (tester) async {
      List<StoryText>? result = const [StoryText(text: 'unchanged')];
      await open(tester, const [StoryText(text: 'ciao')], (r) => result = r);

      await tester.drag(find.text('ciao'), const Offset(0, -200));
      await tester.pump();
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();

      expect(result, isNull, reason: 'null = nothing to apply');
    });

    testWidgets('the number of texts is capped', (tester) async {
      await open(tester, [
        for (var i = 0; i < StoryText.maxTexts; i++)
          StoryText(text: 't$i', y: i / 10),
      ], (_) {});

      await tester.tap(addButton());
      await tester.pumpAndSettle();
      expect(writer(), findsNothing);
      expect(
        find.text('You can add up to ${StoryText.maxTexts} texts.'),
        findsOneWidget,
      );
    });
  });
}
