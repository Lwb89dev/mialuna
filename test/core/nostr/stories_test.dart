import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/filter.dart';
import 'package:mialuna/core/nostr/models/media_event.dart';

NostrEvent storyEvent({
  String id = 's1',
  String pubkey = 'a',
  int createdAt = 1700000000,
  int? expiration,
  List<List<String>>? extraTags,
  int kind = 20,
}) => NostrEvent(
  id: id,
  pubkey: pubkey,
  createdAt: createdAt,
  kind: kind,
  tags: [
    ['imeta', 'url https://cdn.example.com/story.jpg', 'm image/jpeg'],
    ['L', 'mialuna.story'],
    ['l', 'story', 'mialuna.story'],
    if (expiration != null) ['expiration', '$expiration'],
    ...?extraTags,
  ],
  content: 'una storia #mialuna',
  sig: '',
);

void main() {
  group('Stories (NIP-40 + label)', () {
    test('story with future expiration is visible', () {
      final future = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 86400;
      final post = MediaPost.tryParse(storyEvent(expiration: future));
      expect(post, isNotNull);
      expect(post!.isStory, true);
      expect(post.isExpired(), false);
    });

    test('story past 24h is expired and excluded', () {
      final post = MediaPost.tryParse(storyEvent(expiration: 1000)); // 1970
      expect(post!.isStory, true);
      expect(post.isExpired(), true);
    });

    test('story without expiration still parses but stays a story', () {
      final post = MediaPost.tryParse(storyEvent());
      expect(post!.isStory, true);
      expect(post.isExpired(), false);
    });

    test('video stories use kind 22', () {
      final post = MediaPost.tryParse(
        storyEvent(
          kind: 22,
          extraTags: [
            ['imeta', 'url https://cdn.example.com/v.mp4', 'm video/mp4'],
          ],
        ),
      );
      expect(post!.isStory, true);
      expect(post.isReel, true);
    });

    test('buildTags for stories includes label + expiration', () {
      final tags = MediaPost.buildTags(
        media: const [MediaItem(url: 'https://x/1.jpg')],
        caption: 'ciao #mialuna',
        isStory: true,
        expiresAt: 999999,
      );
      expect(tags.any((t) => t[0] == 'l' && t[1] == 'story'), true);
      expect(tags.any((t) => t[0] == 'expiration' && t[1] == '999999'), true);
      expect(tags.any((t) => t[0] == 't' && t[1] == 'mialuna'), true);
    });
  });

  group('NostrFilter NIP-50', () {
    test('serializes search field', () {
      const f = NostrFilter(kinds: [20], search: 'tramonto mare');
      expect(f.toJson()['search'], 'tramonto mare');
      expect(f.toJson()['kinds'], [20]);
    });

    test('omits search when null', () {
      const f = NostrFilter(kinds: [20]);
      expect(f.toJson().containsKey('search'), false);
    });
  });
}
