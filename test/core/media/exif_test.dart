import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mialuna/core/media/exif.dart';

void main() {
  group('ExifStripper', () {
    test('removes GPS EXIF from JPEG', () {
      final image = img.Image(width: 8, height: 8);
      image.exif.gpsIfd.gpsLatitude = 41.89;
      image.exif.gpsIfd.gpsLatitudeRef = 'N';
      image.exif.gpsIfd.gpsLongitude = 12.49;
      image.exif.gpsIfd.gpsLongitudeRef = 'E';
      final withExif = Uint8List.fromList(img.encodeJpg(image));
      expect(ExifStripper.hasGpsData(withExif), true);

      final (clean, mime) = ExifStripper.strip(withExif, 'image/jpeg');
      expect(mime, 'image/jpeg');
      expect(ExifStripper.hasGpsData(clean), false);
      // Still a valid image of the same size.
      final decoded = img.decodeImage(clean);
      expect(decoded?.width, 8);
    });

    test('non-image bytes pass through untouched', () {
      final video = Uint8List.fromList([0, 0, 0, 24, 102, 116, 121, 112]);
      final (out, mime) = ExifStripper.strip(video, 'video/mp4');
      expect(out, video);
      expect(mime, 'video/mp4');
    });

    test('undecodable images fall back to original bytes', () {
      final garbage = Uint8List.fromList([1, 2, 3]);
      final (out, mime) = ExifStripper.strip(garbage, 'image/jpeg');
      expect(out, garbage);
      expect(mime, 'image/jpeg');
    });
  });
}
