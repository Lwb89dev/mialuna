import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/nip19.dart';
import 'package:mialuna/core/nostr/nip59.dart';
import 'package:mialuna/core/nostr/signer.dart';

NsecSigner newSigner() => NsecSigner.fromNsec(NsecSigner.generatePrivateKey());

void main() {
  late NsecSigner alice;
  late NsecSigner bob;

  setUp(() {
    alice = newSigner();
    bob = newSigner();
  });

  Rumor message(String text) => Rumor.create(
    pubkey: alice.publicKey,
    kind: NostrKinds.chatMessage,
    tags: [
      ['p', bob.publicKey],
    ],
    content: text,
  );

  group('NIP-59 gift wrap', () {
    test('round trip: Bob opens what Alice wrapped for him', () async {
      final rumor = message('ciao Bob');
      final wrap = await GiftWrap.wrap(
        signer: alice,
        rumor: rumor,
        recipient: bob.publicKey,
      );
      final opened = await GiftWrap.unwrap(signer: bob, wrap: wrap);
      expect(opened, isNotNull);
      expect(opened!.content, 'ciao Bob');
      expect(opened.pubkey, alice.publicKey);
      expect(opened.id, rumor.id);
      expect(opened.kind, NostrKinds.chatMessage);
    });

    test('the wrap hides author, content and real time', () async {
      final rumor = message('segreto');
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final wrap = await GiftWrap.wrap(
        signer: alice,
        rumor: rumor,
        recipient: bob.publicKey,
      );
      expect(wrap.kind, NostrKinds.giftWrap);
      expect(wrap.pubkey, isNot(alice.publicKey)); // throw-away key
      expect(wrap.content, isNot(contains('segreto')));
      expect(wrap.firstTagValue('p'), bob.publicKey);
      expect(wrap.tags, hasLength(1)); // nothing else leaks
      expect(verifyEventSignature(wrap), true);
      // Timestamp randomised up to two days into the past.
      expect(wrap.createdAt, lessThanOrEqualTo(now));
      expect(wrap.createdAt, greaterThan(now - 2 * 24 * 3600 - 5));
    });

    test('the seal is signed by the author and has no tags', () async {
      final wrap = await GiftWrap.wrap(
        signer: alice,
        rumor: message('x'),
        recipient: bob.publicKey,
      );
      final sealJson = await bob.nip44Decrypt(wrap.pubkey, wrap.content);
      final seal = NostrEvent.fromJson(
        jsonDecode(sealJson) as Map<String, dynamic>,
      );
      expect(seal.kind, NostrKinds.seal);
      expect(seal.tags, isEmpty);
      expect(seal.pubkey, alice.publicKey);
      expect(verifyEventSignature(seal), true);
    });

    test('the sender can read their own copy', () async {
      final rumor = message('copia per me');
      final wrap = await GiftWrap.wrap(
        signer: alice,
        rumor: rumor,
        recipient: alice.publicKey,
      );
      final opened = await GiftWrap.unwrap(signer: alice, wrap: wrap);
      expect(opened?.id, rumor.id);
    });

    test('someone else cannot open it', () async {
      final eve = newSigner();
      final wrap = await GiftWrap.wrap(
        signer: alice,
        rumor: message('privato'),
        recipient: bob.publicKey,
      );
      expect(await GiftWrap.unwrap(signer: eve, wrap: wrap), isNull);
    });

    test('a seal whose author differs from the rumor author is rejected '
        '(no impersonation)', () async {
      final mallory = newSigner();
      // Mallory seals a rumor that claims to be written by Alice.
      final forged = Rumor.create(
        pubkey: alice.publicKey,
        kind: NostrKinds.chatMessage,
        tags: [
          ['p', bob.publicKey],
        ],
        content: 'sono Alice, dammi i soldi',
      );
      final wrap = await GiftWrap.wrap(
        signer: mallory,
        rumor: forged,
        recipient: bob.publicKey,
      );
      expect(await GiftWrap.unwrap(signer: bob, wrap: wrap), isNull);
    });

    test('a rumor whose id does not match its content is rejected', () {
      final rumor = message('vero');
      final json = rumor.toJson()..['content'] = 'falso';
      expect(Rumor.tryParse(json), isNull);
    });

    test('non-wrap events and wraps for other people are ignored', () async {
      final plain = await alice.signEvent(kind: 1, tags: const [], content: '');
      expect(await GiftWrap.unwrap(signer: bob, wrap: plain), isNull);
      final carol = newSigner();
      final forCarol = await GiftWrap.wrap(
        signer: alice,
        rumor: message('per Carol'),
        recipient: carol.publicKey,
      );
      expect(await GiftWrap.unwrap(signer: bob, wrap: forCarol), isNull);
    });
  });

  group('NIP-19 nevent', () {
    const id =
        '6eeb1c5c42a8c1f16d1bd2b9dbbe2b9dbbe2b9dbbe2b9dbbe2b9dbbe2b9dbbe2';
    final author =
        '7e7e9c42a91bfef19fa929e5fda1b72e0ebc1a4c1141673e2794234d86addf4e';

    test('round trip with relay hints, author and kind', () {
      final nevent = Nip19.encodeNevent(
        id.substring(0, 64),
        relays: ['wss://relay.damus.io', 'wss://nos.lol'],
        author: author,
        kind: 22,
      );
      expect(nevent, startsWith('nevent1'));
      final ref = Nip19.decodeEventRef('nostr:$nevent');
      expect(ref.id, id.substring(0, 64));
      expect(ref.relays, ['wss://relay.damus.io', 'wss://nos.lol']);
      expect(ref.author, author);
      expect(ref.kind, 22);
    });

    test('decodes plain note1 references too', () {
      final note = Nip19.encodeNote(author);
      expect(Nip19.decodeEventRef(note).id, author);
    });

    test('finds references inside a message', () {
      final nevent = Nip19.encodeNevent(author);
      final text = 'guarda questo\nnostr:$nevent';
      final match = Nip19.eventRefPattern.firstMatch(text)!;
      expect(match.group(0), 'nostr:$nevent');
      expect(Nip19.eventRefPattern.hasMatch('niente da vedere qui'), false);
    });

    test('rejects other bech32 kinds', () {
      expect(
        () => Nip19.decodeEventRef(Nip19.encodeNpub(author)),
        throwsFormatException,
      );
    });
  });
}
