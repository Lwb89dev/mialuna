import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/models/media_event.dart';

NostrEvent event(int kind, List<List<String>> tags, {String content = ''}) =>
    NostrEvent(
      id: 'a' * 64,
      pubkey: 'b' * 64,
      createdAt: 1700000000,
      kind: kind,
      tags: tags,
      content: content,
      sig: 'c' * 128,
    );

void main() {
  group('media URLs from the wild', () {
    test(
      'web pages are not media (YouTube watch links seen as kind 21/22)',
      () {
        expect(
          isUsableMediaUrl('https://www.youtube.com/watch?v=aZqhAu-ReyM'),
          false,
        );
        expect(isUsableMediaUrl('https://youtu.be/aZqhAu-ReyM'), false);
        expect(isUsableMediaUrl('https://vimeo.com/123'), false);
        expect(isUsableMediaUrl('https://example.com/photo.jpg'), true);
        expect(
          isUsableMediaUrl('https://cdn.blossom.example/${'a' * 64}.mp4'),
          true,
        );
      },
    );

    test('loopback, LAN and non-http addresses are never fetched', () {
      expect(
        isUsableMediaUrl('http://127.0.0.1:4831/img/trace-en-h.png'),
        false,
      );
      expect(isUsableMediaUrl('http://localhost/x.png'), false);
      expect(isUsableMediaUrl('https://192.168.1.2/x.png'), false);
      expect(isUsableMediaUrl('https://10.1.2.3/x.png'), false);
      expect(isUsableMediaUrl('file:///etc/passwd'), false);
      expect(isUsableMediaUrl('javascript:alert(1)'), false);
      expect(isUsableMediaUrl('not a url'), false);
    });

    test('a post whose only media is a web page is not a post', () {
      final e = event(21, [
        ['imeta', 'url https://www.youtube.com/watch?v=abc', 'm image/jpeg'],
      ]);
      expect(MediaPost.tryParse(e), isNull);
    });

    test('a post pointing at the local network is dropped', () {
      final e = event(20, [
        ['imeta', 'url http://127.0.0.1:4831/img/trace-en-h.png'],
      ]);
      expect(MediaPost.tryParse(e), isNull);
    });
  });

  group('photo vs video items', () {
    test('a photo event ignores video items and the other way round', () {
      final photo = MediaPost.tryParse(
        event(20, [
          ['imeta', 'url https://x.example/a.jpg', 'm image/jpeg'],
          ['imeta', 'url https://x.example/b.mp4', 'm video/mp4'],
        ]),
      )!;
      expect(photo.media.map((m) => m.url), ['https://x.example/a.jpg']);

      expect(
        MediaPost.tryParse(
          event(22, [
            ['imeta', 'url https://x.example/a.jpg', 'm image/jpeg'],
          ]),
        ),
        isNull,
        reason: 'a reel with only an image cannot be played',
      );
    });

    test(
      'items without mime type or extension are accepted for either kind',
      () {
        final hash = 'f' * 64;
        expect(
          MediaPost.tryParse(
            event(20, [
              ['imeta', 'url https://x.example/$hash'],
            ]),
          ),
          isNotNull,
        );
        expect(
          MediaPost.tryParse(
            event(22, [
              ['imeta', 'url https://x.example/$hash'],
            ]),
          ),
          isNotNull,
        );
      },
    );

    test('type comes from the declared mime first, then the extension', () {
      expect(
        const MediaItem(url: 'https://x/a.bin', mimeType: 'video/mp4').isVideo,
        true,
      );
      expect(const MediaItem(url: 'https://x/a.mp4').isVideo, true);
      expect(const MediaItem(url: 'https://x/a.PNG?x=1').isImage, true);
      expect(const MediaItem(url: 'https://x/blob').type, MediaType.unknown);
    });
  });

  group('imeta details', () {
    test('thumbnail, fallback mirrors, duration and dimensions are read', () {
      final post = MediaPost.tryParse(
        event(22, [
          [
            'imeta',
            'url https://x.example/v.mp4',
            'm video/mp4',
            'dim 1080x1920',
            'image https://x.example/poster.jpg',
            'fallback https://mirror.example/v.mp4',
            'fallback http://127.0.0.1/evil.mp4',
          ],
          ['duration', '44'],
        ]),
      )!;
      final item = post.media.single;
      expect(item.previewUrl, 'https://x.example/poster.jpg');
      expect(item.fallbackUrls, [
        'https://mirror.example/v.mp4',
      ]); // unsafe one dropped
      expect(item.duration, 44);
      expect(item.aspectRatio, closeTo(9 / 16, 0.001));
    });

    test('poster declared outside imeta is picked up', () {
      final post = MediaPost.tryParse(
        event(21, [
          ['imeta', 'url https://x.example/v.mp4', 'm video/mp4'],
          ['image', 'https://x.example/poster.jpg'],
        ]),
      )!;
      expect(post.media.single.previewUrl, 'https://x.example/poster.jpg');
    });

    test('an unusable poster is dropped instead of failing at render time', () {
      final post = MediaPost.tryParse(
        event(21, [
          [
            'imeta',
            'url https://x.example/v.mp4',
            'image http://localhost/poster.jpg',
          ],
        ]),
      )!;
      expect(post.media.single.previewUrl, isNull);
    });
  });

  group('publishing tags', () {
    test('a title is always derived (NIP-68/71 require it)', () {
      expect(
        MediaPost.deriveTitle('Tramonto a Roma #mialuna'),
        'Tramonto a Roma',
      );
      expect(MediaPost.deriveTitle('#mialuna'), 'Mialuna');
      expect(MediaPost.deriveTitle(''), 'Mialuna');
      expect(MediaPost.deriveTitle('\n\n  seconda riga \n'), 'seconda riga');
      expect(MediaPost.deriveTitle('x' * 200).length, 80);
    });

    test('video events carry dimensions, poster and duration', () {
      final tags = MediaPost.buildTags(
        media: const [
          MediaItem(
            url: 'https://x.example/v.mp4',
            mimeType: 'video/mp4',
            sha256: 'ab',
            width: 1080,
            height: 1920,
            previewUrl: 'https://x.example/p.jpg',
          ),
        ],
        caption: 'ciao #mialuna',
        title: 'ciao',
        duration: 12.4,
        publishedAt: 1700000000,
      );
      final imeta = tags.firstWhere((t) => t[0] == 'imeta');
      expect(
        imeta,
        containsAll([
          'dim 1080x1920',
          'image https://x.example/p.jpg',
          'm video/mp4',
        ]),
      );
      bool has(String name, String value) =>
          tags.any((t) => t[0] == name && t[1] == value);
      expect(has('duration', '12'), true);
      expect(has('title', 'ciao'), true);
      expect(has('published_at', '1700000000'), true);
      expect(tags.where((t) => t[0] == 't').map((t) => t[1]), ['mialuna']);
    });

    test('a published post can be parsed back identically', () {
      final tags = MediaPost.buildTags(
        media: const [
          MediaItem(
            url: 'https://x.example/a.jpg',
            mimeType: 'image/jpeg',
            width: 800,
            height: 600,
          ),
        ],
        caption: 'x',
        title: 'x',
      );
      final back = MediaPost.tryParse(event(20, tags))!;
      expect(back.media.single.width, 800);
      expect(back.media.single.mimeType, 'image/jpeg');
    });
  });

  test('posts are equal when they come from the same event', () {
    final a = MediaPost.tryParse(
      event(20, [
        ['imeta', 'url https://x.example/a.jpg'],
      ]),
    )!;
    final b = MediaPost.tryParse(
      event(20, [
        ['imeta', 'url https://x.example/a.jpg'],
      ]),
    )!;
    expect(a, b);
    expect({a, b}, hasLength(1));
  });
}
