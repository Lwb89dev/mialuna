import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/nip65.dart';

NostrEvent relayListEvent(List<List<String>> tags) => NostrEvent(
  id: 'a' * 64,
  pubkey: 'b' * 64,
  createdAt: 1700000000,
  kind: 10002,
  tags: tags,
  content: '',
  sig: 'c' * 128,
);

void main() {
  group('parseRelayList', () {
    test('missing marker means read+write', () {
      final entries = parseRelayList(
        relayListEvent([
          ['r', 'wss://relay.example'],
        ]),
      );
      expect(entries.single.url, 'wss://relay.example');
      expect(entries.single.read, isTrue);
      expect(entries.single.write, isTrue);
    });

    test('read/write markers are honored', () {
      final entries = parseRelayList(
        relayListEvent([
          ['r', 'wss://read.example', 'read'],
          ['r', 'wss://write.example', 'write'],
          ['r', 'wss://both.example'],
        ]),
      );
      expect(entries[0].read, isTrue);
      expect(entries[0].write, isFalse);
      expect(entries[1].read, isFalse);
      expect(entries[1].write, isTrue);
      expect(entries[2].read, isTrue);
      expect(entries[2].write, isTrue);
    });

    test('deduplicates, skips non-r tags and invalid urls', () {
      final entries = parseRelayList(
        relayListEvent([
          ['r', 'wss://relay.example'],
          ['r', 'wss://relay.example', 'read'],
          ['r', 'http://not-a-relay.example'],
          ['p', 'd' * 64],
        ]),
      );
      expect(entries.map((e) => e.url), ['wss://relay.example']);
      // The first occurrence (no marker → read+write) wins.
      expect(entries.single.write, isTrue);
    });

    test('returns empty for other kinds', () {
      final event = NostrEvent(
        id: 'a' * 64,
        pubkey: 'b' * 64,
        createdAt: 1700000000,
        kind: 1,
        tags: const [
          ['r', 'wss://relay.example'],
        ],
        content: '',
        sig: 'c' * 128,
      );
      expect(parseRelayList(event), isEmpty);
    });
  });
}
