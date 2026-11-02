import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/models/media_event.dart';
import 'package:mialuna/features/stories/stories_controller.dart';

int _next = 0;

/// A story by [author] published [age] seconds ago.
MediaPost story(String author, {bool private = false, int age = 600}) {
  final id = '${_next++}'.padLeft(64, '0');
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return MediaPost.tryParse(
    NostrEvent(
      id: id,
      pubkey: author,
      createdAt: now - age,
      kind: NostrKinds.picture,
      tags: [
        ['imeta', 'url https://cdn.example.com/$id.jpg', 'm image/jpeg'],
        ['L', 'mialuna.story'],
        ['l', 'story', 'mialuna.story'],
        if (private) [MediaPost.audienceTag, MediaPost.closeFriendsAudience],
        ['expiration', '${now + 86400}'],
      ],
      content: '',
      sig: '',
    ),
    allowPrivate: true,
  )!;
}

/// [count] stories by [author], oldest first.
StoryGroup storiesOf(String author, int count, {bool private = false}) =>
    StoryGroup(
      author: author,
      stories: [
        for (var i = 0; i < count; i++)
          story(author, private: private, age: 3000 - i * 100),
      ],
    );
