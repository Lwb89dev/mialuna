import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/models/comment.dart';
import 'package:mialuna/core/nostr/signer.dart';

void main() {
  final rootEvent = NostrEvent(
    id: 'rootid',
    pubkey: 'author1',
    createdAt: 1700000000,
    kind: NostrKinds.picture,
    tags: const [],
    content: 'foto',
    sig: '',
  );

  group('NIP-22 comments', () {
    test('top-level comment has uppercase root + lowercase parent scopes', () {
      final tags = Comment.buildTags(rootEvent: rootEvent);
      expect(tags.any((t) => t[0] == 'E' && t[1] == 'rootid'), true);
      expect(tags.any((t) => t[0] == 'K' && t[1] == '20'), true);
      expect(tags.any((t) => t[0] == 'P' && t[1] == 'author1'), true);
      expect(tags.any((t) => t[0] == 'e' && t[1] == 'rootid'), true);
      expect(tags.any((t) => t[0] == 'k' && t[1] == '20'), true);
    });

    test('reply points to the parent comment, not the root', () {
      final parent = NostrEvent(
        id: 'comment1',
        pubkey: 'other',
        createdAt: 1700000001,
        kind: NostrKinds.comment,
        tags: const [],
        content: 'bello',
        sig: '',
      );
      final tags = Comment.buildTags(
        rootEvent: rootEvent,
        parentComment: parent,
      );
      expect(tags.any((t) => t[0] == 'E' && t[1] == 'rootid'), true);
      expect(tags.any((t) => t[0] == 'e' && t[1] == 'comment1'), true);
      expect(tags.any((t) => t[0] == 'k' && t[1] == '1111'), true);
    });

    test('tryParse accepts comments for the right root only', () async {
      final signer = NsecSigner.fromNsec(
        '67dea2ed018072d675f5415ecfaed7d2597555e202d85b3d65ea4e58d2d92ffa',
      );
      final event = await signer.signEvent(
        kind: NostrKinds.comment,
        tags: Comment.buildTags(rootEvent: rootEvent),
        content: 'che bello!',
      );
      final c = Comment.tryParse(event, forRootId: 'rootid');
      expect(c, isNotNull);
      expect(c!.text, 'che bello!');
      expect(Comment.tryParse(event, forRootId: 'other-root'), isNull);
    });
  });

  group('NIP-25 reactions', () {
    test('reaction tags reference event, author and kind', () {
      final tags = buildReactionTags(rootEvent);
      expect(tags, [
        ['e', 'rootid'],
        ['p', 'author1'],
        ['k', '20'],
      ]);
    });
  });
}
