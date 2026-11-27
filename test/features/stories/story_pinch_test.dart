import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/models/story_text.dart';
import 'package:mialuna/features/stories/story_canvas_editor.dart';
import 'package:mialuna/l10n/strings.dart';

/// Two fingers resize a story text from anywhere on the picture.
void main() {
  late List<StoryText> texts;

  Future<void> pump(WidgetTester tester, List<StoryText> initial) async {
    tester.view.physicalSize = const Size(450, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    texts = initial;
    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: StoryCanvasEditor(
            initial: initial,
            onChanged: (t) => texts = t,
          ),
        ),
      ),
    );
  }

  /// Two fingers starting at [a] and [b], spread to [factor] times as far.
  Future<void> pinch(
    WidgetTester tester,
    Offset a,
    Offset b,
    double factor,
  ) async {
    final middle = (a + b) / 2;
    final first = await tester.startGesture(a, pointer: 11);
    final second = await tester.startGesture(b, pointer: 12);
    for (var step = 1; step <= 10; step++) {
      final f = 1 + (factor - 1) * step / 10;
      await first.moveTo(middle + (a - middle) * f);
      await second.moveTo(middle + (b - middle) * f);
      await tester.pump();
    }
    await first.up();
    await second.up();
    await tester.pumpAndSettle();
  }

  const word = StoryText(text: 'ciao', y: 0.5);

  testWidgets('a pinch far from a short word makes it bigger', (tester) async {
    await pump(tester, const [word]);

    await pinch(tester, const Offset(125, 150), const Offset(325, 150), 1.8);

    expect(texts.single.scale, greaterThan(1.4));
    expect(find.byType(TextField), findsNothing, reason: 'not a tap');
  });

  testWidgets('and pinching in makes it smaller', (tester) async {
    await pump(tester, const [word]);

    await pinch(tester, const Offset(75, 150), const Offset(375, 150), 0.5);

    expect(texts.single.scale, lessThan(0.75));
  });

  testWidgets('a finger on a word picks that one, not the last', (
    tester,
  ) async {
    await pump(tester, const [
      StoryText(text: 'sopra', y: 0.25),
      StoryText(text: 'sotto', y: 0.75),
    ]);
    final upper = tester.getCenter(find.text('sopra', findRichText: true));

    await pinch(tester, upper, upper + const Offset(0, 200), 1.6);

    expect(texts.first.scale, greaterThan(1.2));
    expect(texts.last.scale, 1);
  });

  testWidgets('one finger moves only the word it is on', (tester) async {
    await pump(tester, const [word]);

    await tester.dragFrom(const Offset(80, 150), const Offset(100, 80));
    await tester.pumpAndSettle();
    expect(texts.single, word, reason: 'the drag was on the picture');

    final on = tester.getCenter(find.text('ciao', findRichText: true));
    await tester.dragFrom(on, const Offset(90, 120));
    await tester.pumpAndSettle();
    expect(texts.single.x, greaterThan(0.6));
    expect(texts.single.y, greaterThan(0.55));
    expect(texts.single.scale, 1);
  });

  testWidgets('a pinch while writing resizes the words being written', (
    tester,
  ) async {
    await pump(tester, const []);
    await tester.tapAt(const Offset(225, 200));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ciao');

    await pinch(tester, const Offset(125, 150), const Offset(325, 150), 1.8);
    expect(find.byType(TextField), findsOneWidget, reason: 'still writing');

    await tester.tap(find.widgetWithText(TextButton, 'Done'));
    await tester.pumpAndSettle();
    expect(texts.single.scale, greaterThan(1.4));
  });
}
