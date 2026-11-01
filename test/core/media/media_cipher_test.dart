import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/media/media_cipher.dart';
import 'package:mialuna/core/nostr/bech32.dart';

void main() {
  group('AES-256-GCM', () {
    test('matches the NIST test vector (GCM test case 14)', () {
      // K = 0^256, IV = 0^96, P = 0^128 → C = cea7403d…, T = d0d1c8a7…
      final key = '00' * 32;
      final nonce = '00' * 12;
      final plain = Uint8List(16);
      // decrypting the published C||T must give back the zero block
      final cipherWithTag = hexToBytes(
        'cea7403d4d606b6e074ec5d3baf39d18'
        'd0d1c8a799996bf0265b98b5d48ab919',
      );
      final out = MediaCipher.decrypt(
        Uint8List.fromList(cipherWithTag),
        keyHex: key,
        nonceHex: nonce,
      );
      expect(out, plain);
    });

    test('round trip, with a fresh key and nonce every time', () {
      final plain = Uint8List.fromList(List.generate(5000, (i) => i % 251));
      final a = MediaCipher.encrypt(plain);
      final b = MediaCipher.encrypt(plain);
      expect(a.key, isNot(b.key));
      expect(a.nonce, isNot(b.nonce));
      expect(a.bytes, isNot(b.bytes));
      expect(a.bytes.length, plain.length + 16); // + GCM tag
      expect(
        MediaCipher.decrypt(a.bytes, keyHex: a.key, nonceHex: a.nonce),
        plain,
      );
      expect(a.sha256, MediaCipher.sha256Hex(a.bytes));
      expect(a.plainSha256, MediaCipher.sha256Hex(plain));
    });

    test('ciphertext reveals nothing recognisable', () {
      // A JPEG header must not survive.
      final jpeg = Uint8List.fromList([
        0xFF,
        0xD8,
        0xFF,
        0xE0,
        ...List.filled(200, 7),
      ]);
      final enc = MediaCipher.encrypt(jpeg, random: Random(1));
      expect(enc.bytes.sublist(0, 3), isNot([0xFF, 0xD8, 0xFF]));
    });

    test('a modified byte is detected', () {
      final enc = MediaCipher.encrypt(Uint8List.fromList(List.filled(100, 3)));
      final tampered = Uint8List.fromList(enc.bytes)..[10] ^= 0x01;
      expect(
        () =>
            MediaCipher.decrypt(tampered, keyHex: enc.key, nonceHex: enc.nonce),
        throwsA(isA<MediaCipherException>()),
      );
    });

    test('the wrong key or nonce is refused', () {
      final enc = MediaCipher.encrypt(Uint8List.fromList(List.filled(100, 3)));
      final other = MediaCipher.encrypt(Uint8List(1));
      expect(
        () => MediaCipher.decrypt(
          enc.bytes,
          keyHex: other.key,
          nonceHex: enc.nonce,
        ),
        throwsA(isA<MediaCipherException>()),
      );
      expect(
        () => MediaCipher.decrypt(
          enc.bytes,
          keyHex: enc.key,
          nonceHex: other.nonce,
        ),
        throwsA(isA<MediaCipherException>()),
      );
    });

    test('malformed inputs fail cleanly', () {
      final enc = MediaCipher.encrypt(Uint8List(10));
      expect(
        () => MediaCipher.decrypt(enc.bytes, keyHex: 'zz', nonceHex: enc.nonce),
        throwsA(isA<MediaCipherException>()),
      );
      expect(
        () => MediaCipher.decrypt(
          enc.bytes,
          keyHex: '00' * 16,
          nonceHex: enc.nonce,
        ),
        throwsA(isA<MediaCipherException>()),
      );
      expect(
        () => MediaCipher.decrypt(
          Uint8List(5),
          keyHex: enc.key,
          nonceHex: enc.nonce,
        ),
        throwsA(isA<MediaCipherException>()),
      );
    });

    test('works off the UI isolate', () async {
      final plain = Uint8List.fromList(List.generate(300000, (i) => i % 256));
      final enc = await MediaCipher.encryptAsync(plain);
      expect(
        await MediaCipher.decryptAsync(
          enc.bytes,
          keyHex: enc.key,
          nonceHex: enc.nonce,
        ),
        plain,
      );
    });
  });
}
