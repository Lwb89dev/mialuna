import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/nostr/zap_service.dart';

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
    return http.Response(
      jsonEncode(invoice ?? {'pr': 'lnbc210n1exampleinvoice'}),
      200,
    );
  });
}

void main() {
  final signer = NsecSigner.fromNsec(_privKey);

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
      expect(invoice.bolt11, 'lnbc210n1exampleinvoice');
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

    test('parses sender, amount, comment and zapped event', () {
      final description = jsonEncode({
        'pubkey': _privKey.replaceAll(RegExp('.'), 'a'),
        'content': 'bellissima!',
        'tags': [
          ['p', _recipient],
          ['e', 'e' * 64],
          ['amount', '50000'],
        ],
      });
      final receipt = ZapReceipt.fromEvent(receiptEvent(description));
      expect(receipt, isNotNull);
      expect(receipt!.sender, 'a' * 64);
      expect(receipt.amountSats, 50);
      expect(receipt.comment, 'bellissima!');
      expect(receipt.eventId, 'e' * 64);
    });

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
