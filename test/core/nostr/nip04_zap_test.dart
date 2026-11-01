import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/nip04.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/nostr/zap_service.dart';

void main() {
  const privA =
      '67dea2ed018072d675f5415ecfaed7d2597555e202d85b3d65ea4e58d2d92ffa';
  final pubA = NsecSigner.fromNsec(privA).publicKey;
  final privB = NsecSigner.generatePrivateKey();
  final pubB = NsecSigner.fromNsec(privB).publicKey;

  group('NIP-04', () {
    test('encrypt/decrypt roundtrip between two keys', () {
      final payload = Nip04.encrypt(
        privateKeyHex: privA,
        publicKeyHex: pubB,
        plaintext: 'messaggio segreto 🔒',
      );
      expect(payload.contains('?iv='), true);
      final decrypted = Nip04.decrypt(
        privateKeyHex: privB,
        publicKeyHex: pubA,
        payload: payload,
      );
      expect(decrypted, 'messaggio segreto 🔒');
    });

    test('decryption with wrong key fails or yields garbage', () {
      final payload = Nip04.encrypt(
        privateKeyHex: privA,
        publicKeyHex: pubB,
        plaintext: 'top secret',
      );
      final wrongPriv = NsecSigner.generatePrivateKey();
      var failed = false;
      try {
        final out = Nip04.decrypt(
          privateKeyHex: wrongPriv,
          publicKeyHex: pubA,
          payload: payload,
        );
        if (out == 'top secret') failed = true; // must not match
      } catch (_) {
        failed = true;
      }
      expect(failed, true);
    });

    test('malformed payload throws', () {
      expect(
        () => Nip04.decrypt(
          privateKeyHex: privA,
          publicKeyHex: pubB,
          payload: 'noiv',
        ),
        throwsFormatException,
      );
    });
  });

  group('ZapService address parsing', () {
    test('prefers lud16', () {
      expect(
        ZapService.lightningAddress({'lud16': 'a@b.com', 'lud06': 'lnurl1x'}),
        'a@b.com',
      );
    });
    test('falls back to lud06', () {
      expect(ZapService.lightningAddress({'lud06': 'lnurl1x'}), 'lnurl1x');
    });
    test('null when absent or invalid', () {
      expect(ZapService.lightningAddress(const {}), isNull);
      expect(ZapService.lightningAddress({'lud16': 'not-an-address'}), isNull);
    });
  });
}
