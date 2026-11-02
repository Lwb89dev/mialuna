import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mialuna/core/net/safe_http.dart';
import 'package:mialuna/core/nostr/bolt11.dart';
import 'package:mialuna/core/nostr/nip05.dart';

void main() {
  setUp(
    () => SafeHttp.resolver = (_) async => [InternetAddress('93.184.216.34')],
  );
  tearDown(() => SafeHttp.resolver = InternetAddress.lookup);

  group('which addresses are public', () {
    bool pub(String a) => SafeHttp.isPublicAddress(InternetAddress(a));

    test('the internet', () {
      for (final a in [
        '93.184.216.34',
        '8.8.8.8',
        '1.1.1.1',
        '2606:4700:4700::1111',
      ]) {
        expect(pub(a), true, reason: a);
      }
    });

    test('never the local network', () {
      for (final a in [
        '0.0.0.0',
        '10.0.0.1',
        '127.0.0.1',
        '127.8.8.8',
        '169.254.169.254',
        '172.16.0.1',
        '172.31.255.255',
        '192.168.1.1',
        '100.64.0.1',
        '192.0.0.8',
        '198.18.0.1',
        '224.0.0.1',
        '255.255.255.255',
        '::',
        '::1',
        'fe80::1',
        'fc00::1',
        'fd12:3456::1',
        '2001:db8::1',
        'ff02::1',
        '::ffff:192.168.1.1',
        '::ffff:127.0.0.1',
      ]) {
        expect(pub(a), false, reason: a);
      }
    });

    test('172.15 and 172.32 are ordinary addresses', () {
      expect(pub('172.15.0.1'), true);
      expect(pub('172.32.0.1'), true);
    });
  });

  group('getJson', () {
    http.Client answer(
      int status,
      String body, {
      Map<String, String> headers = const {},
    }) =>
        MockClient((r) async => http.Response(body, status, headers: headers));

    test('reads a small JSON answer', () async {
      final json = await SafeHttp.getJson(
        Uri.https('example.com', '/x'),
        client: answer(200, '{"a":1}'),
      );
      expect(json, {'a': 1});
    });

    test('plain http, credentials and odd hosts are never contacted', () async {
      var contacted = 0;
      final client = MockClient((r) async {
        contacted++;
        return http.Response('{}', 200);
      });
      for (final uri in [
        Uri.parse('http://example.com/x'),
        Uri.parse('https://user:pw@example.com/x'),
        Uri.parse('https://localhost/x'),
        Uri.parse('https://192.168.1.1/x'),
        Uri.parse('https://[::1]/x'),
        Uri.parse('https://printer.local/x'),
        Uri.parse('https://10.0.0.5/x'),
      ]) {
        await expectLater(
          SafeHttp.getJson(uri, client: client),
          throwsA(isA<SafeHttpException>()),
          reason: '$uri',
        );
      }
      expect(contacted, 0);
    });

    test('a public-looking name that resolves inside is refused', () async {
      SafeHttp.resolver = (_) async => [InternetAddress('127.0.0.1')];
      await expectLater(
        SafeHttp.getJson(
          Uri.https('evil.example', '/x'),
          client: answer(200, '{}'),
        ),
        throwsA(isA<SafeHttpException>()),
      );
      // Even when only one of the answers is private.
      SafeHttp.resolver = (_) async => [
        InternetAddress('93.184.216.34'),
        InternetAddress('10.0.0.1'),
      ];
      await expectLater(
        SafeHttp.getJson(
          Uri.https('evil.example', '/x'),
          client: answer(200, '{}'),
        ),
        throwsA(isA<SafeHttpException>()),
      );
    });

    test('a name that does not resolve is refused', () async {
      SafeHttp.resolver = (_) async =>
          throw const SocketException('no such host');
      await expectLater(
        SafeHttp.getJson(
          Uri.https('nowhere.example', '/x'),
          client: answer(200, '{}'),
        ),
        throwsA(isA<SafeHttpException>()),
      );
    });

    test('redirects and errors are failures', () async {
      for (final status in [301, 302, 307, 404, 500]) {
        await expectLater(
          SafeHttp.getJson(
            Uri.https('example.com', '/x'),
            client: answer(
              status,
              '{}',
              headers: {'location': 'http://10.0.0.1/'},
            ),
          ),
          throwsA(isA<SafeHttpException>()),
          reason: '$status',
        );
      }
    });

    test('an answer that is too big is cut off', () async {
      final huge = '{"x":"${'a' * (SafeHttp.maxJsonBytes + 10)}"}';
      await expectLater(
        SafeHttp.getJson(
          Uri.https('example.com', '/x'),
          client: answer(200, huge),
        ),
        throwsA(isA<SafeHttpException>()),
      );
    });

    test('something that is not JSON is a failure, not a crash', () async {
      await expectLater(
        SafeHttp.getJson(
          Uri.https('example.com', '/x'),
          client: answer(200, '<html>'),
        ),
        throwsA(isA<SafeHttpException>()),
      );
    });
  });

  group('NIP-05 through the same door', () {
    final pubkey = 'ab' * 32;

    test('resolves a name', () async {
      final client = MockClient(
        (r) async => http.Response(
          jsonEncode({
            'names': {'luna': pubkey},
          }),
          200,
        ),
      );
      expect(await Nip05.resolve('luna@example.com', client: client), pubkey);
      expect(
        await Nip05.verify('luna@example.com', pubkey, client: client),
        true,
      );
      expect(
        await Nip05.verify('luna@example.com', 'cd' * 32, client: client),
        false,
      );
    });

    test('a redirect to somewhere else resolves to nothing', () async {
      final client = MockClient(
        (r) async => http.Response(
          '',
          302,
          headers: {'location': 'https://elsewhere.example/'},
        ),
      );
      expect(await Nip05.resolve('luna@example.com', client: client), isNull);
    });

    test(
      'a domain that points inside the network resolves to nothing',
      () async {
        SafeHttp.resolver = (_) async => [InternetAddress('192.168.0.1')];
        final client = MockClient(
          (r) async => http.Response(
            jsonEncode({
              'names': {'luna': pubkey},
            }),
            200,
          ),
        );
        expect(await Nip05.resolve('luna@example.com', client: client), isNull);
      },
    );

    test('garbage answers never throw', () async {
      for (final body in ['[]', '{"names":[]}', '{"names":{"luna":5}}', 'x']) {
        final client = MockClient((r) async => http.Response(body, 200));
        expect(
          await Nip05.resolve('luna@example.com', client: client),
          isNull,
          reason: body,
        );
      }
    });
  });

  group('Bolt11.amountMsats', () {
    BigInt? amount(String hrp) =>
        Bolt11.amountMsats('${hrp}1pvjluezpp5qqqsyqcyq5rqwzqfqqqsyqcy');

    test('reads each unit', () {
      expect(amount('lnbc210n'), BigInt.from(21000)); // 21 sats
      expect(
        amount('lnbc2500u'),
        BigInt.from(250000000),
      ); // the BOLT-11 example
      expect(amount('lnbc20m'), BigInt.from(2000000000));
      expect(amount('lnbc1'), BigInt.from(100000000000)); // one bitcoin
      expect(amount('lnbc9678785340p'), BigInt.from(967878534));
      expect(amount('lntb1500n'), BigInt.from(150000));
    });

    test('no amount, or an impossible one, is not an amount', () {
      expect(Bolt11.amountMsats('lnbc1pvjluezpp5qqqsyqcy'), isNull);
      expect(amount('lnbc15p'), isNull, reason: 'pico must come in tens');
    });

    test('what is not an invoice is not one', () {
      for (final s in [
        '',
        'lightning:lnbc1pvj',
        'bitcoin:abc',
        'lnbc210n1not-bech32',
        'LNBC210N1PVJLUEZ'.substring(0, 3),
      ]) {
        expect(Bolt11.amountMsats(s), isNull, reason: s);
      }
    });

    test('is case-insensitive like bech32', () {
      expect(
        Bolt11.amountMsats('LNBC210N1PVJLUEZPP5QQQSYQCYQ5RQWZQFQQQSYQCY'),
        BigInt.from(21000),
      );
    });
  });
}
