import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/media/upload_keys.dart';
import 'package:mialuna/core/storage/local_cache.dart';

void main() {
  late Directory dir;
  late LocalCache cache;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('mialuna_keys_');
    cache = LocalCache(directory: dir);
  });
  tearDown(() => dir.deleteSync(recursive: true));

  String hash(int n) => sha256.convert(utf8.encode('file $n')).toString();

  test('remembers the key behind each file, also after a restart', () async {
    await UploadKeys(cache, 'alice').remember([hash(1), hash(2)], 'aa');
    await UploadKeys(cache, 'alice').remember([hash(3)], 'bb');

    final again = UploadKeys(LocalCache(directory: dir), 'alice');
    expect(await again.keysFor([hash(1), hash(2), hash(3), hash(4)]), {
      hash(1): 'aa',
      hash(2): 'aa',
      hash(3): 'bb',
    });
  });

  test('keeps one account\'s keys apart from another\'s', () async {
    await UploadKeys(cache, 'alice').remember([hash(1)], 'aa');

    expect(await UploadKeys(cache, 'bob').keysFor([hash(1)]), isEmpty);
    expect(await UploadKeys(cache, 'alice').keysFor([hash(1)]), {
      hash(1): 'aa',
    });
  });

  test('forgets the files that are gone, and only those', () async {
    final keys = UploadKeys(cache, 'alice');
    await keys.remember([hash(1), hash(2)], 'aa');

    await keys.forget([hash(1), hash(9)]);

    expect(await keys.keysFor([hash(1), hash(2)]), {hash(2): 'aa'});
  });

  test('does nothing without an account', () async {
    final keys = UploadKeys(cache, null);

    await keys.remember([hash(1)], 'aa');
    await keys.forget([hash(1)]);

    expect(await keys.keysFor([hash(1)]), isEmpty);
    expect(dir.listSync(), isEmpty);
  });

  test('the oldest keys go first once there are too many', () async {
    final keys = UploadKeys(cache, 'alice');
    final all = [for (var i = 0; i < 605; i++) hash(i)];
    await keys.remember(all, 'aa');

    final kept = await keys.keysFor(all);

    expect(kept.length, 600);
    expect(kept.containsKey(hash(4)), false);
    expect(kept.containsKey(hash(5)), true);
    expect(kept.containsKey(hash(604)), true);
  });

  test('remembering again moves a file to the newest end', () async {
    final keys = UploadKeys(cache, 'alice');
    await keys.remember([hash(0)], 'old');
    await keys.remember([for (var i = 1; i < 600; i++) hash(i)], 'aa');
    await keys.remember([hash(0)], 'new'); // 600 entries, hash(0) newest
    await keys.remember([hash(600)], 'aa'); // one too many: hash(1) goes

    expect(await keys.keysFor([hash(0), hash(1)]), {hash(0): 'new'});
  });

  test('simultaneous writers do not lose each other\'s keys', () async {
    final keys = UploadKeys(cache, 'alice');

    await Future.wait([
      for (var i = 0; i < 25; i++) keys.remember([hash(i)], 'k$i'),
    ]);

    final found = await keys.keysFor([for (var i = 0; i < 25; i++) hash(i)]);
    expect(found.length, 25);
    expect(found[hash(24)], 'k24');
  });

  test(
    'a damaged file reads as empty and is rewritten on the next key',
    () async {
      File(
        '${dir.path}/${UploadKeys.fileFor('alice')}',
      ).writeAsStringSync('{oops');
      final keys = UploadKeys(cache, 'alice');

      expect(await keys.keysFor([hash(1)]), isEmpty);
      await keys.remember([hash(1)], 'aa');

      expect(await keys.keysFor([hash(1)]), {hash(1): 'aa'});
    },
  );
}
