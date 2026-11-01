import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/stream/chacha7539.dart';

import 'bech32.dart';

/// NIP-44 v2 encrypted payloads: secp256k1 ECDH, HKDF-SHA256, ChaCha20
/// (RFC 8439), HMAC-SHA256 over nonce+ciphertext, custom power-of-two
/// padding, base64 envelope with version byte 0x02.
class Nip44 {
  static const _version = 2;
  static final _salt = utf8.encode('nip44-v2');

  /// Long-term conversation key: HKDF-extract(salt='nip44-v2', ikm=shared_x).
  /// Symmetric: conv(a, B) == conv(b, A).
  static Uint8List conversationKey(String privateKeyHex, String publicKeyHex) {
    final params = ECCurve_secp256k1();
    final privInt = BigInt.parse(privateKeyHex, radix: 16);
    if (privInt <= BigInt.zero || privInt >= params.n) {
      throw const FormatException('invalid private key');
    }
    final priv = ECPrivateKey(privInt, params);
    final compressed = publicKeyHex.length == 66
        ? publicKeyHex
        : '02$publicKeyHex';
    final point = params.curve.decodePoint(hexToBytes(compressed));
    if (point == null) throw const FormatException('invalid public key');
    final agreement = ECDHBasicAgreement()..init(priv);
    final shared = agreement.calculateAgreement(ECPublicKey(point, params));
    final sharedX = hexToBytes(shared.toRadixString(16).padLeft(64, '0'));
    return hkdfExtract(_salt, sharedX);
  }

  /// RFC 5869 HKDF-extract with SHA-256.
  static Uint8List hkdfExtract(List<int> salt, List<int> ikm) =>
      _hmac(salt, ikm);

  /// RFC 5869 HKDF-expand with SHA-256.
  static Uint8List hkdfExpand(Uint8List prk, List<int> info, int length) {
    final out = BytesBuilder();
    var t = Uint8List(0);
    var counter = 1;
    while (out.length < length) {
      t = _hmac(prk, [...t, ...info, counter]);
      out.add(t);
      counter++;
    }
    return Uint8List.fromList(out.toBytes().sublist(0, length));
  }

  /// Padded length bucket per NIP-44 (min 32, power-of-two chunks).
  static int calcPaddedLen(int unpaddedLen) {
    if (unpaddedLen <= 32) return 32;
    var nextPower = 1;
    while (nextPower < unpaddedLen) {
      nextPower <<= 1;
    }
    final chunk = nextPower <= 256 ? 32 : nextPower ~/ 8;
    return chunk * ((unpaddedLen - 1) ~/ chunk + 1);
  }

  /// Encrypts for [publicKeyHex] with a fresh random nonce.
  static String encrypt({
    required String privateKeyHex,
    required String publicKeyHex,
    required String plaintext,
  }) {
    final key = conversationKey(privateKeyHex, publicKeyHex);
    final rng = Random.secure();
    final nonce = Uint8List.fromList(
      List.generate(32, (_) => rng.nextInt(256)),
    );
    return encryptWithNonce(key, nonce, plaintext);
  }

  /// Encrypts with an explicit conversation key and nonce (testable).
  static String encryptWithNonce(
    Uint8List conversationKey,
    Uint8List nonce,
    String plaintext,
  ) {
    final plain = utf8.encode(plaintext);
    if (plain.isEmpty) throw const FormatException('invalid plaintext length');
    if (nonce.length != 32) throw const FormatException('invalid nonce');
    final (chachaKey, chachaNonce, hmacKey) = _messageKeys(
      conversationKey,
      nonce,
    );
    final padded = _pad(plain);
    final ciphertext = _chacha20(chachaKey, chachaNonce, padded);
    final mac = _hmac(hmacKey, [...nonce, ...ciphertext]);
    return base64Encode(
      Uint8List.fromList([_version, ...nonce, ...ciphertext, ...mac]),
    );
  }

  static String decrypt({
    required String privateKeyHex,
    required String publicKeyHex,
    required String payload,
  }) => decryptWithKey(conversationKey(privateKeyHex, publicKeyHex), payload);

  static String decryptWithKey(Uint8List conversationKey, String payload) {
    final (nonce, ciphertext, mac) = _decodePayload(payload);
    final (chachaKey, chachaNonce, hmacKey) = _messageKeys(
      conversationKey,
      nonce,
    );
    final expected = _hmac(hmacKey, [...nonce, ...ciphertext]);
    if (!_constantTimeEquals(expected, mac)) {
      throw const FormatException('invalid MAC');
    }
    final padded = _chacha20(chachaKey, chachaNonce, ciphertext);
    return utf8.decode(_unpad(padded));
  }

  static (Uint8List, Uint8List, Uint8List) _messageKeys(
    Uint8List conversationKey,
    Uint8List nonce,
  ) {
    if (conversationKey.length != 32) {
      throw const FormatException('invalid conversation key length');
    }
    final keys = hkdfExpand(conversationKey, nonce, 76);
    return (keys.sublist(0, 32), keys.sublist(32, 44), keys.sublist(44, 76));
  }

  static Uint8List _pad(Uint8List unpadded) {
    final len = unpadded.length;
    final prefixLen = len >= 65536 ? 6 : 2;
    final paddedLen = calcPaddedLen(len);
    final out = Uint8List(prefixLen + paddedLen);
    if (prefixLen == 2) {
      out[0] = len >> 8;
      out[1] = len & 0xff;
    } else {
      out[2] = (len >> 24) & 0xff;
      out[3] = (len >> 16) & 0xff;
      out[4] = (len >> 8) & 0xff;
      out[5] = len & 0xff;
    }
    out.setRange(prefixLen, prefixLen + len, unpadded);
    return out;
  }

  static Uint8List _unpad(Uint8List padded) {
    if (padded.length < 2) throw const FormatException('invalid padding');
    final int prefixLen;
    final int len;
    final short = (padded[0] << 8) | padded[1];
    if (short == 0) {
      if (padded.length < 6) throw const FormatException('invalid padding');
      len =
          (padded[2] << 24) | (padded[3] << 16) | (padded[4] << 8) | padded[5];
      if (len < 65536) throw const FormatException('invalid padding');
      prefixLen = 6;
    } else {
      len = short;
      prefixLen = 2;
    }
    if (len == 0 ||
        padded.length - prefixLen < len ||
        padded.length != prefixLen + calcPaddedLen(len)) {
      throw const FormatException('invalid padding');
    }
    return padded.sublist(prefixLen, prefixLen + len);
  }

  static (Uint8List, Uint8List, Uint8List) _decodePayload(String payload) {
    if (payload.isEmpty || payload[0] == '#') {
      throw const FormatException('unknown version');
    }
    if (payload.length < 132) {
      throw const FormatException('invalid payload size');
    }
    final Uint8List data;
    try {
      data = base64Decode(payload);
    } catch (_) {
      throw const FormatException('invalid base64');
    }
    if (data.length < 99) throw const FormatException('invalid data size');
    if (data[0] != _version) {
      throw FormatException('unknown version ${data[0]}');
    }
    return (
      data.sublist(1, 33),
      data.sublist(33, data.length - 32),
      data.sublist(data.length - 32),
    );
  }

  static Uint8List _chacha20(Uint8List key, Uint8List nonce, Uint8List data) {
    final engine = ChaCha7539Engine()
      ..init(true, ParametersWithIV(KeyParameter(key), nonce));
    return engine.process(data);
  }

  static Uint8List _hmac(List<int> key, List<int> message) {
    final hmac = HMac(SHA256Digest(), 64)
      ..init(KeyParameter(Uint8List.fromList(key)));
    return hmac.process(Uint8List.fromList(message));
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
