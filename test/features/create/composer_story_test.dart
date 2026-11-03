import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/create/create_controller.dart';
import 'package:mialuna/features/private/close_friends.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ends the way a successful publish does: a fresh state, "published".
class _Published extends ComposerController {
  void finishPublishing() {
    state = ComposerState(published: true, audience: state.audience);
  }
}

/// A new story starts from nothing, and what is written for one never ends
/// up in a post (or the other way round).
void main() {
  late Directory dir;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dir = Directory.systemTemp.createTempSync('mialuna_composer_');
  });

  ProviderContainer app({Directory? at}) {
    final c = ProviderContainer(
      overrides: [
        localCacheProvider.overrideWithValue(LocalCache(directory: at ?? dir)),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<String?> savedDraft(LocalCache cache) async {
    final drafts = await cache.loadDrafts();
    final draft = drafts['composer_draft'];
    return draft is Map ? draft['caption'] as String? : null;
  }

  test('an abandoned story leaves nothing in the next one', () {
    final c = app();
    final composer = c.read(composerProvider.notifier);
    composer.startStory();
    composer.setCaption('per pochi intimi');
    composer.setSensitive(true);
    expect(c.read(composerProvider).caption, 'per pochi intimi');

    // Thrown away, or started again from the rail.
    composer.startStory();
    final fresh = c.read(composerProvider);
    expect(fresh.mode, ComposerMode.story);
    expect(fresh.caption, isEmpty);
    expect(fresh.sensitive, false);
    expect(fresh.media, isEmpty);
    expect(fresh.overlays, isEmpty);
    expect(fresh.error, isNull);
  });

  test('the audience is a standing choice and stays', () {
    final c = app();
    final composer = c.read(composerProvider.notifier);
    composer.setAudience(Audience.closeFriends);
    composer.startStory();
    expect(c.read(composerProvider).audience, Audience.closeFriends);
  });

  test('a story started right after publishing is clean', () {
    final c = ProviderContainer(
      overrides: [
        localCacheProvider.overrideWithValue(LocalCache(directory: dir)),
        composerProvider.overrideWith(_Published.new),
      ],
    );
    addTearDown(c.dispose);
    final composer = c.read(composerProvider.notifier) as _Published;
    composer.startStory();
    composer.setCaption('prima storia');
    composer.setSensitive(true);

    composer.finishPublishing();
    composer.startStory();
    final next = c.read(composerProvider);
    expect(next.caption, isEmpty);
    expect(next.sensitive, false);
    expect(next.published, false);
  });

  test('switching modes clears the picture, not what was typed', () {
    final c = app();
    final composer = c.read(composerProvider.notifier);
    composer.setCaption('bozza');
    composer.setMode(ComposerMode.video);
    composer.setMode(ComposerMode.story);
    expect(c.read(composerProvider).media, isEmpty);
    expect(c.read(composerProvider).caption, 'bozza');
    // ...but a *new* story is a new start.
    composer.startStory();
    expect(c.read(composerProvider).caption, isEmpty);
  });

  group('drafts', () {
    test('the post composer still keeps and restores its draft', () async {
      final first = app();
      first.read(composerProvider.notifier).setCaption('bozza del post');
      final cache = LocalCache(directory: dir);
      await eventually(() async => await savedDraft(cache) == 'bozza del post');

      final again = app();
      again.read(composerProvider);
      await eventually(
        () async => again.read(composerProvider).caption == 'bozza del post',
      );
    });

    test('a story caption is not saved over the post draft', () async {
      final c = app();
      final composer = c.read(composerProvider.notifier);
      composer.setCaption('bozza del post');
      final cache = LocalCache(directory: dir);
      await eventually(() async => await savedDraft(cache) == 'bozza del post');

      composer.startStory();
      composer.setCaption('segreto della storia');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(await savedDraft(cache), 'bozza del post');
    });

    test('a story caption never turns up in the next post', () async {
      final first = app();
      final composer = first.read(composerProvider.notifier);
      composer.startStory();
      composer.setCaption('solo per gli amici');
      await Future<void>.delayed(const Duration(milliseconds: 200));

      final again = app();
      again.read(composerProvider);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(again.read(composerProvider).caption, isEmpty);
    });

    test('a draft read late does not fill a story already begun', () async {
      final seed = app();
      seed.read(composerProvider.notifier).setCaption('vecchia bozza');
      await eventually(
        () async => await savedDraft(LocalCache(directory: dir)) != null,
      );

      final c = app();
      c
          .read(composerProvider.notifier)
          .startStory(); // before the draft is read
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(c.read(composerProvider).caption, isEmpty);
    });
  });
}

Future<void> eventually(
  Future<bool> Function() condition, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final end = DateTime.now().add(timeout);
  while (!await condition()) {
    if (DateTime.now().isAfter(end)) throw StateError('condition not met');
    await Future<void>.delayed(const Duration(milliseconds: 25));
  }
}
