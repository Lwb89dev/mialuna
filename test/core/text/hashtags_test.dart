import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/branding/mialuna_tag.dart';
import 'package:mialuna/core/nostr/models/media_event.dart';
import 'package:mialuna/core/text/hashtags.dart';

void main() {
  group('Hashtags', () {
    test('keeps accented letters (the old \\w cut #città at "citt")', () {
      expect(Hashtags.extract('Una gita in #città per #perché'), [
        'città',
        'perché',
      ]);
    });

    test('works for any script, digits and underscores', () {
      expect(Hashtags.extract('#東京 #москва #sea_2024 #ÉTÉ'), [
        '東京',
        'москва',
        'sea_2024',
        'été',
      ]);
    });

    test('is lower-cased and has no repeats', () {
      expect(Hashtags.extract('#Mare #mare #MARE #sole'), ['mare', 'sole']);
    });

    test('a # glued to a word is not a hashtag', () {
      expect(Hashtags.extract('a#b foo#bar'), isEmpty);
      expect(Hashtags.extract('mare, #sole!'), ['sole']);
    });

    test('a lone # or punctuation after it is not a hashtag', () {
      expect(Hashtags.extract('# ciao #! #'), isEmpty);
    });

    test('strip removes the tags and nothing else', () {
      expect(Hashtags.strip('ciao #mare blu'), 'ciao  blu');
    });

    test('isBareWord', () {
      expect(Hashtags.isBareWord('città'), true);
      expect(Hashtags.isBareWord('due parole'), false);
      expect(Hashtags.isBareWord(''), false);
    });
  });

  group('hashtags in published events', () {
    test('buildTags writes the full accented tag', () {
      final tags = MediaPost.buildTags(
        media: const [MediaItem(url: 'https://x.example/a.jpg')],
        caption: 'Domenica in #città con #perché',
      );
      final t = [
        for (final tag in tags)
          if (tag[0] == 't') tag[1],
      ];
      expect(t, ['città', 'perché']);
    });

    test('deriveTitle drops accented hashtags entirely', () {
      expect(MediaPost.deriveTitle('Gita #città'), 'Gita');
      expect(MediaPost.deriveTitle('#città'), 'Mialuna');
    });

    test(
      '#mialuna is still recognised, but not as a prefix of another tag',
      () {
        expect(MialunaTag.hasHashtag('ciao #Mialuna'), true);
        expect(MialunaTag.hasHashtag('ciao #mialunaè'), false);
        expect(MialunaTag.hasHashtag('ciao #mialuna_x'), false);
        expect(
          MialunaTag.applyToCaption('ciao #mialunaè'),
          'ciao #mialunaè #mialuna',
        );
      },
    );
  });
}
