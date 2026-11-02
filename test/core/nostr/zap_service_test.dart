import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mialuna/core/net/safe_http.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/nostr/zap_service.dart';

/// 21 sats, written the way a real invoice is (bech32 data after the `1`).
const _invoice21 = 'lnbc210n1pvjluezpp5qqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqypq';

const _privKey =
    '67dea2ed018072d675f5415ecfaed7d2597555e202d85b3d65ea4e58d2d92ffa';
const _recipient =
    '82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2';

http.Client _mockLnurl({
  Map<String, dynamic>? payInfo,
  Map<String, dynamic>? invoice,
  void Function(http.Request request)? onRequest,
}) {
  return MockClient((request) async {
    onRequest?.call(request);
    if (request.url.path.contains('.well-known/lnurlp')) {
      return http.Response(
        jsonEncode(
          payInfo ??
              {
                'callback': 'https://wallet.example/lnurl/callback',
                'minSendable': 1000,
                'maxSendable': 100000000,
                'allowsNostr': true,
                'nostrPubkey': _recipient,
                'commentAllowed': 140,
              },
        ),
        200,
      );
    }
    return http.Response(jsonEncode(invoice ?? {'pr': _invoice21}), 200);
  });
}

void main() {
  final signer = NsecSigner.fromNsec(_privKey);

  setUp(() {
    // No DNS in tests: every name is a public address.
    SafeHttp.resolver = (_) async => [InternetAddress('93.184.216.34')];
  });
  tearDown(() => SafeHttp.resolver = InternetAddress.lookup);

  group('ZapService.fetchPayInfo', () {
    test(
      'resolves lud16 to the well-known endpoint and parses limits',
      () async {
        Uri? requested;
        final service = ZapService(
          httpClient: _mockLnurl(onRequest: (r) => requested = r.url),
        );
        final info = await service.fetchPayInfo('alice@wallet.example');
        expect(requested.toString(), contains('.well-known/lnurlp/alice'));
        expect(info.callback, 'https://wallet.example/lnurl/callback');
        expect(info.minSats, 1);
        expect(info.maxSats, 100000);
        expect(info.commentAllowed, 140);
      },
    );

    test('rejects endpoints without Nostr support', () {
      final service = ZapService(
        httpClient: _mockLnurl(
          payInfo: {
            'callback': 'https://wallet.example/cb',
            'allowsNostr': false,
            'minSendable': 1000,
            'maxSendable': 1000000,
          },
        ),
      );
      expect(
        () => service.fetchPayInfo('alice@wallet.example'),
        throwsA(isA<ZapException>()),
      );
    });
  });

  group('ZapService.requestInvoice', () {
    test('builds a signed kind 9734 and returns the invoice', () async {
      Uri? callbackRequest;
      final service = ZapService(
        httpClient: _mockLnurl(onRequest: (r) => callbackRequest = r.url),
      );
      final invoice = await service.requestInvoice(
        signer: signer,
        lightningAddressOrLnurl: 'alice@wallet.example',
        recipientPubkey: _recipient,
        amountSats: 21,
        eventId: 'a' * 64,
        relays: const ['wss://relay.example'],
        comment: 'great shot',
      );
      expect(invoice.bolt11, _invoice21);
      expect(invoice.amountSats, 21);

      final params = callbackRequest!.queryParameters;
      expect(params['amount'], '21000');
      expect(params['comment'], 'great shot');
      final zapRequest = jsonDecode(params['nostr']!) as Map<String, dynamic>;
      expect(zapRequest['kind'], NostrKinds.zapRequest);
      expect(zapRequest['sig'], isNotEmpty);
      final tags = zapRequest['tags'] as List;
      bool hasTag(List<Object?> expected) => tags.any(
        (t) =>
            t is List &&
            t.length == expected.length &&
            List.generate(t.length, (i) => t[i] == expected[i]).every((x) => x),
      );
      expect(hasTag(['p', _recipient]), isTrue);
      expect(hasTag(['e', 'a' * 64]), isTrue);
      expect(hasTag(['amount', '21000']), isTrue);
      expect(hasTag(['relays', 'wss://relay.example']), isTrue);
    });

    test('rejects amounts outside the LNURL limits', () {
      final service = ZapService(httpClient: _mockLnurl());
      expect(
        () => service.requestInvoice(
          signer: signer,
          lightningAddressOrLnurl: 'alice@wallet.example',
          recipientPubkey: _recipient,
          amountSats: 0,
        ),
        throwsA(isA<ZapException>()),
      );
      expect(
        () => service.requestInvoice(
          signer: signer,
          lightningAddressOrLnurl: 'alice@wallet.example',
          recipientPubkey: _recipient,
          amountSats: 100001,
        ),
        throwsA(isA<ZapException>()),
      );
    });

    test('drops comments when the endpoint does not allow them', () async {
      Uri? callbackRequest;
      final service = ZapService(
        httpClient: _mockLnurl(
          payInfo: {
            'callback': 'https://wallet.example/lnurl/callback',
            'minSendable': 1000,
            'maxSendable': 100000000,
            'allowsNostr': true,
            'commentAllowed': 0,
          },
          onRequest: (r) => callbackRequest = r.url,
        ),
      );
      await service.requestInvoice(
        signer: signer,
        lightningAddressOrLnurl: 'alice@wallet.example',
        recipientPubkey: _recipient,
        amountSats: 21,
        comment: 'ignored',
      );
      expect(callbackRequest!.queryParameters.containsKey('comment'), isFalse);
      final zapRequest = jsonDecode(
        callbackRequest!.queryParameters['nostr']!,
      ) as Map<String, dynamic>;
      expect(zapRequest['content'], '');
    });

    test('throws when no invoice is returned', () {
      final service = ZapService(
        httpClient: _mockLnurl(invoice: {'status': 'ERROR', 'reason': 'nope'}),
      );
      expect(
        () => service.requestInvoice(
          signer: signer,
          lightningAddressOrLnurl: 'alice@wallet.example',
          recipientPubkey: _recipient,
          amountSats: 21,
        ),
        throwsA(isA<ZapException>()),
      );
    });
  });

  group('what the server may not do', () {
    Future<void> expectRefused(Future<Object?> Function() run) async {
      await expectLater(run(), throwsA(isA<ZapException>()));
    }

    test('an invoice for a different amount is refused, not paid', () async {
      for (final wrong in [
        'lnbc2100n1pvjluezpp5qqqsyqcyq5rqwzqfqqqsyqcy', // 100 times more
        'lnbc1pvjluezpp5qqqsyqcyq5rqwzqfqqqsyqcyq5rqw', // no amount at all
        'lnbc210n1not-an-invoice',
        'lightning:lnbc210n1pvjluezpp5',
      ]) {
        final service = ZapService(
          httpClient: _mockLnurl(invoice: {'pr': wrong}),
        );
        await expectRefused(
          () => service.requestInvoice(
            signer: signer,
            lightningAddressOrLnurl: 'alice@wallet.example',
            recipientPubkey: _recipient,
            amountSats: 21,
          ),
        );
      }
    });

    test(
      'a Lightning address cannot smuggle a port, path or credentials',
      () async {
        for (final bad in [
          'a@localhost:3000/x#',
          'a@wallet.example:8080',
          'a@wallet.example/../../x',
          'user:pw@evil.example@wallet.example',
          'a@192.168.1.1',
          '@wallet.example',
        ]) {
          final service = ZapService(httpClient: _mockLnurl());
          await expectRefused(() => service.fetchPayInfo(bad));
        }
      },
    );

    test('a callback on plain http, or an address of the local network, is refused', () async {
      for (final cb in [
        'http://wallet.example/cb',
        'https://192.168.1.10/cb',
        'https://localhost/cb',
        'ftp://wallet.example/cb',
      ]) {
        final service = ZapService(
          httpClient: _mockLnurl(
            payInfo: {
              'callback': cb,
              'minSendable': 1000,
              'maxSendable': 100000000,
              'allowsNostr': true,
            },
          ),
        );
        await expectRefused(
          () => service.requestInvoice(
            signer: signer,
            lightningAddressOrLnurl: 'alice@wallet.example',
            recipientPubkey: _recipient,
            amountSats: 21,
          ),
        );
      }
    });

    test('a name that resolves to the local network is refused', () async {
      SafeHttp.resolver = (_) async => [InternetAddress('192.168.0.1')];
      final service = ZapService(httpClient: _mockLnurl());
      await expectRefused(() => service.fetchPayInfo('alice@wallet.example'));
    });

    test('a redirect is not followed', () async {
      final service = ZapService(
        httpClient: MockClient(
          (r) async => http.Response(
            '',
            302,
            headers: {'location': 'http://192.168.1.1/admin'},
          ),
        ),
      );
      await expectRefused(() => service.fetchPayInfo('alice@wallet.example'));
    });

    test(
      'decimal limits and a callback with its own query still work',
      () async {
        Uri? asked;
        final service = ZapService(
          httpClient: _mockLnurl(
            payInfo: {
              'callback': 'https://wallet.example/cb?k1=abc',
              'minSendable': 1000.0,
              'maxSendable': 100000000.0,
              'allowsNostr': true,
            },
            onRequest: (r) => asked = r.url,
          ),
        );
        final invoice = await service.requestInvoice(
          signer: signer,
          lightningAddressOrLnurl: 'alice@wallet.example',
          recipientPubkey: _recipient,
          amountSats: 21,
        );
        expect(invoice.amountSats, 21);
        expect(asked!.queryParameters['k1'], 'abc');
      },
    );
  });

  group('ZapReceipt', () {
    NostrEvent receiptEvent(String description) => NostrEvent(
      id: 'b' * 64,
      pubkey: 'c' * 64, // LN provider pubkey
      createdAt: 1700000000,
      kind: NostrKinds.zapReceipt,
      tags: [
        ['p', _recipient],
        ['description', description],
      ],
      content: '',
      sig: 'd' * 128,
    );

    Future<String> request({
      Signer? by,
      String content = 'bellissima!',
      String to = _recipient,
      String amount = '50000',
    }) async => jsonEncode(
      (await (by ?? signer).signEvent(
        kind: NostrKinds.zapRequest,
        content: content,
        tags: [
          ['p', to],
          ['e', 'e' * 64],
          ['amount', amount],
        ],
      )).toJson(),
    );

    test('parses sender, amount, comment and zapped event', () async {
      final receipt = ZapReceipt.fromEvent(receiptEvent(await request()));
      expect(receipt, isNotNull);
      expect(receipt!.sender, signer.publicKey);
      expect(receipt.amountSats, 50);
      expect(receipt.comment, 'bellissima!');
      expect(receipt.eventId, 'e' * 64);
    });

    test(
      'the amount is the one of the paid invoice, not the sender\'s claim',
      () async {
        final event = NostrEvent(
          id: 'b' * 64,
          pubkey: 'c' * 64,
          createdAt: 1700000000,
          kind: NostrKinds.zapReceipt,
          tags: [
            ['p', _recipient],
            ['bolt11', _invoice21],
            ['description', await request(amount: '999000000')],
          ],
          content: '',
          sig: 'd' * 128,
        );
        expect(ZapReceipt.fromEvent(event)!.amountSats, 21);
      },
    );

    test(
      'a request that is not signed by its sender is nobody\'s zap',
      () async {
        final signed = jsonDecode(await request()) as Map<String, dynamic>;
        // Same event, somebody else's name on it.
        final impostor = {...signed, 'pubkey': 'a' * 64};
        expect(
          ZapReceipt.fromEvent(receiptEvent(jsonEncode(impostor))),
          isNull,
        );
        // Same name, a different message.
        final tampered = {...signed, 'content': 'ti mando un milione'};
        expect(
          ZapReceipt.fromEvent(receiptEvent(jsonEncode(tampered))),
          isNull,
        );
        // Not even signed.
        final bare = {...signed, 'sig': ''};
        expect(ZapReceipt.fromEvent(receiptEvent(jsonEncode(bare))), isNull);
      },
    );

    test(
      'a request for somebody else, or of another kind, is refused',
      () async {
        expect(
          ZapReceipt.fromEvent(receiptEvent(await request(to: 'f' * 64))),
          isNull,
          reason: 'addressed to another person than the receipt',
        );
        final reaction = await signer.signEvent(
          kind: NostrKinds.reaction,
          content: '+',
          tags: [
            ['p', _recipient],
          ],
        );
        expect(
          ZapReceipt.fromEvent(receiptEvent(jsonEncode(reaction.toJson()))),
          isNull,
        );
      },
    );

    test('returns null for other kinds and malformed descriptions', () {
      expect(
        ZapReceipt.fromEvent(
          NostrEvent(
            id: 'b' * 64,
            pubkey: 'c' * 64,
            createdAt: 1700000000,
            kind: NostrKinds.reaction,
            tags: const [],
            content: '+',
            sig: 'd' * 128,
          ),
        ),
        isNull,
      );
      expect(ZapReceipt.fromEvent(receiptEvent('not json')), isNull);
      expect(
        ZapReceipt.fromEvent(receiptEvent(jsonEncode({'content': 'x'}))),
        isNull,
      );
    });
  });
}
