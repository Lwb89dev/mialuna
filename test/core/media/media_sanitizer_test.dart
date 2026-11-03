import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mialuna/core/media/media_sanitizer.dart';

Uint8List bytesOf(List<int> l) => Uint8List.fromList(l);

bool has(Uint8List haystack, String needle) =>
    latin1.decode(haystack, allowInvalid: true).contains(needle);

/// A JPEG that carries everything a phone camera would put in it.
Uint8List dirtyJpeg({int orientation = 1, int width = 12, int height = 6}) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(200, 80, 40));
  image.exif.gpsIfd.gpsLatitude = 41.89;
  image.exif.gpsIfd.gpsLatitudeRef = 'N';
  image.exif.gpsIfd.gpsLongitude = 12.49;
  image.exif.gpsIfd.gpsLongitudeRef = 'E';
  image.exif.imageIfd.make = 'SecretPhoneCo';
  image.exif.imageIfd.model = 'Model-X';
  image.exif.imageIfd.orientation = orientation;
  final base = img.encodeJpg(image, quality: 90);
  final out = BytesBuilder()..add(base.sublist(0, 2)); // SOI
  void segment(int marker, List<int> payload) {
    final len = payload.length + 2;
    out
      ..add([0xFF, marker, len >> 8, len & 0xFF])
      ..add(payload);
  }

  segment(0xE1, [
    ...ascii.encode('http://ns.adobe.com/xap/1.0/\u0000'),
    ...ascii.encode('<x:xmpmeta>LOCATION-XMP</x:xmpmeta>'),
  ]);
  segment(0xFE, ascii.encode('comment-with-name-Mario'));
  segment(0xED, [
    ...ascii.encode('Photoshop 3.0\u0000'),
    ...ascii.encode('IPTC-CAPTION'),
  ]);
  out.add(base.sublist(2));
  // A Pixel "Ultra HDR" style secondary image appended after the EOI.
  out.add(ascii.encode('TRAILING-GAINMAP-WITH-EXIF'));
  return out.toBytes();
}

int crc32(List<int> data) {
  var c = 0xFFFFFFFF;
  for (final b in data) {
    c ^= b;
    for (var k = 0; k < 8; k++) {
      c = (c & 1) != 0 ? (c >>> 1) ^ 0xEDB88320 : c >>> 1;
    }
  }
  return c ^ 0xFFFFFFFF;
}

Uint8List pngChunk(String type, List<int> data) {
  final body = [...ascii.encode(type), ...data];
  final out = BytesBuilder()
    ..add((ByteData(4)..setUint32(0, data.length)).buffer.asUint8List())
    ..add(body)
    ..add((ByteData(4)..setUint32(0, crc32(body))).buffer.asUint8List());
  return out.toBytes();
}

Uint8List box(String type, List<int> payload) {
  final out = BytesBuilder()
    ..add((ByteData(4)..setUint32(0, payload.length + 8)).buffer.asUint8List())
    ..add(latin1.encode(type))
    ..add(payload);
  return out.toBytes();
}

/// ftyp + moov(mvhd, trak(tkhd, udta(©xyz)), udta(©xyz), meta) + mdat.
Uint8List dirtyMp4({List<int> trailing = const []}) {
  final times = ByteData(100);
  times.setUint32(4, 3700000000); // creation
  times.setUint32(8, 3700000001); // modification
  final mvhd = box('mvhd', times.buffer.asUint8List());
  final tkhd = box('tkhd', times.buffer.asUint8List());
  final gps = box('©xyz', ascii.encode('+41.8900+012.4900/'));
  final trak = box('trak', [...tkhd, ...box('udta', gps)]);
  final udta = box('udta', gps);
  final meta = box(
    'meta',
    ascii.encode('com.apple.quicktime.location.ISO6709 +41.8900+012.4900/'),
  );
  final moov = box('moov', [...mvhd, ...trak, ...udta, ...meta]);
  final ftyp = box('ftyp', [
    ...ascii.encode('isom'),
    0,
    0,
    2,
    0,
    ...ascii.encode('isomiso2mp41'),
  ]);
  final mdat = box('mdat', List.filled(64, 7));
  return bytesOf([...ftyp, ...moov, ...mdat, ...trailing]);
}

void main() {
  group('detects the real format from the bytes', () {
    test('by magic numbers, not by name', () {
      expect(MediaSanitizer.detect(dirtyJpeg()), MediaFormat.jpeg);
      expect(
        MediaSanitizer.detect(
          bytesOf(img.encodePng(img.Image(width: 2, height: 2))),
        ),
        MediaFormat.png,
      );
      expect(MediaSanitizer.detect(dirtyMp4()), MediaFormat.mp4);
      expect(MediaSanitizer.detect(bytesOf([1, 2, 3])), MediaFormat.unknown);
      expect(
        MediaSanitizer.detect(
          bytesOf([
            ...box('ftyp', [...ascii.encode('heic'), 0, 0, 0, 0]),
          ]),
        ),
        MediaFormat.heif,
      );
    });
  });

  group('JPEG', () {
    test(
      'removes GPS, device data, XMP, IPTC, comments and trailing images',
      () {
        final dirty = dirtyJpeg();
        expect(has(dirty, 'SecretPhoneCo'), true);
        expect(has(dirty, 'LOCATION-XMP'), true);
        expect(MediaSanitizer.inspect(dirty), isNotEmpty);

        final clean = MediaSanitizer.sanitize(dirty);
        for (final secret in [
          'Exif',
          'SecretPhoneCo',
          'Model-X',
          'LOCATION-XMP',
          'IPTC-CAPTION',
          'comment-with-name-Mario',
          'TRAILING-GAINMAP',
        ]) {
          expect(has(clean.bytes, secret), false, reason: '$secret survived');
        }
        expect(MediaSanitizer.inspect(clean.bytes), isEmpty);
        expect(clean.mimeType, 'image/jpeg');
        expect(clean.reencoded, false); // lossless: pixels untouched
      },
    );

    test('keeps the picture intact and reports its size', () {
      final clean = MediaSanitizer.sanitize(dirtyJpeg(width: 12, height: 6));
      final decoded = img.decodeJpg(clean.bytes)!;
      expect(decoded.width, 12);
      expect(decoded.height, 6);
      expect(clean.width, 12);
      expect(clean.height, 6);
      expect(decoded.exif.gpsIfd.isEmpty, true);
      // The pixel stream is byte-for-byte what the camera produced.
      final original = img.decodeJpg(dirtyJpeg())!;
      expect(decoded.getPixel(3, 3).r, original.getPixel(3, 3).r);
    });

    test('bakes the EXIF rotation into the pixels before dropping it', () {
      // Orientation 6 = rotate 90° clockwise: 12x6 on disk is shown 6x12.
      final clean = MediaSanitizer.sanitize(dirtyJpeg(orientation: 6));
      expect(clean.reencoded, true);
      final decoded = img.decodeJpg(clean.bytes)!;
      expect(decoded.width, 6);
      expect(decoded.height, 12);
      expect(clean.width, 6);
      expect(clean.height, 12);
      expect(MediaSanitizer.inspect(clean.bytes), isEmpty);
    });

    test('fails closed on a truncated file', () {
      final dirty = dirtyJpeg();
      expect(
        () => MediaSanitizer.sanitize(Uint8List.sublistView(dirty, 0, 30)),
        throwsA(isA<MediaSanitizeException>()),
      );
    });
  });

  group('PNG', () {
    Uint8List dirtyPng() {
      final plain = img.encodePng(img.Image(width: 5, height: 3));
      // Insert text + EXIF + time chunks right before IEND (the last 12 bytes).
      final end = plain.length - 12;
      return bytesOf([
        ...plain.sublist(0, end),
        ...pngChunk('tEXt', ascii.encode('Author\u0000Mario Rossi')),
        ...pngChunk('eXIf', ascii.encode('GPS-IN-EXIF')),
        ...pngChunk('tIME', List.filled(7, 1)),
        ...plain.sublist(end),
      ]);
    }

    test('drops text, EXIF and time chunks, keeps the image', () {
      final dirty = dirtyPng();
      expect(has(dirty, 'Mario Rossi'), true);
      final clean = MediaSanitizer.sanitize(dirty);
      expect(has(clean.bytes, 'Mario Rossi'), false);
      expect(has(clean.bytes, 'GPS-IN-EXIF'), false);
      expect(MediaSanitizer.inspect(clean.bytes), isEmpty);
      final decoded = img.decodePng(clean.bytes)!;
      expect(decoded.width, 5);
      expect(decoded.height, 3);
      expect(clean.mimeType, 'image/png');
    });
  });

  group('WebP', () {
    Uint8List chunk(String type, List<int> payload) {
      final out = BytesBuilder()
        ..add(ascii.encode(type))
        ..add(
          (ByteData(
            4,
          )..setUint32(0, payload.length, Endian.little)).buffer.asUint8List(),
        )
        ..add(payload);
      if (payload.length.isOdd) out.addByte(0);
      return out.toBytes();
    }

    test('removes EXIF and XMP chunks and clears the VP8X flags', () {
      final vp8x = chunk('VP8X', [
        0x1C,
        0,
        0,
        0,
        9,
        0,
        0,
        4,
        0,
        0,
      ]); // 10x5, EXIF+XMP+alpha
      final vp8 = chunk('VP8 ', [0, 0, 0, 0x9D, 0x01, 0x2A, 10, 0, 5, 0, 0, 0]);
      final exif = chunk('EXIF', ascii.encode('GPS-WEBP'));
      final xmp = chunk('XMP ', ascii.encode('XMP-WEBP'));
      final body = [...ascii.encode('WEBP'), ...vp8x, ...vp8, ...exif, ...xmp];
      final webp = bytesOf([
        ...ascii.encode('RIFF'),
        ...(ByteData(
          4,
        )..setUint32(0, body.length, Endian.little)).buffer.asUint8List(),
        ...body,
      ]);
      expect(MediaSanitizer.detect(webp), MediaFormat.webp);
      expect(has(webp, 'GPS-WEBP'), true);

      final clean = MediaSanitizer.sanitize(webp);
      expect(has(clean.bytes, 'GPS-WEBP'), false);
      expect(has(clean.bytes, 'XMP-WEBP'), false);
      expect(MediaSanitizer.inspect(clean.bytes), isEmpty);
      // RIFF size is consistent with what is left.
      final size = ByteData.sublistView(clean.bytes)
          .getUint32(4, Endian.little);
      expect(size, clean.bytes.length - 8);
      // VP8X flags no longer announce EXIF/XMP; alpha is kept.
      expect(clean.bytes[20] & 0x0C, 0);
      expect(clean.bytes[20] & 0x10, 0x10);
      expect(clean.width, 10);
      expect(clean.height, 5);
    });
  });

  /// A picture that tells its own orientation: 4 x 2 blocks of 8 px, each a
  /// colour of its own, so where every block ends up shows how it was turned.
  group('orientation', () {
    const colours = [
      [255, 0, 0],
      [0, 255, 0],
      [0, 0, 255],
      [255, 255, 0],
      [0, 255, 255],
      [255, 0, 255],
      [255, 128, 0],
      [128, 0, 255],
    ];
    const blocksWide = 4, blocksHigh = 2;

    img.Image stored() {
      final image = img.Image(width: 32, height: 16);
      for (var by = 0; by < blocksHigh; by++) {
        for (var bx = 0; bx < blocksWide; bx++) {
          final c = colours[bx + by * blocksWide];
          img.fillRect(
            image,
            x1: bx * 8,
            y1: by * 8,
            x2: bx * 8 + 8,
            y2: by * 8 + 8,
            color: img.ColorRgb8(c[0], c[1], c[2]),
          );
        }
      }
      return image;
    }

    /// Which block of the picture on disk shows at block ([dx], [dy]) of the
    /// picture as it is meant to be seen: the eight EXIF orientations.
    (int, int) source(int orientation, int dx, int dy) {
      const w = blocksWide, h = blocksHigh;
      return switch (orientation) {
        1 => (dx, dy),
        2 => (w - 1 - dx, dy),
        3 => (w - 1 - dx, h - 1 - dy),
        4 => (dx, h - 1 - dy),
        5 => (dy, dx),
        6 => (dy, h - 1 - dx),
        7 => (w - 1 - dy, h - 1 - dx),
        _ => (w - 1 - dy, dx),
      };
    }

    /// The blocks of [shown] are the ones the orientation asks for.
    void expectUpright(img.Image shown, int orientation, {int tolerance = 24}) {
      final turned = orientation >= 5;
      expect(shown.width, turned ? 16 : 32, reason: 'width, orientation $orientation');
      expect(shown.height, turned ? 32 : 16, reason: 'height, orientation $orientation');
      final across = shown.width ~/ 8, down = shown.height ~/ 8;
      for (var dy = 0; dy < down; dy++) {
        for (var dx = 0; dx < across; dx++) {
          final (sx, sy) = source(orientation, dx, dy);
          final want = colours[sx + sy * blocksWide];
          final got = shown.getPixel(dx * 8 + 4, dy * 8 + 4);
          for (final (i, channel) in [got.r, got.g, got.b].indexed) {
            expect(
              (channel - want[i]).abs(),
              lessThanOrEqualTo(tolerance),
              reason: 'block ($dx,$dy) should be the one at ($sx,$sy), '
                  'orientation $orientation',
            );
          }
        }
      }
    }

    /// A TIFF block (what an `eXIf` or `EXIF` chunk holds) saying [orientation].
    List<int> tiff(int orientation) => [
      ...ascii.encode('MM'), 0, 42, 0, 0, 0, 8, // header, IFD at 8
      0, 1, // one entry
      0x01, 0x12, 0, 3, 0, 0, 0, 1, 0, orientation, 0, 0, // Orientation: SHORT
      0, 0, 0, 0, // no next IFD
    ];

    for (var o = 1; o <= 8; o++) {
      test('a JPEG with orientation $o comes out the right way up', () {
        final source = stored();
        source.exif.imageIfd.orientation = o;
        final clean = MediaSanitizer.sanitize(
          bytesOf(img.encodeJpg(source, quality: 95)),
        );
        expect(MediaSanitizer.inspect(clean.bytes), isEmpty);
        final shown = img.decodeJpg(clean.bytes)!;
        expect(shown.exif.imageIfd.hasOrientation, false);
        expectUpright(shown, o);
        expect(clean.width, shown.width);
        expect(clean.height, shown.height);
      });

      test('a PNG with orientation $o comes out the right way up', () {
        final plain = img.encodePng(stored());
        final end = plain.length - 12;
        final dirty = bytesOf([
          ...plain.sublist(0, end),
          ...pngChunk('eXIf', tiff(o)),
          ...plain.sublist(end),
        ]);
        final clean = MediaSanitizer.sanitize(dirty);
        expect(clean.mimeType, 'image/png');
        expect(MediaSanitizer.inspect(clean.bytes), isEmpty);
        expect(has(clean.bytes, 'eXIf'), false);
        expectUpright(img.decodePng(clean.bytes)!, o, tolerance: 0);
        expect(clean.reencoded, o != 1);
      });
    }

    test('a WebP that says "turn me" is turned, and becomes a PNG', () {
      // Written by a real encoder (lossless, EXIF orientation 6).
      final webp = base64Decode('UklGRoYAAABXRUJQVlA4WAoAAAAIAAAAHwAADwAAVlA4TEUAAAAvH8ADAD9AkG3Tmd/8GgSSNjYfT34BQZH/o81/8IM4gRkrBta0bQVKIYUUUkghhVEYf4D+94nof5xqYWBX783q4sdXvQcARVhJRhoAAABNTQAqAAAACAABARIAAwAAAAEABgAAAAAAAA==');
      expect(has(webp, 'EXIF'), true);
      final clean = MediaSanitizer.sanitize(webp);
      expect(clean.mimeType, 'image/png');
      expect(has(clean.bytes, 'EXIF'), false);
      expectUpright(img.decodePng(clean.bytes)!, 6, tolerance: 0);
      expect(MediaSanitizer.inspect(clean.bytes), isEmpty);
    });

    test('an upright PNG is left alone, byte for byte but for the metadata', () {
      final plain = img.encodePng(stored());
      final end = plain.length - 12;
      final clean = MediaSanitizer.sanitize(
        bytesOf([
          ...plain.sublist(0, end),
          ...pngChunk('eXIf', tiff(1)),
          ...plain.sublist(end),
        ]),
      );
      expect(clean.reencoded, false);
      expect(clean.bytes, plain);
    });

    test('a nonsense orientation is taken for none', () {
      final plain = img.encodePng(stored());
      final end = plain.length - 12;
      final clean = MediaSanitizer.sanitize(
        bytesOf([
          ...plain.sublist(0, end),
          ...pngChunk('eXIf', tiff(9)),
          ...plain.sublist(end),
        ]),
      );
      expect(clean.reencoded, false);
      expectUpright(img.decodePng(clean.bytes)!, 1, tolerance: 0);
    });
  });

  group('GIF', () {
    test('drops comment extensions, keeps the animation data', () {
      final gif = img.encodeGif(img.Image(width: 4, height: 4));
      // Header(6) + LSD(7) [+ GCT], then a comment extension after it.
      final packed = gif[10];
      var at = 13;
      if (packed & 0x80 != 0) at += 3 * (1 << ((packed & 7) + 1));
      final dirty = bytesOf([
        ...gif.sublist(0, at),
        0x21,
        0xFE,
        0x0B,
        ...ascii.encode('Mario-Rossi'),
        0x00,
        ...gif.sublist(at),
      ]);
      expect(has(dirty, 'Mario-Rossi'), true);
      final clean = MediaSanitizer.sanitize(dirty);
      expect(has(clean.bytes, 'Mario-Rossi'), false);
      expect(MediaSanitizer.inspect(clean.bytes), isEmpty);
      expect(img.decodeGif(clean.bytes)!.width, 4);
    });
  });

  group('MP4 / MOV', () {
    test('wipes location atoms and timestamps without moving anything', () {
      final dirty = dirtyMp4();
      expect(has(dirty, '+41.8900+012.4900'), true);
      expect(MediaSanitizer.inspect(dirty), isNotEmpty);

      final clean = MediaSanitizer.sanitize(dirty);
      expect(has(clean.bytes, '41.89'), false);
      expect(has(clean.bytes, 'ISO6709'), false);
      expect(MediaSanitizer.inspect(clean.bytes), isEmpty);
      // Same layout: chunk offsets inside the file stay valid.
      expect(clean.bytes.length, dirty.length);
      expect(clean.mimeType, 'video/mp4');
      // mdat payload untouched.
      expect(clean.bytes.sublist(clean.bytes.length - 8), List.filled(8, 7));
      // Creation/modification times are zeroed (mvhd right after moov's header).
      final moov = has(clean.bytes, 'moov');
      expect(moov, true);
      final mvhdAt = latin1
          .decode(clean.bytes, allowInvalid: true)
          .indexOf('mvhd');
      expect(clean.bytes.sublist(mvhdAt + 8, mvhdAt + 16), List.filled(8, 0));
    });

    test('drops vendor data glued after the last box', () {
      final dirty = dirtyMp4(
        trailing: ascii.encode('SEFT-SAMSUNG-GPS-TRAILER'),
      );
      final clean = MediaSanitizer.sanitize(dirty);
      expect(has(clean.bytes, 'SAMSUNG-GPS'), false);
      expect(clean.bytes.length, lessThan(dirty.length));
    });

    test('QuickTime movies keep their type', () {
      final qt = dirtyMp4();
      qt.setRange(8, 12, ascii.encode('qt  '));
      expect(MediaSanitizer.sanitize(qt).mimeType, 'video/quicktime');
    });

    test('a video without moov/mdat is refused', () {
      final broken = bytesOf([
        ...box('ftyp', [...ascii.encode('isom'), 0, 0, 0, 0]),
      ]);
      expect(
        () => MediaSanitizer.sanitize(broken),
        throwsA(isA<MediaSanitizeException>()),
      );
    });
  });

  group('fail closed', () {
    test('unknown formats are never uploaded as they are', () {
      expect(
        () => MediaSanitizer.sanitize(bytesOf(List.filled(64, 1))),
        throwsA(isA<MediaSanitizeException>()),
      );
    });

    test(
      'WebM/MKV cannot be cleaned, so it is refused with a clear reason',
      () {
        final webm = bytesOf([0x1A, 0x45, 0xDF, 0xA3, ...List.filled(40, 0)]);
        expect(
          () => MediaSanitizer.sanitize(webm),
          throwsA(
            isA<MediaSanitizeException>().having(
              (e) => e.message,
              'message',
              contains('MP4'),
            ),
          ),
        );
      },
    );

    test('sanitizeAsync gives the same answer off the UI isolate', () async {
      final clean = await MediaSanitizer.sanitizeAsync(dirtyJpeg());
      expect(MediaSanitizer.inspect(clean.bytes), isEmpty);
      await expectLater(
        MediaSanitizer.sanitizeAsync(bytesOf([9, 9, 9, 9, 9])),
        throwsA(isA<MediaSanitizeException>()),
      );
    });
  });
}
