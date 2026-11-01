import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Strips EXIF and other metadata (including GPS location) from images by
/// decoding and re-encoding them. Applied by default before every upload.
/// Non-image bytes (e.g. videos) pass through untouched.
class ExifStripper {
  /// Returns (bytes, mimeType). Falls back to the original bytes when the
  /// format is not decodable — safer to send the original than to break the
  /// upload.
  static (Uint8List, String) strip(Uint8List bytes, String mimeType) {
    if (!mimeType.startsWith('image/')) return (bytes, mimeType);
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return (bytes, mimeType);
      decoded.exif = img.ExifData(); // drop all EXIF, incl. GPS
      if (mimeType == 'image/png') {
        return (Uint8List.fromList(img.encodePng(decoded)), mimeType);
      }
      // Default: high-quality JPEG re-encode.
      return (
        Uint8List.fromList(img.encodeJpg(decoded, quality: 92)),
        'image/jpeg',
      );
    } catch (_) {
      return (bytes, mimeType);
    }
  }

  /// True when the bytes still contain GPS EXIF data (privacy risk).
  static bool hasGpsData(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      return decoded?.exif.gpsIfd.isEmpty == false;
    } catch (_) {
      return false;
    }
  }
}
