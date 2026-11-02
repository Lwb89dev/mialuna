import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/text/clip.dart';

void main() {
  test('a normal text is shown as it is', () {
    expect(clipForDisplay('ciao #mare'), 'ciao #mare');
    expect(clipForDisplay('x' * maxDisplayedChars), 'x' * maxDisplayedChars);
  });

  test('a huge text is cut, with an ellipsis', () {
    final clipped = clipForDisplay('a' * 1000000);
    expect(clipped.length, maxDisplayedChars + 1);
    expect(clipped.endsWith('…'), true);
  });

  test('an emoji is not cut in two', () {
    // 🌕 is two UTF-16 units; the cut would fall between them.
    final text = '${'a' * 9}🌕🌕🌕';
    final clipped = clipForDisplay(text, max: 10);
    expect(clipped, '${'a' * 9}…');
    for (final unit in clipped.codeUnits) {
      expect(unit >= 0xD800 && unit <= 0xDFFF, false, reason: 'no half emoji');
    }
  });
}
