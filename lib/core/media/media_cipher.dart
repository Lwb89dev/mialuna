import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/export.dart' show GCMBlockCipher;

import '../../l10n/strings.dart';
import '../nostr/bech32.dart';

/// Why a private file could not be decrypted. Thrown from an isolate, so only
/// the code travels; the text is resolved where the user's language is known.
enum MediaCipherError { invalidKey, truncated, mismatch }

class MediaCipherException implements Exception {
  final MediaCipherError? error;
  final String? _text;

  /// A message that is already in the user's language (main isolate only).
  const MediaCipherException(String message) : error = null, _text = message;

  const MediaCipherException.code(MediaCipherError this.error) : _text = null;

  String get message {
    final text = _text;
    if (text != null) return text;
    final l10n = AppStrings.current;
    return switch (error!) {
      MediaCipherError.invalidKey => l10n.cipherInvalidKey,
      MediaCipherError.truncated => l10n.cipherTruncated,
      MediaCipherError.mismatch => l10n.cipherMismatch,
    };
  }

  @override
  String toString() => message;
}

/// A file encrypted for a private post.
class EncryptedBlob {
  /// Ciphertext followed by the 16-byte GCM tag: what gets uploaded.
  final Uint8List bytes;

  /// AES-256 key and GCM nonce, hex. They only ever travel inside the
  /// encrypted post.
  final String key;
  final String nonce;

  /// SHA-256 of [bytes] (what the server stores) and of the plaintext.
  final String sha256;
  final String plainSha256;

  const EncryptedBlob({
    required this.bytes,
    required this.key,
    required this.nonce,
    required this.sha256,
    required this.plainSha256,
  });
}

/// AES-256-GCM for close-friends media. A new key and nonce for every file, so
/// reusing nothing across posts; the 128-bit tag authenticates the data, so a
/// server (or anyone in between) that alters the blob is detected.
abstract final class MediaCipher {
  static const keyLength = 32;
  static const nonceLength = 12;
  static const tagBits = 128;
  static const algorithm = 'aes-gcm';

  static Uint8List _random(int n, Random random) =>
      Uint8List.fromList(List.generate(n, (_) => random.nextInt(256)));

  static GCMBlockCipher _cipher(bool encrypt, Uint8List key, Uint8List nonce) =>
      GCMBlockCipher(AESEngine())..init(
        encrypt,
        AEADParameters(KeyParameter(key), tagBits, nonce, Uint8List(0)),
      );

  static EncryptedBlob encrypt(Uint8List plain, {Random? random}) {
    final rng = random ?? Random.secure();
    final key = _random(keyLength, rng);
    final nonce = _random(nonceLength, rng);
    final cipher = _cipher(true, key, nonce).process(plain);
    return EncryptedBlob(
      bytes: cipher,
      key: bytesToHex(key),
      nonce: bytesToHex(nonce),
      sha256: sha256Hex(cipher),
      plainSha256: sha256Hex(plain),
    );
  }

  /// Decrypts [cipherWithTag]; throws [MediaCipherException] when the key is
  /// wrong or the data was modified.
  static Uint8List decrypt(
    Uint8List cipherWithTag, {
    required String keyHex,
    required String nonceHex,
  }) {
    try {
      final key = hexToBytes(keyHex);
      final nonce = hexToBytes(nonceHex);
      if (key.length != keyLength || nonce.length != nonceLength) {
        throw const MediaCipherException.code(MediaCipherError.invalidKey);
      }
      if (cipherWithTag.length < tagBits ~/ 8) {
        throw const MediaCipherException.code(MediaCipherError.truncated);
      }
      return _cipher(false, key, nonce).process(cipherWithTag);
    } on MediaCipherException {
      rethrow;
    } on InvalidCipherTextException {
      throw const MediaCipherException.code(MediaCipherError.mismatch);
    } on FormatException {
      throw const MediaCipherException.code(MediaCipherError.invalidKey);
    }
  }

  static String sha256Hex(List<int> data) => sha256.convert(data).toString();

  /// Off the UI isolate: photos take a moment, videos several seconds.
  static Future<EncryptedBlob> encryptAsync(Uint8List plain) =>
      Isolate.run(() => encrypt(plain));

  static Future<Uint8List> decryptAsync(
    Uint8List cipherWithTag, {
    required String keyHex,
    required String nonceHex,
  }) => Isolate.run(
    () => decrypt(cipherWithTag, keyHex: keyHex, nonceHex: nonceHex),
  );
}
