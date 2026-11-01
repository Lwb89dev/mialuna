import 'dart:convert';

import 'package:bip340/bip340.dart' as bip340;
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/nip04.dart';
import 'package:mialuna/core/nostr/nip44.dart';
import 'package:mialuna/core/nostr/nwc_service.dart';

const _clientSecret =
    '67dea2ed018072d675f5415ecfaed7d2597555e202d85b3d65ea4e58d2d92ffa';
const _walletSecret =
    '315e59ff51cb9209768cf7da80791ddcaae56ac9775eb25b6dee1234bc5d2268';
final _walletPubkey = bip340.getPublicKey(_walletSecret);

const _bolt11 = 'lnbc210n1exampleinvoice';

void main() {
  group('NwcConnection.parse', () {
    test('parses a valid connection string', () {
      final conn = NwcConnection.parse(
        'nostr+walletconnect://$_walletPubkey'
        '?relay=wss%3A%2F%2Frelay.example&secret=$_clientSecret'
        '&lud16=alice%40wallet.example',
      );
      expect(conn.walletPubkey, _walletPubkey);
      expect(conn.relays, ['wss://relay.example']);
      expect(conn.secret, _clientSecret);
      expect(conn.lud16, 'alice@wallet.example');
      expect(conn.clientPubkey, bip340.getPublicKey(_clientSecret));
    });

    test('round-trips through toUri', () {
      final uri =
          'nostr+walletconnect://$_walletPubkey'
          '?relay=wss%3A%2F%2Frelay.example&secret=$_clientSecret';
      final conn = NwcConnection.parse(uri);
      final again = NwcConnection.parse(conn.toUri());
      expect(again.walletPubkey, conn.walletPubkey);
      expect(again.relays, conn.relays);
      expect(again.secret, conn.secret);
    });

    test('rejects invalid URIs', () {
      expect(
        () => NwcConnection.parse('https://example.com'),
        throwsA(isA<NwcException>()),
      );
      expect(
        () => NwcConnection.parse(
          'nostr+walletconnect://$_walletPubkey?secret=$_clientSecret',
        ),
        throwsA(isA<NwcException>()), // no relay
      );
      expect(
        () => NwcConnection.parse(
          'nostr+walletconnect://$_walletPubkey?relay=wss://r.example',
        ),
        throwsA(isA<NwcException>()), // no secret
      );
      expect(
        () => NwcConnection.parse(
          'nostr+walletconnect://$_walletPubkey'
          '?relay=wss://r.example&secret=nothex',
        ),
        throwsA(isA<NwcException>()),
      );
    });
  });

  group('NwcService.buildPayInvoiceRequest', () {
    test('builds a kind 23194 request decryptable with NIP-44', () async {
      final conn = NwcConnection(
        walletPubkey: _walletPubkey,
        relays: const ['wss://relay.example'],
        secret: _clientSecret,
      );
      final event = await NwcService.buildPayInvoiceRequest(conn, _bolt11);
      expect(event.kind, NwcService.requestKind);
      expect(event.pubkey, conn.clientPubkey);
      expect(event.firstTagValue('p'), _walletPubkey);

      // The wallet side can decrypt the payload.
      final plaintext = Nip44.decrypt(
        privateKeyHex: _walletSecret,
        publicKeyHex: conn.clientPubkey,
        payload: event.content,
      );
      final request = jsonDecode(plaintext) as Map<String, dynamic>;
      expect(request['method'], 'pay_invoice');
      expect(request['params']['invoice'], _bolt11);
    });

    test('NIP-04 fallback payload is decryptable with NIP-04', () async {
      final conn = NwcConnection(
        walletPubkey: _walletPubkey,
        relays: const ['wss://relay.example'],
        secret: _clientSecret,
      );
      final event = await NwcService.buildPayInvoiceRequest(
        conn,
        _bolt11,
        useNip44: false,
      );
      expect(event.content, contains('?iv='));
      final plaintext = Nip04.decrypt(
        privateKeyHex: _walletSecret,
        publicKeyHex: conn.clientPubkey,
        payload: event.content,
      );
      final request = jsonDecode(plaintext) as Map<String, dynamic>;
      expect(request['method'], 'pay_invoice');
      expect(request['params']['invoice'], _bolt11);
    });
  });
}
