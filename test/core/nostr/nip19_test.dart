import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/bech32.dart';
import 'package:mialuna/core/nostr/nip19.dart';

void main() {
  group('NIP-19', () {
    // Vector from NIP-19 spec examples (well-known test key).
    const privkeyHex =
        '67dea2ed018072d675f5415ecfaed7d2597555e202d85b3d65ea4e58d2d92ffa';
    const nsec =
        'nsec1vl029mgpspedva04g90vltkh6fvh240zqtv9k0t9af8935ke9laqsnlfe5';

    test('decodes nsec to hex', () {
      expect(Nip19.decodeNsec(nsec), privkeyHex);
    });

    test('encode/decode roundtrip npub', () {
      const pub =
          '7e7e9c42a91bfef19fa929e5fda1b72e0ebc1a4c1141673e2794234d86addf4e';
      final npub = Nip19.encodeNpub(pub);
      expect(npub.startsWith('npub1'), true);
      expect(Nip19.decodeNpub(npub), pub);
    });

    test('encode/decode roundtrip note', () {
      const id =
          '6eeb1c5c42a8c1f16d1bd2b9dbbe2b9dbbe2b9dbbe2b9dbbe2b9dbbe2b9dbbe2';
      final note = Nip19.encodeNote(id);
      expect(note.startsWith('note1'), true);
      expect(Nip19.decodeNote(note), id);
    });

    test('rejects wrong prefix', () {
      expect(
        () => Nip19.decodeNsec(Nip19.encodeNpub(privkeyHex)),
        throwsFormatException,
      );
    });

    test('isValidNsec', () {
      expect(Nip19.isValidNsec(nsec), true);
      expect(Nip19.isValidNsec('nsec1invalid'), false);
      expect(Nip19.isValidNsec('hello'), false);
      expect(Nip19.isValidNsec(''), false);
    });

    test('rejects checksum mismatch', () {
      final bad =
          nsec.substring(0, nsec.length - 1) + (nsec.endsWith('2') ? '3' : '2');
      expect(() => Nip19.decodeNsec(bad), throwsFormatException);
    });
  });

  group('bech32', () {
    test('known BIP-173 vector', () {
      // A12UEL5L is the valid bech32 encoding of hrp "a" + empty data.
      expect(Bech32.encode('a', []), 'a12uel5l');
    });
  });
}
