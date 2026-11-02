import 'event.dart';

/// NIP-51 list helpers for Mialuna's local-first lists.
/// Bookmarks live in kind 10003 (`e` tags), muted authors and hashtags in
/// kind 10000 (`p` and `t` tags). Both are replaceable events holding the
/// full list.
abstract final class Nip51 {
  static List<List<String>> bookmarkTags(Set<String> eventIds) => [
    for (final id in eventIds.toList()..sort()) ['e', id],
  ];

  static List<List<String>> muteTags(
    Set<String> pubkeys, {
    Set<String> hashtags = const {},
  }) => [
    for (final pk in pubkeys.toList()..sort()) ['p', pk],
    for (final tag in hashtags.toList()..sort()) ['t', tag],
  ];

  /// Tags a list must keep when Mialuna republishes it. The lists are shared
  /// with other clients, which add entries Mialuna does not understand
  /// (addressable bookmarks, muted words and threads…): publishing only our
  /// own tags would silently delete them. So [previous]'s tags whose name is
  /// not in [managedNames] are carried over, followed by [managed].
  static List<List<String>> keepingForeignTags(
    NostrEvent? previous,
    List<List<String>> managed, {
    required Set<String> managedNames,
  }) => [
    for (final t in previous?.tags ?? const <List<String>>[])
      if (t.isEmpty || !managedNames.contains(t[0])) t,
    ...managed,
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

  /// Muted hashtags from a kind 10000 event (empty for other kinds).
  static Set<String> mutedHashtags(NostrEvent event) {
    if (event.kind != NostrKinds.muteList) return const {};
    return {
      for (final tag in event.tags)
        if (tag.length >= 2 && tag[0] == 't') tag[1].toLowerCase(),
    };
  }
}
