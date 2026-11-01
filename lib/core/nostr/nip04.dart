import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';
import 'package:pointycastle/paddings/pkcs7.dart';
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';

import 'bech32.dart';

/// NIP-04 encryption: ECDH over secp256k1 + AES-256-CBC, payload format
/// `base64(ciphertext)?iv=base64(iv)`. Legacy but still the most widely
/// supported by NIP-46 bunkers; NIP-44 is planned.
class Nip04 {
  static Uint8List sharedSecret(String privateKeyHex, String publicKeyHex) {
    final params = ECCurve_secp256k1();
    final priv = ECPrivateKey(BigInt.parse(privateKeyHex, radix: 16), params);
    final compressed = publicKeyHex.length == 66
        ? publicKeyHex
        : '02$publicKeyHex';
    final point = params.curve.decodePoint(hexToBytes(compressed));
    if (point == null) throw const FormatException('invalid public key');
    final agreement = ECDHBasicAgreement()..init(priv);
    final shared = agreement.calculateAgreement(ECPublicKey(point, params));
    final bytes = shared.toRadixString(16).padLeft(64, '0');
    return hexToBytes(bytes);
  }

  static String encrypt({
    required String privateKeyHex,
    required String publicKeyHex,
    required String plaintext,
  }) {
    final key = sharedSecret(privateKeyHex, publicKeyHex);
    final iv = _randomBytes(16);
    final cipher = _cipher(true, key, iv);
    final encrypted = cipher.process(
      Uint8List.fromList(utf8.encode(plaintext)),
    );
    return '${base64Encode(encrypted)}?iv=${base64Encode(iv)}';
  }

  static String decrypt({
    required String privateKeyHex,
    required String publicKeyHex,
    required String payload,
  }) {
    final parts = payload.split('?iv=');
    if (parts.length != 2) {
      throw const FormatException('invalid NIP-04 payload');
    }
    final key = sharedSecret(privateKeyHex, publicKeyHex);
    final cipher = _cipher(false, key, base64Decode(parts[1]));
    final decrypted = cipher.process(base64Decode(parts[0]));
    return utf8.decode(decrypted);
  }

  static PaddedBlockCipherImpl _cipher(
    bool forEncryption,
    Uint8List key,
    Uint8List iv,
  ) {
    final cbc = CBCBlockCipher(AESEngine());
    final cipher = PaddedBlockCipherImpl(PKCS7Padding(), cbc);
    cipher.init(
      forEncryption,
      PaddedBlockCipherParameters(
        ParametersWithIV(KeyParameter(key), iv),
        null,
      ),
    );
    return cipher;
  }

  static Uint8List _randomBytes(int n) {
    final rng = Random.secure();
    return Uint8List.fromList(List.generate(n, (_) => rng.nextInt(256)));
  }
}
