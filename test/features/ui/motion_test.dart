import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/theme/mialuna_motion.dart';
import 'package:mialuna/features/feed/widgets/moon_like.dart';

Widget _app(Widget child, {bool reduce = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduce),
    child: Scaffold(body: child),
  ),
);

void main() {
  testWidgets('scrolling cancels the press without activating the item', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _app(
        ListView(
          children: [
            MialunaPressable(
              onTap: () => taps++,
              child: const SizedBox(height: 200, child: Text('Story')),
            ),
            const SizedBox(height: 1600),
          ],
        ),
      ),
    );
    final target = find.byType(MialunaPressable);
    final gesture = await tester.startGesture(tester.getCenter(target));
    await tester.pump(const Duration(milliseconds: 150));
    expect(
      tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
      0.96,
    );

    await gesture.moveBy(const Offset(0, -100));
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(taps, 0);

    await tester.tap(target);
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('reduced motion keeps a pressed item still and tappable', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _app(
        MialunaPressable(
          onTap: () => taps++,
          child: const SizedBox(width: 100, height: 100),
        ),
        reduce: true,
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(MialunaPressable)),
    );
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('enabling reduced motion stops an active moon burst', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const MoonBurst(trigger: 0)));
    await tester.pumpWidget(_app(const MoonBurst(trigger: 1)));
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.byType(Image), findsOneWidget);

    await tester.pumpWidget(_app(const MoonBurst(trigger: 1), reduce: true));
    await tester.pump();
    expect(find.byType(Image), findsNothing);
    expect(tester.binding.transientCallbackCount, 0);
  });
}
