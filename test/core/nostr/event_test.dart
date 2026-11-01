import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/signer.dart';

void main() {
  group('NostrEvent', () {
    // Known vector: fixed key and timestamps produce deterministic ids.
    test('signs and verifies a kind 20 event', () async {
      final signer = NsecSigner.fromNsec(
        '67dea2ed018072d675f5415ecfaed7d2597555e202d85b3d65ea4e58d2d92ffa',
      );
      final event = await signer.signEvent(
        kind: NostrKinds.picture,
        tags: [
          ['imeta', 'url https://example.com/a.jpg', 'm image/jpeg'],
        ],
        content: 'Tramonto #mialuna',
        createdAt: 1700000000,
      );
      expect(event.verifyId(), true);
      expect(verifyEventSignature(event), true);
      expect(event.pubkey, signer.publicKey);
    });

    test('rejects tampered content', () async {
      final signer = NsecSigner.fromNsec(
        '67dea2ed018072d675f5415ecfaed7d2597555e202d85b3d65ea4e58d2d92ffa',
      );
      final event = await signer.signEvent(
        kind: NostrKinds.picture,
        tags: const [],
        content: 'originale',
      );
      final tampered = NostrEvent(
        id: event.id,
        pubkey: event.pubkey,
        createdAt: event.createdAt,
        kind: event.kind,
        tags: event.tags,
        content: 'manomesso',
        sig: event.sig,
      );
      expect(verifyEventSignature(tampered), false);
    });

    test('guest signer cannot sign', () {
      final guest = GuestSigner();
      expect(guest.canSign, false);
      expect(
        () => guest.signEvent(kind: 1, tags: [], content: ''),
        throwsA(isA<SignerException>()),
      );
    });

    test('invalid nsec input throws', () {
      expect(() => NsecSigner.fromNsec('nsec1invalid'), throwsFormatException);
      expect(() => NsecSigner.fromNsec('not-a-key'), throwsFormatException);
      expect(() => NsecSigner.fromNsec(''), throwsFormatException);
    });

    test('NIP-40 expiration', () async {
      final signer = NsecSigner.fromNsec(
        '67dea2ed018072d675f5415ecfaed7d2597555e202d85b3d65ea4e58d2d92ffa',
      );
      final event = await signer.signEvent(
        kind: NostrKinds.picture,
        tags: [
          ['expiration', '1000'],
        ],
        content: '',
      );
      expect(event.expiration, 1000);
      expect(event.isExpired(2000), true);
      expect(event.isExpired(500), false);
    });
  });
}
