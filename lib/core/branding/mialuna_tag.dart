import '../text/hashtags.dart';

/// Central branding policy for the official hashtag. Every media post
/// published through Mialuna carries #mialuna; this is the single place
/// where that rule lives.
abstract final class MialunaTag {
  static const hashtag = 'mialuna';

  /// Appends ` #mialuna` to a caption unless already present
  /// (case-insensitive, whole-word). The user's caption is never altered
  /// beyond the append.
  static String applyToCaption(String caption) {
    if (hasHashtag(caption)) return caption;
    final trimmed = caption.trimRight();
    return trimmed.isEmpty ? '#$hashtag' : '$trimmed #$hashtag';
  }

  static bool hasHashtag(String caption) =>
      Hashtags.extract(caption).contains(hashtag);

  /// Ensures the `["t", "mialuna"]` tag exists exactly once.
  static List<List<String>> applyToTags(List<List<String>> tags) {
    final hasT = tags.any(
      (t) => t.length >= 2 && t[0] == 't' && t[1].toLowerCase() == hashtag,
    );
    if (hasT) return tags;
    return [
      ...tags,
      ['t', hashtag],
    ];
  }
}
