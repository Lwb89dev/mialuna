import 'dart:convert';

import 'package:bip340/bip340.dart' as bip340;
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/bech32.dart';
import 'package:mialuna/core/nostr/nip44.dart';

// Official NIP-44 v2 test vectors:
// https://github.com/paulmillr/nip44/blob/master/nip44.vectors.json
// (sha256: 269ed0f69e4c192512cc779e78c555090cebc7c785b609e338a62afc3ce25040)
void main() {
  group('Nip44 conversation keys', () {
    const vectors = [
      (
        '315e59ff51cb9209768cf7da80791ddcaae56ac9775eb25b6dee1234bc5d2268',
        'c2f9d9948dc8c7c38321e4b85c8558872eafa0641cd269db76848a6073e69133',
        '3dfef0ce2a4d80a25e7a328accf73448ef67096f65f79588e358d9a0eb9013f1',
      ),
      (
        'a1e37752c9fdc1273be53f68c5f74be7c8905728e8de75800b94262f9497c86e',
        '03bb7947065dde12ba991ea045132581d0954f042c84e06d8c00066e23c1a800',
        '4d14f36e81b8452128da64fe6f1eae873baae2f444b02c950b90e43553f2178b',
      ),
      (
        // sec1 == pub2
        '0000000000000000000000000000000000000000000000000000000000000001',
        '79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798',
        '3b4610cb7189beb9cc29eb3716ecc6102f1247e8f3101a03a1787d8908aeb54e',
      ),
      (
        // sec1 = n - 2
        'fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364139',
        '0000000000000000000000000000000000000000000000000000000000000002',
        '8b6392dbf2ec6a2b2d5b1477fc2be84d63ef254b667cadd31bd3f444c44ae6ba',
      ),
    ];

    for (final (sec1, pub2, expected) in vectors) {
      test('conversation key for ${sec1.substring(0, 8)}…', () {
        final key = Nip44.conversationKey(sec1, pub2);
        expect(bytesToHex(key), expected);
      });
    }

    test('rejects invalid secret keys and public keys', () {
      const badSec1s = [
        'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
        '0000000000000000000000000000000000000000000000000000000000000000',
        'fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141',
      ];
      for (final sec1 in badSec1s) {
        expect(
          () => Nip44.conversationKey(
            sec1,
            '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
          ),
          throwsA(anything),
        );
      }
      const badPub2s = [
        'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
        '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
        '0000000000000000000000000000000000000000000000000000000000000000',
        'eb1f7200aecaa86682376fb1c13cd12b732221e774f553b0a0857f88fa20f86d',
        '709858a4c121e4a84eb59c0ded0261093c71e8ca29efeef21a6161c447bcaf9f',
      ];
      for (final pub2 in badPub2s) {
        expect(
          () => Nip44.conversationKey(
            '0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20',
            pub2,
          ),
          throwsA(anything),
        );
      }
    });
  });

  group('Nip44 message keys (HKDF-expand)', () {
    const conversationKey =
        'a1a3d60f3470a8612633924e91febf96dc5366ce130f658b1f0fc652c20b3b54';
    const vectors = [
      (
        'e1e6f880560d6d149ed83dcc7e5861ee62a5ee051f7fde9975fe5d25d2a02d72',
        'f145f3bed47cb70dbeaac07f3a3fe683e822b3715edb7c4fe310829014ce7d76'
            'c4ad129bb01180c0933a160c'
            '027c1db445f05e2eee864a0975b0ddef5b7110583c8c192de3732571ca5838c4',
      ),
      (
        'e1d6d28c46de60168b43d79dacc519698512ec35e8ccb12640fc8e9f26121101',
        'e35b88f8d4a8f1606c5082f7a64b100e5d85fcdb2e62aeafbec03fb9e860ad92'
            '22925e920cee4a50a478be90'
            '46a7c55d4283cb0df1d5e29540be67abfe709e3b2e14b7bf9976e6df994ded30',
      ),
      (
        'cfc13bef512ac9c15951ab00030dfaf2626fdca638dedb35f2993a9eeb85d650',
        '020783eb35fdf5b80ef8c75377f4e937efb26bcbad0e61b4190e39939860c4bf'
            'd3594987af769a52904656ac'
            '237ec0ccb6ebd53d179fa8fd319e092acff599ef174c1fdafd499ef2b8dee745',
      ),
    ];

    for (final (nonce, expected) in vectors) {
      test('keys for nonce ${nonce.substring(0, 8)}…', () {
        final keys = Nip44.hkdfExpand(
          hexToBytes(conversationKey),
          hexToBytes(nonce),
          76,
        );
        expect(bytesToHex(keys), expected);
      });
    }
  });

  group('Nip44 padding', () {
    test('calc_padded_len vectors', () {
      const vectors = [
        [16, 32],
        [32, 32],
        [33, 64],
        [37, 64],
        [45, 64],
        [49, 64],
        [64, 64],
        [65, 96],
        [100, 128],
        [111, 128],
        [200, 224],
        [250, 256],
        [320, 320],
        [383, 384],
        [384, 384],
        [400, 448],
        [500, 512],
        [512, 512],
        [515, 640],
        [700, 768],
        [800, 896],
        [900, 1024],
        [1020, 1024],
        [65536, 65536],
      ];
      for (final [input, expected] in vectors) {
        expect(Nip44.calcPaddedLen(input), expected, reason: 'len $input');
      }
    });
  });

  group('Nip44 encrypt/decrypt vectors', () {
    const vectors = [
      (
        'c41c775356fd92eadc63ff5a0dc1da211b268cbea22316767095b2871ea1412d',
        '0000000000000000000000000000000000000000000000000000000000000001',
        'a',
        'AgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABee0G5VSK0/9YypIObAtD'
            'KfYEAjD35uVkHyB0F4DwrcNaCXlCWZKaArsGrY6M9wnuTMxWfp1RTN9Xga8no+kF5Vsb',
      ),
      (
        'c41c775356fd92eadc63ff5a0dc1da211b268cbea22316767095b2871ea1412d',
        'f00000000000000000000000000000f00000000000000000000000000000000f',
        '🍕🫃',
        'AvAAAAAAAAAAAAAAAAAAAPAAAAAAAAAAAAAAAAAAAAAPSKSK6is9ngkX2+cSq85T'
            'h16oRTISAOfhStnixqZziKMDvB0QQzgFZdjLTPicCJaV8nDITO+QfaQ61+KbWQIOO2Yj',
      ),
      (
        '3e2b52a63be47d34fe0a80e34e73d436d6963bc8f39827f327057a9986c20a45',
        'b635236c42db20f021bb8d1cdff5ca75dd1a0cc72ea742ad750f33010b24f73b',
        '表ポあA鷗ŒéＢ逍Üßªąñ丂㐀𠀀',
        'ArY1I2xC2yDwIbuNHN/1ynXdGgzHLqdCrXUPMwELJPc7s7JqlCMJBAIIjfkpHReB'
            'PXeoMCyuClwgbT419jUWU1PwaNl4FEQYKCDKVJz+97Mp3K+Q2YGa77B6gpxB/lr1'
            'QgoqpDf7wDVrDmOqGoiPjWDqy8KzLueKDcm9BVP8xeTJIxs=',
      ),
      (
        '75fe686d21a035f0c7cd70da64ba307936e5ca0b20710496a6b6b5f573377bdd',
        '38d1ca0abef9e5f564e89761a86cee04574b6825d3ef2063b10ad75899e4b023',
        'الكل في المجمو عة (5)',
        'AjjRygq++eX1ZOiXYahs7gRXS2gl0+8gY7EK11iZ5LAjbOTrlfrxak5Lki42v2jM'
            'PpLSicy8eHjsWkkMtF0i925vOaKG/ZkMHh9ccQBdfTvgEGKzztedqDCAWb5TP1Yw'
            'U1PsWaiiqG3+WgVvJiO4lUdMHXL7+zKKx8bgDtowzz4QAwI=',
      ),
    ];

    for (final (convKey, nonce, plaintext, payload) in vectors) {
      test('round trip "${plaintext.substring(0, 1)}"', () {
        final key = hexToBytes(convKey);
        final encrypted = Nip44.encryptWithNonce(
          key,
          hexToBytes(nonce),
          plaintext,
        );
        expect(encrypted, payload);
        expect(Nip44.decryptWithKey(key, payload), plaintext);
      });
    }

    test('high-level encrypt/decrypt round trip between two keys', () {
      const sec1 =
          '5c0c523f52a5b6fad39ed2403092df8cebc36318b39383bca6c00808626fab3a';
      const sec2 =
          '4b22aa260e4acb7021e32f38a6cdf4b673c6a277755bfce287e370c924dc936d';
      final pub1 = bip340.getPublicKey(sec1);
      final pub2 = bip340.getPublicKey(sec2);
      final payload = Nip44.encrypt(
        privateKeyHex: sec1,
        publicKeyHex: pub2,
        plaintext: 'under the same moon',
      );
      expect(payload.startsWith('A'), isTrue);
      final back = Nip44.decrypt(
        privateKeyHex: sec2,
        publicKeyHex: pub1,
        payload: payload,
      );
      expect(back, 'under the same moon');
    });
  });

  group('Nip44 extended length prefix', () {
    const convKey =
        'c41c775356fd92eadc63ff5a0dc1da211b268cbea22316767095b2871ea1412d';
    const nonce =
        '0000000000000000000000000000000000000000000000000000000000000001';
    const vectors = [
      (
        65535,
        '6d8c2810d1e870fbaa1f0a0937126cca837a15f9260e27060c331d70a3c0bc84',
      ),
      (
        65536,
        'b7b4edb36ba92e267d322d56d9aebc22e7fa96ff52e3c12adc07f07a43cbc616',
      ),
      (
        65537,
        'eeb7c7c5373894ea2c1547cfd3ccb15d5a0b2d619da852e5c79df792dcc9e435',
      ),
    ];

    for (final (len, payloadSha) in vectors) {
      test('plaintext length $len', () {
        final payload = Nip44.encryptWithNonce(
          hexToBytes(convKey),
          hexToBytes(nonce),
          'a' * len,
        );
        expect(sha256.convert(utf8.encode(payload)).toString(), payloadSha);
        expect(Nip44.decryptWithKey(hexToBytes(convKey), payload), 'a' * len);
      });
    }
  });

  group('Nip44 invalid decryption', () {
    const vectors = [
      (
        'ca2527a037347b91bea0c8a30fc8d9600ffd81ec00038671e3a0f0cb0fc9f642',
        '#Atqupco0WyaOW2IGDKcshwxI9xO8HgD/P8Ddt46CbxDbrhdG8VmJdU0MIDf06CUvE'
            'vdnr1cp1fiMtlM/GrE92xAc1K5odTpCzUB+mjXgbaqtntBUbTToSUoT0ovrlPwzGjyp',
      ),
      (
        '36f04e558af246352dcf73b692fbd3646a2207bd8abd4b1cd26b234db84d9481',
        'AK1AjUvoYW3IS7C/BGRUoqEC7ayTfDUgnEPNeWTF/reBZFaha6EAIRueE9D1B1Ru'
            'oiuFScC0Q94yjIuxZD3JStQtE8JMNacWFs9rlYP+ZydtHhRucp+lxfdvFlaGV/sQlqZz',
      ),
      (
        'cff7bd6a3e29a450fd27f6c125d5edeb0987c475fd1e8d97591e0d4d8a89763c',
        'Agn/l3ULCEAS4V7LhGFM6IGA17jsDUaFCKhrbXDANholyySBfeh+EN8wNB9gaLlg'
            '4j6wdBYh+3oK+mnxWu3NKRbSvQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
      ),
      (
        'cfcc9cf682dfb00b11357f65bdc45e29156b69db424d20b3596919074f5bf957',
        'AmWxSwuUmqp9UsQX63U7OQ6K1thLI69L7G2b+j4DoIr0oRWQ8avl4OLqWZiTJ10v'
            'IgKrNqjoaX+fNhE9RqmR5g0f6BtUg1ijFMz71MO1D4lQLQfW7+UHva8PGYgQ1QpHlKgR',
      ),
      (
        '5254827d29177622d40a7b67cad014fe7137700c3c523903ebbe3e1b74d40214',
        'Anq2XbuLvCuONcr7V0UxTh8FAyWoZNEdBHXvdbNmDZHB573MI7R7rrTYftpqmvUp'
            'ahmBC2sngmI14/L0HjOZ7lWGJlzdh6luiOnGPc46cGxf08MRC4CIuxx3i2Lm0KqgJ7vA',
      ),
      (
        'fea39aca9aa8340c3a78ae1f0902aa7e726946e4efcd7783379df8096029c496',
        'An1Cg+O1TIhdav7ogfSOYvCj9dep4ctxzKtZSniCw5MwRrrPJFyAQYZh5VpjC2QY'
            'zny5LIQ9v9lhqmZR4WBYRNJ0ognHVNMwiFV1SHpvUFT8HHZN/m/QarflbvDHAtO6pY16',
      ),
      (
        '0c4cffb7a6f7e706ec94b2e879f1fc54ff8de38d8db87e11787694d5392d5b3f',
        'Am+f1yZnwnOs0jymZTcRpwhDRHTdnrFcPtsBzpqVdD6b2NZDaNm/TPkZGr75kbB6'
            'tCSoq7YRcbPiNfJXNch3Tf+o9+zZTMxwjgX/nm3yDKR2kHQMBhVleCB9uPuljl40AJ8k'
            'XRD0gjw+aYRJFUMK9gCETZAjjmrsCM+nGRZ1FfNsHr6Z',
      ),
      ('5cd2d13b9e355aeb2452afbd3786870dbeecb9d355b12cb0a3b6e9da5744cd35', ''),
      (
        'd61d3f09c7dfe1c0be91af7109b60a7d9d498920c90cbba1e137320fdd938853',
        'Ag==',
      ),
      (
        '873bb0fc665eb950a8e7d5971965539f6ebd645c83c08cd6a85aafbad0f0bc47',
        'AqxgToSh3H7iLYRJjoWAM+vSv/Y1mgNlm6OWWjOYUClrFF8=',
      ),
      (
        '9f2fef8f5401ac33f74641b568a7a30bb19409c76ffdc5eae2db6b39d2617fbe',
        'Ap/2SEZCVFIhYk6qx7nqJxM6TMI1ZoKmAzrO7vBDVJhhuZXWiM20i/tIsbjT0Kxk'
            'Js2MZjh1oXNYMO9ggfk7i47WQA==',
      ),
    ];

    for (final (convKey, payload) in vectors) {
      test(
        'rejects payload starting ${payload.isEmpty ? "(empty)" : payload.substring(0, 4)}',
        () {
          expect(
            () => Nip44.decryptWithKey(hexToBytes(convKey), payload),
            throwsA(anything),
          );
        },
      );
    }

    test('rejects invalid base64', () {
      expect(
        () => Nip44.decryptWithKey(
          hexToBytes(
            'ca2527a037347b91bea0c8a30fc8d9600ffd81ec00038671e3a0f0cb0fc9f642',
          ),
          'Atфupco0WyaOW2IGDKcshwxI9xO8HgD/P8Ddt46CbxDbrhdG8VmJZE0UICD06CUv'
          'Evdnr1cp1fiMtlM/GrE92xAc1EwsVCQEgWEu2gsHUVf4JAa3TpgkmFc3TWsax0v6n/Wq',
        ),
        throwsA(anything),
      );
    });
  });

  test('rejects empty plaintext', () {
    expect(
      () => Nip44.encrypt(
        privateKeyHex:
            '0000000000000000000000000000000000000000000000000000000000000001',
        publicKeyHex:
            '79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798',
        plaintext: '',
      ),
      throwsA(anything),
    );
  });
}
