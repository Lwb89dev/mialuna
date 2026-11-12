import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/create/create_controller.dart';
import 'package:mialuna/features/create/editor/adjustments.dart';
import 'package:mialuna/features/create/editor/crop_tool.dart';
import 'package:mialuna/features/create/editor/image_edit_apply.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Edits are recipes kept next to the original: reopening the editor starts
/// from the untouched photo, and a look can be copied onto the whole post.
void main() {
  late Directory dir;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dir = Directory.systemTemp.createTempSync('mialuna_edit_');
  });

  ProviderContainer app() {
    final c = ProviderContainer(
      overrides: [
        localCacheProvider.overrideWithValue(LocalCache(directory: dir)),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  PickedMedia photo(int width, int height) {
    final image = img.Image(width: width, height: height);
    img.fill(image, color: img.ColorRgb8(120, 120, 120));
    final bytes = Uint8List.fromList(img.encodeJpg(image));
    return PickedMedia(
      file: XFile.fromData(bytes, name: 'p.jpg'),
      bytes: bytes,
      mimeType: 'image/jpeg',
    );
  }

  test('an edit keeps the original and the recipe; undoing it restores '
      'the original bytes', () {
    final c = app();
    final composer = c.read(composerProvider.notifier);
    final picked = photo(40, 30);
    composer.addPicked(picked..alt = 'a grey wall');

    const edit = ImageEdit(crop: Crop(right: 0.5));
    composer.applyEdit(0, edit, applyImageEdit(picked.bytes, edit));
    final edited = c.read(composerProvider).media.single;
    expect(img.decodeImage(edited.bytes)!.width, 20);
    expect(identical(edited.originalBytes, picked.bytes), isTrue);
    expect(edited.edit, edit);
    expect(edited.alt, 'a grey wall');

    composer.applyEdit(0, const ImageEdit(), null);
    final undone = c.read(composerProvider).media.single;
    expect(identical(undone.bytes, picked.bytes), isTrue);
    expect(undone.edit.isIdentity, isTrue);
  });

  test('the look goes onto every other photo, each keeping its crop', () async {
    final c = app();
    final composer = c.read(composerProvider.notifier);
    composer
      ..addPicked(photo(40, 30))
      ..addPicked(photo(30, 40));
    const cropped = ImageEdit(crop: Crop(bottom: 0.5));
    composer.applyEdit(
      1,
      cropped,
      applyImageEdit(c.read(composerProvider).media[1].bytes, cropped),
    );

    const look = Adjustments(exposure: 0.5);
    final first = c.read(composerProvider).media[0];
    composer.applyEdit(
      0,
      const ImageEdit(adjust: look),
      applyImageEdit(first.bytes, const ImageEdit(adjust: look)),
    );
    await composer.applyLookToAll(0);

    final second = c.read(composerProvider).media[1];
    expect(second.edit.adjust, look);
    expect(second.edit.crop, cropped.crop);
    final out = img.decodeImage(second.bytes)!;
    expect((out.width, out.height), (30, 20));
    expect(out.getPixel(5, 5).r, greaterThan(150));
  });
}
