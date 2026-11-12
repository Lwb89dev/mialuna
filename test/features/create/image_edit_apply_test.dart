import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mialuna/features/create/editor/adjustments.dart';
import 'package:mialuna/features/create/editor/color_engine.dart';
import 'package:mialuna/features/create/editor/crop_tool.dart';
import 'package:mialuna/features/create/editor/image_edit_apply.dart';

Uint8List solidJpeg(int width, int height, int r, int g, int b) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(r, g, b));
  return Uint8List.fromList(img.encodeJpg(image, quality: 100));
}

/// Left half red, right half blue: tells turns and mirrors apart.
img.Image halves(int width, int height) {
  final image = img.Image(width: width, height: height);
  for (final p in image) {
    p
      ..r = p.x < width / 2 ? 255 : 0
      ..g = 0
      ..b = p.x < width / 2 ? 0 : 255;
  }
  return image;
}

img.Image render(Uint8List bytes, ImageEdit edit) =>
    img.decodeImage(applyImageEdit(bytes, edit)!.bytes)!;

ImageEdit look(Adjustments a) => ImageEdit(adjust: a);

void main() {
  group('geometry', () {
    test('an untouched photo comes back byte for byte, not re-encoded', () {
      final bytes = solidJpeg(40, 30, 200, 100, 50);
      final out = applyImageEdit(bytes, const ImageEdit())!;
      expect(identical(out.bytes, bytes), isTrue);
      expect((out.width, out.height), (40, 30));
    });

    test('crop halves the picture in fractions', () {
      final out = render(
        solidJpeg(40, 30, 200, 100, 50),
        const ImageEdit(crop: Crop(left: 0.25, right: 0.75)),
      );
      expect((out.width, out.height), (20, 30));
    });

    test('a quarter turn swaps width and height', () {
      final out = render(
        solidJpeg(40, 30, 200, 100, 50),
        const ImageEdit(quarterTurns: 1),
      );
      expect((out.width, out.height), (30, 40));
    });

    test('rotation then crop applies in rotated space', () {
      final out = render(
        solidJpeg(40, 30, 200, 100, 50),
        const ImageEdit(quarterTurns: 1, crop: Crop(bottom: 0.5)),
      );
      expect((out.width, out.height), (30, 20));
    });

    test('turns and mirror match the image package pixel for pixel', () {
      final source = halves(8, 6);
      for (var turns = 0; turns < 4; turns++) {
        for (final flip in [false, true]) {
          var expected = img.copyRotate(source, angle: 90.0 * turns);
          if (flip) expected = img.flipHorizontal(img.Image.from(expected));
          final out = renderEdit(
            source,
            ImageEdit(quarterTurns: turns, flipHorizontal: flip),
          );
          expect((out.width, out.height), (expected.width, expected.height));
          for (final p in expected) {
            final o = out.getPixel(p.x, p.y);
            expect((o.r, o.b), (p.r, p.b), reason: 'turns $turns flip $flip');
          }
        }
      }
    });

    test('straightening keeps the size and shows no empty corner', () {
      final out = render(
        solidJpeg(60, 40, 120, 160, 200),
        const ImageEdit(straighten: 12),
      );
      expect((out.width, out.height), (60, 40));
      for (final (x, y) in [(0, 0), (59, 0), (0, 39), (59, 39)]) {
        expect(out.getPixel(x, y).b.toInt(), greaterThan(180));
      }
    });

    test('the EXIF orientation is applied before editing', () {
      final image = img.Image(width: 40, height: 20);
      img.fill(image, color: img.ColorRgb8(10, 200, 10));
      image.exif.imageIfd.orientation = 6; // shot holding the phone upright
      final bytes = Uint8List.fromList(img.encodeJpg(image));
      final out = render(bytes, const ImageEdit(crop: Crop(right: 0.5)));
      expect((out.width, out.height), (10, 40));
      expect(out.exif.imageIfd.hasOrientation, isFalse);
    });

    test('the colour profile survives the edit', () {
      final image = img.Image(width: 8, height: 8);
      img.fill(image, color: img.ColorRgb8(100, 100, 100));
      image.iccProfile = img.IccProfile(
        'Display P3',
        img.IccProfileCompression.none,
        Uint8List.fromList(List.generate(200, (i) => i % 256)),
      );
      final bytes = Uint8List.fromList(img.encodeJpg(image));
      final out = render(bytes, look(const Adjustments(exposure: 0.3)));
      expect(out.iccProfile, isNotNull);
      expect(out.iccProfile!.decompressed().length, 200);
    });

    test('undecodable bytes give no result', () {
      expect(
        applyImageEdit(Uint8List.fromList([1, 2, 3]), const ImageEdit()),
        isNull,
      );
    });
  });

  group('look', () {
    img.Pixel centre(Uint8List bytes, Adjustments a) {
      final out = render(bytes, look(a));
      return out.getPixel(out.width ~/ 2, out.height ~/ 2);
    }

    final grey = solidJpeg(16, 16, 120, 120, 120);

    test('the neutral table is the identity', () {
      final lut = ColorEngine.buildLut(Adjustments.none);
      final out = Float64List(3);
      ColorEngine.sampleLut(lut, 0.2, 0.5, 0.9, out);
      expect(out[0], closeTo(0.2, 1e-6));
      expect(out[1], closeTo(0.5, 1e-6));
      expect(out[2], closeTo(0.9, 1e-6));
    });

    test('positive brightness and exposure brighten', () {
      expect(
        centre(grey, const Adjustments(brightness: 0.5)).r,
        greaterThan(130),
      );
      expect(
        centre(grey, const Adjustments(exposure: 0.5)).r,
        greaterThan(150),
      );
      expect(centre(grey, const Adjustments(exposure: -0.5)).r, lessThan(90));
    });

    test('saturation −1 turns colour to grey', () {
      final p = centre(
        solidJpeg(8, 8, 200, 50, 50),
        const Adjustments(saturation: -1),
      );
      expect((p.r - p.g).abs(), lessThan(4));
      expect((p.g - p.b).abs(), lessThan(4));
    });

    test('a warmer temperature adds red and takes blue', () {
      final p = centre(grey, const Adjustments(temperature: 0.6));
      expect(p.r, greaterThan(p.b + 15));
    });

    test('shadows lift the darks more than the lights', () {
      final dark = centre(
        solidJpeg(8, 8, 40, 40, 40),
        const Adjustments(shadows: 1),
      );
      final light = centre(
        solidJpeg(8, 8, 220, 220, 220),
        const Adjustments(shadows: 1),
      );
      expect(dark.r - 40, greaterThan(15));
      expect((light.r - 220).abs(), lessThan(4));
    });

    test('HSL changes one colour range and leaves the others', () {
      const shift = Adjustments();
      final noRed = shift.withHsl(HslColor.red, const HslShift(saturation: -1));
      final red = centre(solidJpeg(8, 8, 210, 30, 30), noRed);
      final blue = centre(solidJpeg(8, 8, 30, 30, 210), noRed);
      expect((red.r - red.g).abs(), lessThan(10));
      expect(blue.b - blue.r, greaterThan(150));
    });

    test('a curve through a lowered midpoint darkens the middle grey', () {
      final curve = const ToneCurve().inserted(0.5, 0.35)!.$1;
      final p = centre(
        solidJpeg(8, 8, 128, 128, 128),
        Adjustments(curves: ToneCurves(rgb: curve)),
      );
      expect(p.r, inInclusiveRange(84, 96));
    });

    test('a vignette darkens the corners, not the middle', () {
      final out = render(
        solidJpeg(64, 48, 180, 180, 180),
        look(const Adjustments(vignette: -1)),
      );
      expect(out.getPixel(32, 24).r, greaterThan(170));
      expect(out.getPixel(0, 0).r, lessThan(90));
    });

    test('grain moves pixels both ways and averages out', () {
      final out = render(
        solidJpeg(64, 64, 128, 128, 128),
        look(const Adjustments(grain: 1)),
      );
      var sum = 0, min = 255, max = 0;
      for (final p in out) {
        final v = p.r.toInt();
        sum += v;
        if (v < min) min = v;
        if (v > max) max = v;
      }
      expect(sum / (64 * 64), closeTo(128, 4));
      expect(max - min, greaterThan(20));
    });
  });

  group('tone curve', () {
    test('goes through its points and never overshoots', () {
      final curve = const ToneCurve()
          .inserted(0.25, 0.4)!
          .$1
          .inserted(0.75, 0.6)!
          .$1;
      final t = curve.table(1001);
      expect(t[250], closeTo(0.4, 1e-3));
      expect(t[750], closeTo(0.6, 1e-3));
      for (var i = 1; i < t.length; i++) {
        expect(t[i], greaterThanOrEqualTo(t[i - 1] - 1e-6));
      }
    });

    test('end points move only up and down; the middle stays ordered', () {
      final c = const ToneCurve().inserted(0.5, 0.5)!.$1;
      final moved = c.moved(0, 0.3, 0.1);
      expect(moved.points.first, const CurvePoint(0, 0.1));
      final squeezed = c.moved(1, 0.99, 0.5);
      expect(squeezed.points[1].x, lessThan(1));
      expect(c.removed(0), c);
      expect(c.removed(1), const ToneCurve());
    });
  });
}
