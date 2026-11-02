import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// The app icon is drawn by the app (Home bar, onboarding, login), by
/// Android's launcher and by iOS. A flat PNG with black corners outside its
/// rounded shape looks fine in a viewer and wrong everywhere else.
void main() {
  img.Image load(String path) => img.decodePng(File(path).readAsBytesSync())!;

  test(
    'assets/icons/icon.png has transparent corners and an opaque middle',
    () {
      final icon = load('assets/icons/icon.png');
      expect(icon.hasAlpha, true, reason: 'black corners instead of alpha');
      for (final (x, y) in [
        (0, 0),
        (icon.width - 1, 0),
        (0, icon.height - 1),
        (icon.width - 1, icon.height - 1),
      ]) {
        expect(icon.getPixel(x, y).a, 0, reason: 'corner $x,$y');
      }
      expect(icon.getPixel(icon.width ~/ 2, icon.height ~/ 2).a, 255);
      expect(icon.width, icon.height);
    },
  );

  test('the iOS icon is an opaque, full-bleed 1024 square', () {
    final ios = load('tool/launcher/ios_icon.png');
    expect(ios.width, 1024);
    expect(ios.height, 1024);
    expect(ios.hasAlpha, false);
    // No black corner: the shape's own corners were cropped away.
    final corner = ios.getPixel(0, 0);
    expect(corner.r + corner.g + corner.b, greaterThan(40));
  });

  test('the generated launcher icons exist for Android and iOS', () {
    for (final dpi in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']) {
      expect(
        File('android/app/src/main/res/mipmap-$dpi/ic_launcher.png')
            .existsSync(),
        true,
        reason: dpi,
      );
      expect(
        File(
          'android/app/src/main/res/drawable-$dpi/ic_launcher_background.png',
        ).existsSync(),
        true,
        reason: dpi,
      );
    }
    final ios = File(
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png',
    );
    expect(img.decodePng(ios.readAsBytesSync())!.hasAlpha, false);
  });
}
