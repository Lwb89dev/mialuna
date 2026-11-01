import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/nip51.dart';

NostrEvent listEvent(int kind, List<List<String>> tags) => NostrEvent(
  id: 'a' * 64,
  pubkey: 'b' * 64,
  createdAt: 1700000000,
  kind: kind,
  tags: tags,
  content: '',
  sig: 'c' * 128,
);

void main() {
  group('Nip51 bookmarks (kind 10003)', () {
    test('tags round-trip through parsing', () {
      final ids = {'e' * 64, 'f' * 64};
      final event = listEvent(NostrKinds.bookmarks, Nip51.bookmarkTags(ids));
      expect(Nip51.bookmarkIds(event), ids);
    });

    test('ignores non-e tags and other kinds', () {
      final event = listEvent(NostrKinds.bookmarks, [
        ['e', 'e' * 64],
        ['p', 'b' * 64],
      ]);
      expect(Nip51.bookmarkIds(event), {'e' * 64});
      expect(
        Nip51.bookmarkIds(
          listEvent(NostrKinds.muteList, [
            ['e', 'e' * 64],
          ]),
        ),
        isEmpty,
      );
    });
  });

  group('Nip51 mute list (kind 10000)', () {
    test('tags round-trip through parsing', () {
      final pubs = {'a' * 64, 'b' * 64};
      final event = listEvent(NostrKinds.muteList, Nip51.muteTags(pubs));
      expect(Nip51.mutedPubkeys(event), pubs);
    });

    test('hashtags round-trip and are lowercased', () {
      final event = listEvent(
        NostrKinds.muteList,
        Nip51.muteTags({'a' * 64}, hashtags: {'Moon', 'sea'}),
      );
      expect(Nip51.mutedPubkeys(event), {'a' * 64});
      expect(Nip51.mutedHashtags(event), {'moon', 'sea'});
    });

    test('ignores other kinds', () {
      expect(
        Nip51.mutedPubkeys(
          listEvent(NostrKinds.bookmarks, [
            ['p', 'a' * 64],
          ]),
        ),
        isEmpty,
      );
      expect(
        Nip51.mutedHashtags(
          listEvent(NostrKinds.bookmarks, [
            ['t', 'moon'],
          ]),
        ),
        isEmpty,
      );
    });
  });
}
