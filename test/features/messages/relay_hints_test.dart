import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/features/messages/share_utils.dart';

void main() {
  group('relayHints', () {
    test('the relay a post was really read from comes first', () {
      // A post can live on one relay only, and not the author's first ones.
      expect(
        relayHints(
          ['wss://first.example', 'wss://second.example'],
          ['wss://mine.example'],
          seenOn: 'wss://theforest.example',
        ),
        ['wss://theforest.example', 'wss://first.example'],
      );
    });

    test("without one, the author's relays, then this account's", () {
      expect(relayHints(['wss://a.example'], ['wss://mine.example']), [
        'wss://a.example',
        'wss://mine.example',
      ]);
    });

    test('only secure relays, each once', () {
      expect(
        relayHints(
          ['wss://a.example', 'ws://plain.example'],
          ['wss://a.example', 'wss://b.example'],
          seenOn: 'ws://127.0.0.1:7000',
        ),
        ['wss://a.example', 'wss://b.example'],
      );
    });
  });
}
