import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mialuna/core/media/media_cipher.dart';
import 'package:mialuna/core/media/private_media.dart';
import 'package:mialuna/core/nostr/models/media_event.dart';

MediaItem itemFor(
  EncryptedBlob blob, {
  String? url,
  List<String> fallbacks = const [],
  String? ox,
  String? x,
  String mime = 'image/jpeg',
}) => MediaItem(
  url: url ?? 'https://blossom.example/blob',
  mimeType: mime,
  sha256: x ?? blob.sha256,
  plainSha256: ox ?? blob.plainSha256,
  fallbackUrls: fallbacks,
  encryption: MediaEncryption(key: blob.key, nonce: blob.nonce),
);

void main() {
  final plain = Uint8List.fromList(List.generate(2000, (i) => i % 200));
  late EncryptedBlob blob;
  late Directory dir;

  setUp(() {
    blob = MediaCipher.encrypt(plain);
    dir = Directory.systemTemp.createTempSync('mialuna_pm_');
  });

  PrivateMediaService serving(
    Map<String, Uint8List> files, {
    void Function(Uri)? onGet,
  }) => PrivateMediaService(
    MockClient((req) async {
      onGet?.call(req.url);
      final f = files[req.url.toString()];
      return f == null ? http.Response('', 404) : http.Response.bytes(f, 200);
    }),
    directory: dir,
  );

  test('downloads, checks both hashes and decrypts', () async {
    final service = serving({'https://blossom.example/blob': blob.bytes});
    expect(await service.imageBytes(itemFor(blob)), plain);
  });

  test('is cached: the second look does not hit the network again', () async {
    var gets = 0;
    final service = serving({
      'https://blossom.example/blob': blob.bytes,
    }, onGet: (_) => gets++);
    final item = itemFor(blob);
    await service.imageBytes(item);
    await service.imageBytes(item);
    expect(gets, 1);
  });

  test('a swapped file on the server is refused', () async {
    final other = MediaCipher.encrypt(Uint8List.fromList([9, 9, 9]));
    final service = serving({'https://blossom.example/blob': other.bytes});
    await expectLater(
      service.imageBytes(itemFor(blob)),
      throwsA(isA<MediaCipherException>()),
    );
  });

  test('plaintext that does not match the declared hash is refused', () async {
    final service = serving({'https://blossom.example/blob': blob.bytes});
    await expectLater(
      service.imageBytes(itemFor(blob, ox: 'ab' * 32)),
      throwsA(isA<MediaCipherException>()),
    );
  });

  test('falls back to a mirror when the first URL is gone', () async {
    final service = serving({'https://mirror.example/blob': blob.bytes});
    final item = itemFor(blob, fallbacks: ['https://mirror.example/blob']);
    expect(await service.imageBytes(item), plain);
  });

  test('a file announced as huge is never read', () async {
    final service = PrivateMediaService(
      MockClient.streaming(
        (req, body) async => http.StreamedResponse(
          Stream.value(Uint8List(10)),
          200,
          contentLength: PrivateMediaService.maxFileBytes + 100000,
        ),
      ),
      directory: dir,
    );
    await expectLater(
      service.imageBytes(itemFor(blob)),
      throwsA(
        isA<MediaCipherException>().having(
          (e) => e.message,
          'm',
          contains('large'),
        ),
      ),
    );
  });

  test('a stream that outgrows the limit is cut off', () async {
    final chunk = Uint8List(8 * 1024 * 1024);
    final service = PrivateMediaService(
      MockClient.streaming(
        (req, body) async => http.StreamedResponse(
          Stream.fromIterable(
            List.filled(20, chunk),
          ), // 160 MB, no length given
          200,
        ),
      ),
      directory: dir,
    );
    await expectLater(
      service.imageBytes(itemFor(blob)),
      throwsA(isA<MediaCipherException>()),
    );
  });

  test('without a key there is nothing to decrypt', () async {
    final service = serving({});
    await expectLater(
      service.imageBytes(const MediaItem(url: 'https://x.example/a.jpg')),
      throwsA(isA<MediaCipherException>()),
    );
  });

  test('decrypted videos become files, are reused, and can be wiped', () async {
    var gets = 0;
    final video = Uint8List.fromList(List.generate(5000, (i) => i % 17));
    final enc = MediaCipher.encrypt(video);
    final service = serving({
      'https://blossom.example/blob': enc.bytes,
    }, onGet: (_) => gets++);
    final item = itemFor(enc, mime: 'video/mp4');
    final file = await service.videoFile(item);
    expect(file.path, endsWith('.mp4'));
    expect(file.readAsBytesSync(), video);
    final again = await service.videoFile(item);
    expect(again.path, file.path);
    expect(gets, 1);
    await service.cleanUp(everything: true);
    expect(file.existsSync(), false);
  });

  test('a failed download is not remembered: the retry works', () async {
    var up = false;
    final service = PrivateMediaService(
      MockClient(
        (req) async =>
            up ? http.Response.bytes(blob.bytes, 200) : http.Response('', 503),
      ),
      directory: dir,
    );
    final item = itemFor(blob, mime: 'video/mp4');
    await expectLater(
      service.videoFile(item),
      throwsA(isA<MediaCipherException>()),
    );
    up = true;
    expect((await service.videoFile(item)).readAsBytesSync(), plain);
  });
}
