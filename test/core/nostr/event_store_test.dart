import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/event_store.dart';
import 'package:mialuna/core/nostr/filter.dart';

NostrEvent ev(
  String id,
  int kind, {
  int createdAt = 1000,
  String pubkey = 'a',
}) => NostrEvent(
  id: id,
  pubkey: pubkey,
  createdAt: createdAt,
  kind: kind,
  tags: const [],
  content: '',
  sig: '',
);

void main() {
  group('EventStore', () {
    test('deduplicates by id', () {
      final store = EventStore();
      expect(store.add(ev('x', 20)), true);
      expect(store.add(ev('x', 20)), false);
      expect(store.length, 1);
    });

    test('keeps newest replaceable event (kind 0)', () {
      final store = EventStore();
      expect(store.add(ev('old', 0, createdAt: 100)), true);
      expect(store.add(ev('older', 0, createdAt: 50)), false);
      expect(store.add(ev('new', 0, createdAt: 200)), true);
      expect(store.latestReplaceable(0, 'a')!.id, 'new');
    });

    test('query filters by kind and sorts newest-first', () {
      final store = EventStore();
      store.add(ev('a', 20, createdAt: 1));
      store.add(ev('b', 1, createdAt: 999));
      store.add(ev('c', 20, createdAt: 500));
      final media = store.query(kinds: NostrKinds.mediaKinds);
      expect(media.map((e) => e.id), ['c', 'a']);
    });

    test('query limit', () {
      final store = EventStore();
      for (var i = 0; i < 10; i++) {
        store.add(ev('e$i', 20, createdAt: i));
      }
      expect(store.query(limit: 5).length, 5);
    });
  });

  group('NostrFilter', () {
    test('matches kinds/authors/tags', () {
      final filter = const NostrFilter(
        kinds: [20],
        authors: ['a'],
        tagFilters: {
          '#t': ['mialuna'],
        },
      );
      final match = NostrEvent(
        id: 'x',
        pubkey: 'a',
        createdAt: 100,
        kind: 20,
        tags: const [
          ['t', 'mialuna'],
        ],
        content: '',
        sig: '',
      );
      expect(filter.matches(match), true);
      expect(filter.matches(ev('y', 1, pubkey: 'a')), false);
      expect(filter.matches(ev('z', 20, pubkey: 'b')), false);
    });

    test('since/until bounds', () {
      const f = NostrFilter(since: 100, until: 200);
      expect(f.matches(ev('a', 20, createdAt: 150)), true);
      expect(f.matches(ev('b', 20, createdAt: 50)), false);
      expect(f.matches(ev('c', 20, createdAt: 250)), false);
    });
  });
}
