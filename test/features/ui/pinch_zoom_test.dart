import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/features/feed/widgets/pinch_zoom.dart';
import 'package:mialuna/l10n/strings.dart';

void main() {
  const key = Key('media');

  Widget app({ScrollController? controller}) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: ListView(
        controller: controller,
        children: [
          const SizedBox(height: 100),
          PinchToZoom(
            child: Container(key: key, height: 300, color: Colors.red),
          ),
          const SizedBox(height: 2000),
        ],
      ),
    ),
  );

  testWidgets('two fingers grow the media above the page and it springs back', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    expect(find.byKey(key), findsOneWidget);
    final width = tester.getSize(find.byKey(key)).width;

    final center = tester.getCenter(find.byKey(key));
    final a = await tester.startGesture(
      center - const Offset(40, 0),
      pointer: 1,
    );
    final b = await tester.startGesture(
      center + const Offset(40, 0),
      pointer: 2,
    );
    await tester.pump();
    await a.moveBy(const Offset(-60, 0));
    await b.moveBy(const Offset(60, 0));
    await tester.pump();

    // A copy floats in the overlay, bigger than the original.
    expect(find.byKey(key), findsNWidgets(2));
    final floating = find.byKey(key).last;
    final grown =
        tester.getBottomRight(floating).dx - tester.getTopLeft(floating).dx;
    expect(grown, greaterThan(width * 2));

    await a.up();
    await b.up();
    await tester.pumpAndSettle();
    expect(find.byKey(key), findsOneWidget);
    expect(tester.getSize(find.byKey(key)).width, width);
  });

  testWidgets('pinching does not scroll the feed', (tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(app(controller: controller));
    final center = tester.getCenter(find.byKey(key));
    final a = await tester.startGesture(
      center - const Offset(40, 0),
      pointer: 1,
    );
    final b = await tester.startGesture(
      center + const Offset(40, 0),
      pointer: 2,
    );
    await tester.pump();
    // Both fingers also travel upwards while spreading.
    await a.moveBy(const Offset(-40, -80));
    await b.moveBy(const Offset(40, -80));
    await tester.pump();
    expect(controller.offset, 0);
    await a.up();
    await b.up();
    await tester.pumpAndSettle();
  });

  testWidgets('a one-finger swipe still scrolls the list', (tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(app(controller: controller));
    await tester.drag(find.byKey(key), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(controller.offset, greaterThan(100));
    expect(find.byKey(key), findsOneWidget); // no overlay was started
  });

  testWidgets('disabled zoom leaves the child alone', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PinchToZoom(
          enabled: false,
          child: SizedBox(key: key, width: 100, height: 100),
        ),
      ),
    );
    final c = tester.getCenter(find.byKey(key));
    final a = await tester.startGesture(c - const Offset(20, 0), pointer: 1);
    final b = await tester.startGesture(c + const Offset(20, 0), pointer: 2);
    await a.moveBy(const Offset(-30, 0));
    await b.moveBy(const Offset(30, 0));
    await tester.pump();
    expect(find.byKey(key), findsOneWidget);
    await a.up();
    await b.up();
  });
}
