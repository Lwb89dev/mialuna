import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/models/media_event.dart';

const _at = 1700000000;

NostrEvent _event(String mime, {bool labelled = true}) => NostrEvent(
  id: '1' * 64,
  pubkey: 'a1' * 32,
  createdAt: _at,
  kind: NostrKinds.story,
  tags: [
    ['imeta', 'url https://cdn.example.com/x', 'm $mime'],
    if (labelled) ...[
      ['L', 'mialuna.story'],
      ['l', 'story', 'mialuna.story'],
    ],
  ],
  content: '',
  sig: '',
);

void main() {
  test('feeds and profiles never ask for stories', () {
    expect(NostrKinds.mediaKinds, isNot(contains(NostrKinds.story)));
    // The rail still reads those published by Mialuna 0.25 and earlier.
    expect(
      NostrKinds.storyKinds,
      containsAll([
        NostrKinds.story,
        NostrKinds.picture,
        NostrKinds.shortVideo,
      ]),
    );
  });

  test('photo and video stories share a kind: the file tells them apart', () {
    final photo = MediaPost.tryParse(_event('image/jpeg'))!;
    final video = MediaPost.tryParse(_event('video/mp4'))!;

    expect(photo.isStory, true);
    expect(photo.isVideo, false);
    expect(video.isStory, true);
    expect(video.isVideo, true);
    expect(video.media.single.isVideo, true);
    expect(video.isReel, false);
  });

  test('the kind alone makes it a story, gone after 24 hours', () {
    final story = MediaPost.tryParse(_event('image/jpeg', labelled: false))!;

    expect(story.isStory, true);
    expect(story.isExpired(_at + 86399), false);
    expect(story.isExpired(_at + 86400), true);
  });
}
