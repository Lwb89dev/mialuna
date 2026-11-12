import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mialuna/features/create/editor/image_editor_screen.dart';
import 'package:mialuna/l10n/strings.dart';

/// The editor in every language, on the smallest phone with large text and
/// on a common phone: every panel must lay out without overflowing.
void main() {
  final photo = () {
    final image = img.Image(width: 120, height: 80);
    img.fill(image, color: img.ColorRgb8(90, 140, 200));
    return Uint8List.fromList(img.encodeJpg(image));
  }();

  const cases = {
    'small phone, large text': (Size(320, 568), 2.0),
    'pixel': (Size(411, 923), 1.0),
  };

  for (final lang in AppLocalizations.supportedLocales.map(
    (l) => l.languageCode,
  )) {
    for (final MapEntry(key: where, value: (size, scale)) in cases.entries) {
      for (final pro in [false, true]) {
        testWidgets('[$lang] ${pro ? 'pro' : 'basic'} editor · $where', (
          tester,
        ) async {
          tester.view.physicalSize = size * 2;
          tester.view.devicePixelRatio = 2;
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearAllTestValues);

          await tester.pumpWidget(
            MaterialApp(
              locale: Locale(lang),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: ImageEditorScreen(bytes: photo, pro: pro, otherPhotos: 1),
            ),
          );
          // Decoding runs in an isolate: give it real time.
          for (
            var i = 0;
            i < 20 && find.byType(Slider).evaluate().isEmpty;
            i++
          ) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 100)),
            );
            await tester.pump();
          }
          expect(find.byType(Slider), findsWidgets);
          final first = tester.takeException();
          expect(
            first,
            isNull,
            reason: first is FlutterError ? first.toStringDeep() : '$first',
          );

          if (pro) {
            for (final tool in EditorTool.values) {
              final state = tester.state(find.byType(ImageEditorScreen));
              // Select the panel through its tab (the icons are the tabs).
              final icon = switch (tool) {
                EditorTool.crop => Icons.crop_rotate,
                EditorTool.light => Icons.wb_sunny_outlined,
                EditorTool.color => Icons.thermostat_outlined,
                EditorTool.hsl => Icons.palette_outlined,
                EditorTool.curves => Icons.show_chart,
                EditorTool.effects => Icons.auto_awesome_outlined,
              };
              await tester.ensureVisible(find.byIcon(icon));
              await tester.tap(find.byIcon(icon));
              await tester.pump();
              expect(state.mounted, isTrue);
              final error = tester.takeException();
              expect(
                error,
                isNull,
                reason:
                    '$lang ${tool.name}: '
                    '${error is FlutterError ? error.toStringDeep() : error}',
              );
            }
          }
          await tester.pumpWidget(const SizedBox());
          await tester.pump(const Duration(seconds: 1));
        });
      }
    }
  }
}
