import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mialuna/features/create/editor/crop_tool.dart';
import 'package:mialuna/features/create/editor/image_edit_apply.dart';

Uint8List solidJpeg(int width, int height, int r, int g, int b) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(r, g, b));
  return Uint8List.fromList(img.encodeJpg(image, quality: 100));
}

void main() {
  test('identity edit keeps the image dimensions', () {
    final out = applyImageEdit(
      solidJpeg(40, 30, 200, 100, 50),
      const ImageEdit(),
    );
    final decoded = img.decodeImage(out)!;
    expect(decoded.width, 40);
    expect(decoded.height, 30);
  });

  test('crop halves the picture in fractions', () {
    final out = applyImageEdit(
      solidJpeg(40, 30, 200, 100, 50),
      const ImageEdit(crop: Crop(left: 0.25, top: 0, right: 0.75, bottom: 1)),
    );
    final decoded = img.decodeImage(out)!;
    expect(decoded.width, 20);
    expect(decoded.height, 30);
  });

  test('a quarter turn swaps width and height', () {
    final out = applyImageEdit(
      solidJpeg(40, 30, 200, 100, 50),
      const ImageEdit(quarterTurns: 1),
    );
    final decoded = img.decodeImage(out)!;
    expect(decoded.width, 30);
    expect(decoded.height, 40);
  });

  test('rotation then crop applies in rotated space', () {
    final out = applyImageEdit(
      solidJpeg(40, 30, 200, 100, 50),
      const ImageEdit(
        quarterTurns: 1,
        crop: Crop(left: 0, top: 0, right: 1, bottom: 0.5),
      ),
    );
    final decoded = img.decodeImage(out)!;
    expect(decoded.width, 30);
    expect(decoded.height, 20);
  });

  test('positive brightness brightens a solid color', () {
    final out = applyImageEdit(
      solidJpeg(8, 8, 100, 100, 100),
      const ImageEdit(brightness: 0.5),
    );
    final decoded = img.decodeImage(out)!;
    final pixel = decoded.getPixel(4, 4);
    expect(pixel.r.toInt(), greaterThan(100));
  });

  test('zero saturation turns color to gray', () {
    final out = applyImageEdit(
      solidJpeg(8, 8, 200, 50, 50),
      const ImageEdit(saturation: -1),
    );
    final decoded = img.decodeImage(out)!;
    final pixel = decoded.getPixel(4, 4);
    expect((pixel.r - pixel.g).abs(), lessThan(4));
    expect((pixel.g - pixel.b).abs(), lessThan(4));
  });

  test('undecodable bytes pass through untouched', () {
    final garbage = Uint8List.fromList([1, 2, 3]);
    expect(applyImageEdit(garbage, const ImageEdit()), garbage);
  });
}
