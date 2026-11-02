/// The one definition of a `#hashtag`, shared by the composer, the captions,
/// the texts laid over stories and the search box.
///
/// Dart's `\w` only knows ASCII, so `#città` or `#perché` used to be cut at the
/// first accented letter (`#citt`). Letters, marks and digits of any script,
/// plus `_`, are accepted here — the same rule Instagram applies.
abstract final class Hashtags {
  static const _word = r'[\p{L}\p{M}\p{N}_]';

  /// A hashtag that does not continue a word (`a#b` is not one). Group 1 is
  /// the tag without the `#`.
  static final RegExp pattern = RegExp('(?<!$_word)#($_word+)', unicode: true);

  /// True when [text] is made only of hashtag characters (`città`, not `a b`).
  static final RegExp _bareWord = RegExp('^$_word+\$', unicode: true);

  static bool isBareWord(String text) => _bareWord.hasMatch(text);

  static Iterable<RegExpMatch> matches(String text) => pattern.allMatches(text);

  /// The tags in [text], lower-cased and without repeats, in reading order.
  static List<String> extract(String text) {
    final seen = <String>{};
    for (final m in pattern.allMatches(text)) {
      seen.add(m.group(1)!.toLowerCase());
    }
    return seen.toList();
  }

  /// [text] without its hashtags.
  static String strip(String text) => text.replaceAll(pattern, '');
}
