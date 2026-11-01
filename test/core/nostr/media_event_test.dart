import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/models/media_event.dart';

NostrEvent fakeEvent({
  required int kind,
  String content = '',
  List<List<String>> tags = const [],
  int createdAt = 1700000000,
  String pubkey =
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
  String id = 'a',
}) => NostrEvent(
  id: id,
  pubkey: pubkey,
  createdAt: createdAt,
  kind: kind,
  tags: tags,
  content: content,
  sig: '',
);

void main() {
  group('MediaPost parsing', () {
    test('parses a NIP-68 kind 20 with imeta', () {
      final post = MediaPost.tryParse(
        fakeEvent(
          kind: 20,
          content: 'Tramonto #mialuna',
          tags: [
            [
              'imeta',
              'url https://cdn.example.com/a.jpg',
              'm image/jpeg',
              'dim 1080x1350',
              'alt Un tramonto sul mare',
            ],
            ['t', 'mialuna'],
            ['title', 'Tramonto'],
          ],
        ),
      );
      expect(post, isNotNull);
      expect(post!.media.single.url, 'https://cdn.example.com/a.jpg');
      expect(post.media.single.width, 1080);
      expect(post.media.single.height, 1350);
      expect(post.media.single.alt, 'Un tramonto sul mare');
      expect(post.caption, 'Tramonto #mialuna');
      expect(post.hashtags, contains('mialuna'));
      expect(post.isCarousel, false);
      expect(post.isVideo, false);
    });

    test('parses carousels as a single post with multiple media', () {
      final post = MediaPost.tryParse(
        fakeEvent(
          kind: 20,
          tags: [
            ['imeta', 'url https://cdn.example.com/1.jpg', 'm image/jpeg'],
            ['imeta', 'url https://cdn.example.com/2.jpg', 'm image/jpeg'],
            ['imeta', 'url https://cdn.example.com/3.jpg', 'm image/jpeg'],
          ],
        ),
      );
      expect(post!.media.length, 3);
      expect(post.isCarousel, true);
    });

    test('kind 21 is video, kind 22 is reel', () {
      final video = MediaPost.tryParse(
        fakeEvent(
          kind: 21,
          tags: [
            ['imeta', 'url https://cdn.example.com/v.mp4', 'm video/mp4'],
          ],
        ),
      );
      expect(video!.isVideo, true);
      expect(video.isReel, false);

      final reel = MediaPost.tryParse(
        fakeEvent(
          kind: 22,
          tags: [
            ['imeta', 'url https://cdn.example.com/r.mp4', 'm video/mp4'],
          ],
        ),
      );
      expect(reel!.isReel, true);
    });

    test('kind 1 text notes are never media posts', () {
      expect(MediaPost.tryParse(fakeEvent(kind: 1, content: 'ciao')), isNull);
      expect(
        MediaPost.tryParse(
          fakeEvent(kind: 1, content: 'guarda https://x.com/a.jpg'),
        ),
        isNull,
      );
    });

    test('kind 20 without media is rejected', () {
      expect(MediaPost.tryParse(fakeEvent(kind: 20, content: 'vuoto')), isNull);
    });

    test('external posts without #mialuna remain visible', () {
      final post = MediaPost.tryParse(
        fakeEvent(
          kind: 20,
          content: 'da un altro client',
          tags: [
            ['imeta', 'url https://cdn.example.com/x.jpg', 'm image/jpeg'],
          ],
        ),
      );
      expect(post, isNotNull);
      expect(post!.hashtags, isNot(contains('mialuna')));
    });

    test('content-warning marks sensitive content', () {
      final post = MediaPost.tryParse(
        fakeEvent(
          kind: 20,
          tags: [
            ['imeta', 'url https://cdn.example.com/x.jpg'],
            ['content-warning', 'nudità'],
          ],
        ),
      );
      expect(post!.isSensitive, true);
      expect(post.sensitiveReason, 'nudità');
    });

    test('story marker identification', () {
      final story = MediaPost.tryParse(
        fakeEvent(
          kind: 20,
          tags: [
            ['imeta', 'url https://cdn.example.com/x.jpg'],
            ['L', 'mialuna.story'],
            ['l', 'story', 'mialuna.story'],
            [
              'expiration',
              '${DateTime.now().millisecondsSinceEpoch ~/ 1000 + 86400}',
            ],
          ],
        ),
      );
      expect(story!.isStory, true);
      expect(story.isExpired(), false);
    });

    test('expired stories disappear', () {
      final story = MediaPost.tryParse(
        fakeEvent(
          kind: 20,
          tags: [
            ['imeta', 'url https://cdn.example.com/x.jpg'],
            ['l', 'story', 'mialuna.story'],
            ['expiration', '1000'],
          ],
        ),
      );
      expect(story!.isExpired(), true);
    });

    test('falls back to url tags and content URLs', () {
      final fromUrlTag = MediaPost.tryParse(
        fakeEvent(
          kind: 21,
          tags: [
            ['url', 'https://cdn.example.com/v.mp4'],
          ],
        ),
      );
      expect(fromUrlTag, isNotNull);

      final fromContent = MediaPost.tryParse(
        fakeEvent(kind: 20, content: 'foto https://cdn.example.com/x.png'),
      );
      expect(fromContent, isNotNull);
      expect(fromContent!.media.single.isImage, true);
    });
  });

  group('MediaPost.buildTags', () {
    test('builds imeta + caption hashtags + t tags', () {
      final tags = MediaPost.buildTags(
        media: const [
          MediaItem(url: 'https://x/a.jpg', mimeType: 'image/jpeg'),
        ],
        caption: 'Ciao #mare #Mare',
      );
      expect(tags.any((t) => t[0] == 'imeta'), true);
      expect(tags.where((t) => t[0] == 't' && t[1] == 'mare').length, 1);
    });

    test('carousel emits plain url tags for compatibility', () {
      final tags = MediaPost.buildTags(
        media: const [
          MediaItem(url: 'https://x/1.jpg'),
          MediaItem(url: 'https://x/2.jpg'),
        ],
        caption: '',
      );
      expect(tags.where((t) => t[0] == 'url').length, 2);
    });

    test('story tags and expiration included when requested', () {
      final tags = MediaPost.buildTags(
        media: const [MediaItem(url: 'https://x/1.jpg')],
        caption: '',
        isStory: true,
        expiresAt: 12345,
      );
      expect(tags.any((t) => t[0] == 'L' && t[1] == 'mialuna.story'), true);
      expect(tags.any((t) => t[0] == 'expiration' && t[1] == '12345'), true);
    });
  });
}
