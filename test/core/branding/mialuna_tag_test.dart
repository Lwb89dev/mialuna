import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/branding/mialuna_tag.dart';

void main() {
  group('MialunaTag', () {
    test('appends #mialuna to a plain caption', () {
      expect(
        MialunaTag.applyToCaption('Tramonto sul mare'),
        'Tramonto sul mare #mialuna',
      );
    });

    test('handles empty caption', () {
      expect(MialunaTag.applyToCaption(''), '#mialuna');
      expect(MialunaTag.applyToCaption('   '), '#mialuna');
    });

    test('never duplicates an existing hashtag', () {
      expect(MialunaTag.applyToCaption('Ciao #mialuna'), 'Ciao #mialuna');
      expect(MialunaTag.applyToCaption('#Mialuna vibes'), '#Mialuna vibes');
      expect(MialunaTag.applyToCaption('#MIALUNA'), '#MIALUNA');
    });

    test('does not match similar words', () {
      expect(MialunaTag.hasHashtag('#mialunaaa'), false);
      expect(
        MialunaTag.applyToCaption('#mialunaaa festa'),
        '#mialunaaa festa #mialuna',
      );
    });

    test('preserves user caption and trailing whitespace handling', () {
      expect(MialunaTag.applyToCaption('Foto  '), 'Foto #mialuna');
    });

    test('applyToTags adds t tag exactly once', () {
      final tags = MialunaTag.applyToTags([
        ['t', 'mare'],
      ]);
      expect(tags.where((t) => t[0] == 't' && t[1] == 'mialuna').length, 1);

      final already = MialunaTag.applyToTags([
        ['t', 'Mialuna'],
      ]);
      expect(already.where((t) => t[0] == 't').length, 1);
    });
  });
}
