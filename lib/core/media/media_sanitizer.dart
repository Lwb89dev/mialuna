import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image/image.dart' as img;

import '../../l10n/strings.dart';

/// The real container format of a file, detected from its bytes (never from
/// the file name or the declared MIME type).
enum MediaFormat { jpeg, png, gif, webp, mp4, webm, heif, unknown }

/// A file that is safe to upload: every metadata block that can carry
/// location, device or author information was removed.
class SanitizedMedia {
  final Uint8List bytes;
  final String mimeType;
  final int? width;
  final int? height;

  /// True when the pixels had to be re-encoded (rotated EXIF orientation,
  /// HEIC/AVIF conversion); false for lossless byte-level cleaning.
  final bool reencoded;

  const SanitizedMedia({
    required this.bytes,
    required this.mimeType,
    this.width,
    this.height,
    this.reencoded = false,
  });
}

/// Why a file could not be cleaned. Cleaning runs in an isolate, so only the
/// code (and a technical [detail]) travels; the text is resolved in the main
/// isolate, in the user's language.
enum MediaSanitizeError {
  heifNeedsAsync,
  webmUnsupported,
  unknownFormat,
  leftovers,
  processingFailed,
  jpegInvalid,
  jpegTruncated,
  jpegNoSize,
  jpegUndecodable,
  pngTruncated,
  pngInvalid,
  gifInvalid,
  gifTruncated,
  webpTruncated,
  webpInvalid,
  mp4Invalid,
  conversionFailed,
  heifUnsupported,
  privateFileTooLarge,
}

class MediaSanitizeException implements Exception {
  final MediaSanitizeError error;
  final String detail;
  const MediaSanitizeException(this.error, [this.detail = '']);

  String get message {
    final l10n = AppStrings.current;
    return switch (error) {
      MediaSanitizeError.heifNeedsAsync => l10n.sanitizeHeifNeedsAsync,
      MediaSanitizeError.webmUnsupported => l10n.sanitizeWebmUnsupported,
      MediaSanitizeError.unknownFormat => l10n.sanitizeUnknownFormat,
      MediaSanitizeError.leftovers => l10n.sanitizeLeftovers(detail),
      MediaSanitizeError.processingFailed => l10n.sanitizeProcessingFailed(
        detail,
      ),
      MediaSanitizeError.jpegInvalid => l10n.sanitizeJpegInvalid,
      MediaSanitizeError.jpegTruncated => l10n.sanitizeJpegTruncated,
      MediaSanitizeError.jpegNoSize => l10n.sanitizeJpegNoSize,
      MediaSanitizeError.jpegUndecodable => l10n.sanitizeJpegUndecodable,
      MediaSanitizeError.pngTruncated => l10n.sanitizePngTruncated,
      MediaSanitizeError.pngInvalid => l10n.sanitizePngInvalid,
      MediaSanitizeError.gifInvalid => l10n.sanitizeGifInvalid,
      MediaSanitizeError.gifTruncated => l10n.sanitizeGifTruncated,
      MediaSanitizeError.webpTruncated => l10n.sanitizeWebpTruncated,
      MediaSanitizeError.webpInvalid => l10n.sanitizeWebpInvalid,
      MediaSanitizeError.mp4Invalid => l10n.sanitizeMp4Invalid,
      MediaSanitizeError.conversionFailed => l10n.sanitizeConversionFailed,
      MediaSanitizeError.heifUnsupported => l10n.sanitizeHeifUnsupported,
      MediaSanitizeError.privateFileTooLarge => l10n.fileOver100Mb,
    };
  }

  @override
  String toString() => message;
}

/// Removes EXIF, XMP, IPTC, comments, text chunks, location atoms and every
/// other metadata block from photos and videos **before they leave the
/// device**. Works on the bytes themselves — JPEG/PNG/WebP/GIF segments and
/// MP4/MOV boxes are filtered without recompressing the picture.
///
/// The policy is *fail closed*: a file that cannot be cleaned and verified is
/// rejected with a [MediaSanitizeException]; the original is never uploaded
/// as a fallback.
abstract final class MediaSanitizer {
  // ── detection ───────────────────────────────────────────────────────

  static MediaFormat detect(Uint8List b) {
    if (b.length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) {
      return MediaFormat.jpeg;
    }
    if (b.length >= 8 &&
        b[0] == 0x89 &&
        b[1] == 0x50 &&
        b[2] == 0x4E &&
        b[3] == 0x47) {
      return MediaFormat.png;
    }
    if (b.length >= 6 && _ascii(b, 0, 3) == 'GIF') return MediaFormat.gif;
    if (b.length >= 12 &&
        _ascii(b, 0, 4) == 'RIFF' &&
        _ascii(b, 8, 4) == 'WEBP') {
      return MediaFormat.webp;
    }
    if (b.length >= 4 &&
        b[0] == 0x1A &&
        b[1] == 0x45 &&
        b[2] == 0xDF &&
        b[3] == 0xA3) {
      return MediaFormat.webm;
    }
    if (b.length >= 12 && _ascii(b, 4, 4) == 'ftyp') {
      final brand = _ascii(b, 8, 4);
      const heif = {
        'heic',
        'heix',
        'hevc',
        'hevx',
        'mif1',
        'msf1',
        'avif',
        'avis',
      };
      return heif.contains(brand) ? MediaFormat.heif : MediaFormat.mp4;
    }
    return MediaFormat.unknown;
  }

  static String _ascii(Uint8List b, int offset, int length) {
    if (offset + length > b.length) return '';
    return String.fromCharCodes(b.sublist(offset, offset + length));
  }

  // ── public API ──────────────────────────────────────────────────────

  /// Cleans [bytes] synchronously (pure Dart). HEIC/AVIF cannot be handled
  /// here — use [sanitizeAsync].
  static SanitizedMedia sanitize(Uint8List bytes) {
    final SanitizedMedia out;
    switch (detect(bytes)) {
      case MediaFormat.jpeg:
        out = _jpeg(bytes);
      case MediaFormat.png:
        out = _png(bytes);
      case MediaFormat.gif:
        out = _gif(bytes);
      case MediaFormat.webp:
        out = _webp(bytes);
      case MediaFormat.mp4:
        out = _mp4(bytes);
      case MediaFormat.heif:
        throw const MediaSanitizeException(MediaSanitizeError.heifNeedsAsync);
      case MediaFormat.webm:
        throw const MediaSanitizeException(MediaSanitizeError.webmUnsupported);
      case MediaFormat.unknown:
        throw const MediaSanitizeException(MediaSanitizeError.unknownFormat);
    }
    final leftovers = inspect(out.bytes);
    if (leftovers.isNotEmpty) {
      throw MediaSanitizeException(
        MediaSanitizeError.leftovers,
        leftovers.join(', '),
      );
    }
    return out;
  }

  /// Cleans [bytes] off the UI isolate and converts HEIC/AVIF photos to JPEG
  /// through the platform decoder.
  static Future<SanitizedMedia> sanitizeAsync(Uint8List bytes) async {
    final format = detect(bytes);
    if (format == MediaFormat.heif) return _convertWithPlatformDecoder(bytes);
    if (format == MediaFormat.mp4) return sanitize(bytes);
    try {
      return await Isolate.run(() => sanitize(bytes));
    } on MediaSanitizeException {
      rethrow;
    } catch (e) {
      throw MediaSanitizeException(MediaSanitizeError.processingFailed, '$e');
    }
  }

  /// Names the metadata still present in [bytes] (empty = clean). Used as a
  /// final check on every file about to be uploaded.
  static List<String> inspect(Uint8List bytes) {
    try {
      return switch (detect(bytes)) {
        MediaFormat.jpeg => _inspectJpeg(bytes),
        MediaFormat.png => _inspectPng(bytes),
        MediaFormat.gif => _inspectGif(bytes),
        MediaFormat.webp => _inspectWebp(bytes),
        MediaFormat.mp4 => _inspectMp4(bytes),
        _ => ['unsupported-format'],
      };
    } on MediaSanitizeException {
      rethrow;
    } catch (_) {
      return ['unparseable'];
    }
  }

  // ── JPEG ────────────────────────────────────────────────────────────

  static bool _isSof(int marker) =>
      marker >= 0xC0 &&
      marker <= 0xCF &&
      marker != 0xC4 &&
      marker != 0xC8 &&
      marker != 0xCC;

  /// Keeps the segments needed to decode and display the picture, plus the
  /// ICC profile (colour only). Everything else — Exif, XMP, IPTC, comments,
  /// Multi-Picture data, trailing gain-map images — is dropped.
  static bool _keepJpegSegment(int marker, Uint8List b, int start, int end) {
    if (marker >= 0xE1 && marker <= 0xEF) {
      if (marker == 0xE2 && _ascii(b, start, 12) == 'ICC_PROFILE\u0000') {
        return true;
      }
      if (marker == 0xEE && _ascii(b, start, 5) == 'Adobe') return true;
      return false;
    }
    if (marker == 0xFE) return false; // COM
    return true;
  }

  static SanitizedMedia _jpeg(Uint8List b) {
    final out = BytesBuilder(copy: false)..add([0xFF, 0xD8]);
    var i = 2;
    int? width, height;
    var orientation = 1;
    var sawEoi = false;
    while (i < b.length) {
      if (b[i] != 0xFF) {
        throw const MediaSanitizeException(MediaSanitizeError.jpegInvalid);
      }
      while (i < b.length && b[i] == 0xFF) {
        i++;
      }
      if (i >= b.length) break;
      final marker = b[i++];
      if (marker == 0xD9) {
        sawEoi = true;
        out.add([0xFF, 0xD9]);
        break;
      }
      if (marker == 0x01 || (marker >= 0xD0 && marker <= 0xD7)) {
        out.add([0xFF, marker]);
        continue;
      }
      if (i + 2 > b.length) {
        throw const MediaSanitizeException(MediaSanitizeError.jpegTruncated);
      }
      final len = (b[i] << 8) | b[i + 1];
      final segStart = i + 2;
      final segEnd = i + len;
      if (len < 2 || segEnd > b.length) {
        throw const MediaSanitizeException(MediaSanitizeError.jpegTruncated);
      }
      if (_isSof(marker) && segEnd - segStart >= 5) {
        height = (b[segStart + 1] << 8) | b[segStart + 2];
        width = (b[segStart + 3] << 8) | b[segStart + 4];
      }
      if (marker == 0xE1 && _ascii(b, segStart, 6) == 'Exif\u0000\u0000') {
        orientation = _exifOrientation(b, segStart + 6, segEnd);
      }
      if (_keepJpegSegment(marker, b, segStart, segEnd)) {
        out.add([0xFF, marker]);
        out.add(Uint8List.sublistView(b, i, segEnd));
      }
      i = segEnd;
      if (marker == 0xDA) {
        // Entropy-coded scan: runs until the next real marker.
        var j = i;
        while (j < b.length - 1) {
          if (b[j] == 0xFF) {
            final n = b[j + 1];
            if (n == 0x00 || (n >= 0xD0 && n <= 0xD7)) {
              j += 2;
              continue;
            }
            if (n == 0xFF) {
              j++;
              continue;
            }
            break;
          }
          j++;
        }
        if (j >= b.length - 1) j = b.length; // scan ran to the end of file
        out.add(Uint8List.sublistView(b, i, j));
        i = j;
      }
    }
    if (width == null || height == null) {
      throw const MediaSanitizeException(MediaSanitizeError.jpegNoSize);
    }
    if (!sawEoi) out.add([0xFF, 0xD9]);

    final cleaned = out.toBytes();
    if (orientation != 1) {
      // The EXIF orientation is about to disappear, so bake it into the
      // pixels — otherwise the photo would show up rotated.
      final source = img.decodeJpg(b);
      if (source == null) {
        throw const MediaSanitizeException(MediaSanitizeError.jpegUndecodable);
      }
      final baked = img.bakeOrientation(source)..exif = img.ExifData();
      final encoded = Uint8List.fromList(img.encodeJpg(baked, quality: 95));
      return SanitizedMedia(
        bytes: encoded,
        mimeType: 'image/jpeg',
        width: baked.width,
        height: baked.height,
        reencoded: true,
      );
    }
    return SanitizedMedia(
      bytes: cleaned,
      mimeType: 'image/jpeg',
      width: width,
      height: height,
    );
  }

  /// Reads the Orientation tag (0x0112) from a TIFF block; 1 when absent.
  static int _exifOrientation(Uint8List b, int tiffStart, int end) {
    try {
      if (tiffStart + 8 > end) return 1;
      final little = b[tiffStart] == 0x49;
      final data = ByteData.sublistView(b);
      int u16(int o) => data.getUint16(o, little ? Endian.little : Endian.big);
      int u32(int o) => data.getUint32(o, little ? Endian.little : Endian.big);
      final ifd = tiffStart + u32(tiffStart + 4);
      if (ifd + 2 > end) return 1;
      final count = u16(ifd);
      for (var n = 0; n < count; n++) {
        final entry = ifd + 2 + n * 12;
        if (entry + 12 > end) break;
        if (u16(entry) == 0x0112) {
          final v = u16(entry + 8);
          return v >= 1 && v <= 8 ? v : 1;
        }
      }
    } catch (_) {}
    return 1;
  }

  static List<String> _inspectJpeg(Uint8List b) {
    final found = <String>{};
    var i = 2;
    while (i < b.length - 1) {
      if (b[i] != 0xFF) break;
      while (i < b.length && b[i] == 0xFF) {
        i++;
      }
      if (i >= b.length) break;
      final marker = b[i++];
      if (marker == 0xD9) {
        if (i < b.length) found.add('jpeg:trailing-data');
        break;
      }
      if (marker == 0x01 || (marker >= 0xD0 && marker <= 0xD7)) continue;
      if (i + 2 > b.length) break;
      final len = (b[i] << 8) | b[i + 1];
      final segStart = i + 2;
      if (len < 2 || i + len > b.length) break;
      if (marker >= 0xE1 && marker <= 0xEF) {
        final keep =
            (marker == 0xE2 &&
                _ascii(b, segStart, 12) == 'ICC_PROFILE\u0000') ||
            (marker == 0xEE && _ascii(b, segStart, 5) == 'Adobe');
        if (!keep) {
          found.add(
            marker == 0xE1
                ? (_ascii(b, segStart, 4) == 'Exif' ? 'jpeg:exif' : 'jpeg:xmp')
                : 'jpeg:app${marker - 0xE0}',
          );
        }
      }
      if (marker == 0xFE) found.add('jpeg:comment');
      i += len;
      if (marker == 0xDA) {
        var j = i;
        while (j < b.length - 1) {
          if (b[j] == 0xFF) {
            final n = b[j + 1];
            if (n == 0x00 || (n >= 0xD0 && n <= 0xD7)) {
              j += 2;
              continue;
            }
            if (n == 0xFF) {
              j++;
              continue;
            }
            break;
          }
          j++;
        }
        i = j;
      }
    }
    return found.toList();
  }

  // ── PNG ─────────────────────────────────────────────────────────────

  static const _pngKeep = {
    'IHDR',
    'PLTE',
    'IDAT',
    'IEND',
    'tRNS',
    'gAMA',
    'cHRM',
    'sRGB',
    'iCCP',
    'sBIT',
    'bKGD',
    'hIST',
    'pHYs',
    'acTL',
    'fcTL',
    'fdAT',
  };

  static SanitizedMedia _png(Uint8List b) {
    final out = BytesBuilder(copy: false)..add(Uint8List.sublistView(b, 0, 8));
    final data = ByteData.sublistView(b);
    var i = 8;
    int? width, height;
    var sawEnd = false;
    while (i + 12 <= b.length) {
      final len = data.getUint32(i);
      final type = _ascii(b, i + 4, 4);
      final total = 12 + len;
      if (i + total > b.length) {
        throw const MediaSanitizeException(MediaSanitizeError.pngTruncated);
      }
      if (type == 'IHDR' && len >= 8) {
        width = data.getUint32(i + 8);
        height = data.getUint32(i + 12);
      }
      final critical = type.codeUnitAt(0) >= 0x41 && type.codeUnitAt(0) <= 0x5A;
      if (_pngKeep.contains(type) || (critical && type != 'IEND')) {
        out.add(Uint8List.sublistView(b, i, i + total));
      }
      i += total;
      if (type == 'IEND') {
        sawEnd = true;
        break;
      }
    }
    if (!sawEnd || width == null || height == null) {
      throw const MediaSanitizeException(MediaSanitizeError.pngInvalid);
    }
    return SanitizedMedia(
      bytes: out.toBytes(),
      mimeType: 'image/png',
      width: width,
      height: height,
    );
  }

  static List<String> _inspectPng(Uint8List b) {
    final found = <String>{};
    final data = ByteData.sublistView(b);
    var i = 8;
    while (i + 12 <= b.length) {
      final len = data.getUint32(i);
      final type = _ascii(b, i + 4, 4);
      final critical = type.codeUnitAt(0) >= 0x41 && type.codeUnitAt(0) <= 0x5A;
      if (!_pngKeep.contains(type) && !critical) found.add('png:$type');
      i += 12 + len;
    }
    return found.toList();
  }

  // ── GIF ─────────────────────────────────────────────────────────────

  static SanitizedMedia _gif(Uint8List b) {
    if (b.length < 13) {
      throw const MediaSanitizeException(MediaSanitizeError.gifInvalid);
    }
    final data = ByteData.sublistView(b);
    final width = data.getUint16(6, Endian.little);
    final height = data.getUint16(8, Endian.little);
    final out = BytesBuilder(copy: false);
    var i = 13;
    final packed = b[10];
    if (packed & 0x80 != 0) i += 3 * (1 << ((packed & 7) + 1));
    out.add(Uint8List.sublistView(b, 0, i));
    var sawTrailer = false;
    while (i < b.length) {
      final block = b[i];
      if (block == 0x3B) {
        out.add([0x3B]);
        sawTrailer = true;
        break;
      }
      if (block == 0x21) {
        if (i + 2 > b.length) {
          throw const MediaSanitizeException(MediaSanitizeError.gifTruncated);
        }
        final label = b[i + 1];
        final end = _gifSubBlocksEnd(b, i + 2);
        var keep = label == 0xF9; // graphic control
        if (label == 0xFF && i + 14 < b.length) {
          final app = _ascii(b, i + 3, 11);
          keep = app == 'NETSCAPE2.0' || app == 'ANIMEXTS1.0';
        }
        if (keep) out.add(Uint8List.sublistView(b, i, end));
        i = end;
      } else if (block == 0x2C) {
        if (i + 10 > b.length) {
          throw const MediaSanitizeException(MediaSanitizeError.gifTruncated);
        }
        var p = i + 10;
        final lp = b[i + 9];
        if (lp & 0x80 != 0) p += 3 * (1 << ((lp & 7) + 1));
        p += 1; // LZW minimum code size
        final end = _gifSubBlocksEnd(b, p);
        out.add(Uint8List.sublistView(b, i, end));
        i = end;
      } else {
        throw const MediaSanitizeException(MediaSanitizeError.gifInvalid);
      }
    }
    if (!sawTrailer) {
      throw const MediaSanitizeException(MediaSanitizeError.gifTruncated);
    }
    return SanitizedMedia(
      bytes: out.toBytes(),
      mimeType: 'image/gif',
      width: width,
      height: height,
    );
  }

  static int _gifSubBlocksEnd(Uint8List b, int start) {
    var p = start;
    while (p < b.length) {
      final n = b[p];
      p += 1 + n;
      if (n == 0) return p;
    }
    throw const MediaSanitizeException(MediaSanitizeError.gifTruncated);
  }

  static List<String> _inspectGif(Uint8List b) {
    final found = <String>{};
    var i = 13;
    final packed = b[10];
    if (packed & 0x80 != 0) i += 3 * (1 << ((packed & 7) + 1));
    while (i < b.length) {
      final block = b[i];
      if (block == 0x3B) break;
      if (block == 0x21) {
        final label = b[i + 1];
        final end = _gifSubBlocksEnd(b, i + 2);
        if (label == 0xFE) found.add('gif:comment');
        if (label == 0x01) found.add('gif:text');
        if (label == 0xFF) {
          final app = _ascii(b, i + 3, 11);
          if (app != 'NETSCAPE2.0' && app != 'ANIMEXTS1.0') {
            found.add('gif:app');
          }
        }
        i = end;
      } else if (block == 0x2C) {
        var p = i + 10;
        final lp = b[i + 9];
        if (lp & 0x80 != 0) p += 3 * (1 << ((lp & 7) + 1));
        i = _gifSubBlocksEnd(b, p + 1);
      } else {
        break;
      }
    }
    return found.toList();
  }

  // ── WebP ────────────────────────────────────────────────────────────

  static const _webpKeep = {
    'VP8 ',
    'VP8L',
    'VP8X',
    'ALPH',
    'ANIM',
    'ANMF',
    'ICCP',
  };

  static SanitizedMedia _webp(Uint8List b) {
    final data = ByteData.sublistView(b);
    final body = BytesBuilder(copy: false);
    var i = 12;
    int? width, height;
    while (i + 8 <= b.length) {
      final type = _ascii(b, i, 4);
      final len = data.getUint32(i + 4, Endian.little);
      final padded = len + (len & 1);
      if (i + 8 + len > b.length) {
        throw const MediaSanitizeException(MediaSanitizeError.webpTruncated);
      }
      final chunkEnd = (i + 8 + padded).clamp(0, b.length);
      if (_webpKeep.contains(type)) {
        if (type == 'VP8X' && len >= 10) {
          final chunk = Uint8List.fromList(b.sublist(i, chunkEnd));
          chunk[8] = chunk[8] & ~0x0C; // clear EXIF (0x08) and XMP (0x04)
          body.add(chunk);
          width = 1 + (b[i + 12] | (b[i + 13] << 8) | (b[i + 14] << 16));
          height = 1 + (b[i + 15] | (b[i + 16] << 8) | (b[i + 17] << 16));
        } else {
          if (type == 'VP8 ' && len >= 10 && width == null) {
            width = (b[i + 14] | (b[i + 15] << 8)) & 0x3FFF;
            height = (b[i + 16] | (b[i + 17] << 8)) & 0x3FFF;
          } else if (type == 'VP8L' && len >= 5 && width == null) {
            final bits =
                b[i + 9] |
                (b[i + 10] << 8) |
                (b[i + 11] << 16) |
                (b[i + 12] << 24);
            width = 1 + (bits & 0x3FFF);
            height = 1 + ((bits >> 14) & 0x3FFF);
          }
          body.add(Uint8List.sublistView(b, i, chunkEnd));
        }
      }
      i = chunkEnd;
    }
    final chunks = body.toBytes();
    if (chunks.isEmpty) {
      throw const MediaSanitizeException(MediaSanitizeError.webpInvalid);
    }
    final out = BytesBuilder(copy: false)
      ..add(utf8.encode('RIFF'))
      ..add(
        (ByteData(
          4,
        )..setUint32(0, chunks.length + 4, Endian.little)).buffer.asUint8List(),
      )
      ..add(utf8.encode('WEBP'))
      ..add(chunks);
    return SanitizedMedia(
      bytes: out.toBytes(),
      mimeType: 'image/webp',
      width: width,
      height: height,
    );
  }

  static List<String> _inspectWebp(Uint8List b) {
    final found = <String>{};
    final data = ByteData.sublistView(b);
    var i = 12;
    while (i + 8 <= b.length) {
      final type = _ascii(b, i, 4);
      final len = data.getUint32(i + 4, Endian.little);
      if (!_webpKeep.contains(type)) found.add('webp:${type.trim()}');
      if (type == 'VP8X' && len >= 1 && (b[i + 8] & 0x0C) != 0) {
        found.add('webp:vp8x-flags');
      }
      i += 8 + len + (len & 1);
    }
    return found.toList();
  }

  // ── MP4 / MOV ───────────────────────────────────────────────────────

  static const _mp4Containers = {'moov', 'trak', 'mdia'};
  static const _mp4Strip = {'udta', 'meta', 'uuid', 'XMP_', 'Xtra', 'smta'};

  /// Neutralises metadata boxes in place: each one becomes a `free` box with
  /// a zeroed payload, so every offset in the file stays valid.
  static SanitizedMedia _mp4(Uint8List input) {
    final b = Uint8List.fromList(input);
    final brand = _ascii(b, 8, 4);
    var sawMoov = false, sawMdat = false;
    final end = _walkMp4(b, 0, b.length, 0, (type) {
      if (type == 'moov') sawMoov = true;
      if (type == 'mdat') sawMdat = true;
    });
    if (!sawMoov || !sawMdat) {
      throw const MediaSanitizeException(MediaSanitizeError.mp4Invalid);
    }
    // Unknown bytes after the last box (vendor trailers) are dropped.
    final cleaned = end < b.length ? Uint8List.sublistView(b, 0, end) : b;
    return SanitizedMedia(
      bytes: cleaned,
      mimeType: brand == 'qt  ' ? 'video/quicktime' : 'video/mp4',
    );
  }

  /// Returns the offset where the valid box chain ends.
  static int _walkMp4(
    Uint8List b,
    int start,
    int end,
    int depth,
    void Function(String type) onBox,
  ) {
    final data = ByteData.sublistView(b);
    var i = start;
    while (i + 8 <= end) {
      var size = data.getUint32(i);
      final type = _ascii(b, i + 4, 4);
      var header = 8;
      if (size == 1) {
        if (i + 16 > end) return i;
        size = data.getUint64(i + 8);
        header = 16;
      } else if (size == 0) {
        size = end - i;
      }
      if (size < header || i + size > end) return i;
      if (depth == 0) onBox(type);
      if (_mp4Strip.contains(type)) {
        // Rename to `free` and zero the payload.
        b[i + 4] = 0x66;
        b[i + 5] = 0x72;
        b[i + 6] = 0x65;
        b[i + 7] = 0x65;
        for (var k = i + header; k < i + size; k++) {
          b[k] = 0;
        }
      } else if (_mp4Containers.contains(type)) {
        _walkMp4(b, i + header, i + size, depth + 1, onBox);
      } else if (type == 'mvhd' || type == 'tkhd' || type == 'mdhd') {
        // Creation/modification timestamps.
        final version = b[i + header];
        final span = version == 1 ? 16 : 8;
        for (var k = 0; k < span && i + header + 4 + k < i + size; k++) {
          b[i + header + 4 + k] = 0;
        }
      }
      i += size;
    }
    return i;
  }

  static final _iso6709 = RegExp(r'[+-]\d{2,3}\.\d{2,}[+-]\d{2,3}\.\d{2,}');

  static List<String> _inspectMp4(Uint8List b) {
    final found = <String>{};
    final data = ByteData.sublistView(b);
    void walk(int start, int end, int depth) {
      var i = start;
      while (i + 8 <= end) {
        var size = data.getUint32(i);
        final type = _ascii(b, i + 4, 4);
        var header = 8;
        if (size == 1) {
          if (i + 16 > end) return;
          size = data.getUint64(i + 8);
          header = 16;
        } else if (size == 0) {
          size = end - i;
        }
        if (size < header || i + size > end) return;
        if (_mp4Strip.contains(type)) found.add('mp4:$type');
        if (_mp4Containers.contains(type)) {
          walk(i + header, i + size, depth + 1);
        }
        if (type == 'moov') {
          final text = latin1.decode(
            Uint8List.sublistView(b, i, i + size),
            allowInvalid: true,
          );
          if (_iso6709.hasMatch(text)) found.add('mp4:gps-string');
        }
        i += size;
      }
    }

    walk(0, b.length, 0);
    return found.toList();
  }

  // ── HEIC / AVIF ─────────────────────────────────────────────────────

  /// Decodes with the platform codec (which understands HEIC/AVIF) and
  /// re-encodes as a clean JPEG: pixels only, no metadata can survive.
  static Future<SanitizedMedia> _convertWithPlatformDecoder(
    Uint8List bytes,
  ) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final raw = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final width = image.width;
      final height = image.height;
      image.dispose();
      codec.dispose();
      if (raw == null) {
        throw const MediaSanitizeException(MediaSanitizeError.conversionFailed);
      }
      final rgba = raw.buffer.asUint8List();
      final jpeg = await Isolate.run(() {
        final decoded = img.Image.fromBytes(
          width: width,
          height: height,
          bytes: rgba.buffer,
          numChannels: 4,
          order: img.ChannelOrder.rgba,
        );
        return Uint8List.fromList(img.encodeJpg(decoded, quality: 92));
      });
      return SanitizedMedia(
        bytes: jpeg,
        mimeType: 'image/jpeg',
        width: width,
        height: height,
        reencoded: true,
      );
    } on MediaSanitizeException {
      rethrow;
    } catch (_) {
      throw const MediaSanitizeException(MediaSanitizeError.heifUnsupported);
    }
  }
}
