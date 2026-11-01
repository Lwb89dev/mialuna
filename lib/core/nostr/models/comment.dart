import '../event.dart';

/// A NIP-22 comment (kind 1111) on a media post.
class Comment {
  final NostrEvent event;
  final String? parentId; // direct parent (comment) or null when root-level
  final String rootId;

  const Comment({required this.event, required this.rootId, this.parentId});

  String get id => event.id;
  String get author => event.pubkey;
  String get text => event.content;
  int get createdAt => event.createdAt;

  /// Parses a kind 1111 event. Returns null if it lacks a valid root
  /// reference for the given post.
  static Comment? tryParse(NostrEvent event, {required String forRootId}) {
    if (event.kind != NostrKinds.comment) return null;
    String? rootId;
    String? parentId;
    for (final tag in event.tags) {
      if (tag.length < 2) continue;
      if (tag[0] == 'E') rootId = tag[1]; // root scope (uppercase)
      if (tag[0] == 'e') parentId ??= tag[1]; // parent (lowercase)
    }
    // Some clients use lowercase 'e' for kind-1-style roots; accept the
    // first e-tag as root when no 'E' exists.
    rootId ??= parentId;
    if (rootId == null || rootId != forRootId) return null;
    return Comment(
      event: event,
      rootId: rootId,
      parentId: parentId == rootId ? null : parentId,
    );
  }

  /// Builds the tag set for a comment on a media post (or a reply).
  static List<List<String>> buildTags({
    required NostrEvent rootEvent,
    NostrEvent? parentComment,
    String relayHint = '',
  }) {
    if (parentComment == null) {
      return [
        // Root scope (uppercase) per NIP-22 for non-kind-1 roots.
        ['E', rootEvent.id, relayHint, rootEvent.pubkey],
        ['K', rootEvent.kind.toString()],
        ['P', rootEvent.pubkey],
        // Parent scope = root for top-level comments.
        ['e', rootEvent.id, relayHint, rootEvent.pubkey],
        ['k', rootEvent.kind.toString()],
        ['p', rootEvent.pubkey],
      ];
    }
    return [
      ['E', rootEvent.id, relayHint, rootEvent.pubkey],
      ['K', rootEvent.kind.toString()],
      ['P', rootEvent.pubkey],
      ['e', parentComment.id, relayHint, parentComment.pubkey],
      ['k', NostrKinds.comment.toString()],
      ['p', parentComment.pubkey],
    ];
  }
}

/// Tags for a NIP-25 reaction (like) on a media event.
List<List<String>> buildReactionTags(NostrEvent target) => [
  ['e', target.id],
  ['p', target.pubkey],
  ['k', target.kind.toString()],
];
