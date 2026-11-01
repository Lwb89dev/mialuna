import 'event.dart';

/// NIP-51 list helpers for Mialuna's local-first lists.
/// Bookmarks live in kind 10003 (`e` tags), muted authors in kind 10000
/// (`p` tags). Both are replaceable events holding the full list.
abstract final class Nip51 {
  static List<List<String>> bookmarkTags(Set<String> eventIds) => [
    for (final id in eventIds.toList()..sort()) ['e', id],
  ];

  static List<List<String>> muteTags(Set<String> pubkeys) => [
    for (final pk in pubkeys.toList()..sort()) ['p', pk],
  ];

  /// Bookmarked event ids from a kind 10003 event (empty for other kinds).
  static Set<String> bookmarkIds(NostrEvent event) {
    if (event.kind != NostrKinds.bookmarks) return const {};
    return {
      for (final tag in event.tags)
        if (tag.length >= 2 && tag[0] == 'e') tag[1],
    };
  }

  /// Muted pubkeys from a kind 10000 event (empty for other kinds).
  static Set<String> mutedPubkeys(NostrEvent event) {
    if (event.kind != NostrKinds.muteList) return const {};
    return {
      for (final tag in event.tags)
        if (tag.length >= 2 && tag[0] == 'p') tag[1],
    };
  }
}
