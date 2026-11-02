import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/nwc_service.dart';
import 'package:mialuna/core/nostr/relay.dart';

void main() {
  test('wss anywhere; ws only on the user\'s own network', () {
    for (final ok in [
      'wss://relay.damus.io',
      'wss://relay.example.com/path',
      'ws://localhost:7777',
      'ws://127.0.0.1:40495',
      'ws://192.168.1.20:4848',
      'ws://10.0.0.2',
      'ws://relay.local',
      'ws://myrelay',
    ]) {
      expect(isAcceptableRelayUrl(ok), true, reason: ok);
    }
    for (final bad in [
      'ws://relay.damus.io',
      'ws://93.184.216.34',
      'ws://example.com:80',
      'http://relay.example.com',
      'https://relay.example.com',
      'ftp://relay.example.com',
      'wss://',
      'relay.example.com',
      '',
    ]) {
      expect(isAcceptableRelayUrl(bad), false, reason: bad);
    }
  });

  test('a wallet link only keeps relays worth talking to', () {
    final uri =
        'nostr+walletconnect://${'ab' * 32}?relay=ws%3A%2F%2Fevil.example.com'
        '&relay=wss%3A%2F%2Frelay.example.com&secret=${'cd' * 32}';
    expect(NwcConnection.parse(uri).relays, ['wss://relay.example.com']);
    expect(
      () => NwcConnection.parse(
        'nostr+walletconnect://${'ab' * 32}?relay=ws%3A%2F%2Fevil.example.com&secret=${'cd' * 32}',
      ),
      throwsA(isA<NwcException>()),
    );
  });
}
