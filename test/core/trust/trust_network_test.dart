import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/trust/trust_network.dart';

NostrEvent followList(
  List<String> tagValues, {
  List<List<String>> extra = const [],
}) => NostrEvent(
  id: 'a' * 64,
  pubkey: 'b' * 64,
  createdAt: 1,
  kind: NostrKinds.followList,
  tags: [
    for (final v in tagValues) ['p', v],
    ...extra,
  ],
  content: '',
  sig: 'c' * 128,
);

String key(int i) => i.toRadixString(16).padLeft(64, '0');

void main() {
  test('only valid keys in `p` tags are followed', () {
    final event = followList(
      [key(1), 'not-a-key', key(2).toUpperCase(), key(1)],
      extra: [
        ['e', key(9)],
        ['p'],
      ],
    );
    expect(followedBy(event), {key(1), key(2)});
  });

  test('an account qualifies from the tenth list that follows it', () {
    final counter = FollowCounter();
    for (var i = 0; i < 9; i++) {
      counter.add([key(100), key(200 + i)]);
    }
    expect(counter.reaching(), isEmpty, reason: '9 of 10');
    counter.add([key(100)]);
    expect(counter.reaching(), {key(100)});
  });

  test('a list that repeats an account counts it once', () {
    final counter = FollowCounter();
    counter.add(List.filled(30, key(7)));
    expect(counter.reaching(), isEmpty);
    expect(counter.reaching(1), {key(7)});
  });

  test('a filter that is off lets everybody through; on, only the trusted', () {
    expect(TrustFilter.open.allows('anyone'), true);
    const on = TrustFilter(true, {'friend'});
    expect(on.allows('friend'), true);
    expect(on.allows('stranger'), false);
  });
}
