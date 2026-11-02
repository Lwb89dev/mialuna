import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/nip19.dart';
import 'package:mialuna/core/nostr/profile_repository.dart';

void main() {
  final pubkey = 'ab' * 32;

  test('a person with no name is shown by their npub, not by raw hex', () {
    final label = ProfileMetadata(pubkey: pubkey).label;
    final npub = Nip19.encodeNpub(pubkey);
    expect(label, startsWith('npub1'));
    expect(
      label,
      '${npub.substring(0, 14)}…${npub.substring(npub.length - 6)}',
    );
    expect(ProfileMetadata(pubkey: pubkey).givenName, isNull);
  });

  test('the name they chose comes first: display name, then username', () {
    expect(
      ProfileMetadata(
        pubkey: pubkey,
        name: 'luna',
        displayName: 'Luna M.',
      ).label,
      'Luna M.',
    );
    expect(ProfileMetadata(pubkey: pubkey, name: 'luna').label, 'luna');
    expect(ProfileMetadata(pubkey: pubkey, name: '').givenName, isNull);
  });

  test('something that is not a key does not crash the label', () {
    expect(ProfileMetadata.shortNpub('zz'), 'zz');
    expect(ProfileMetadata.shortNpub('not-a-hex-key-at-all'), 'not-a-he…');
  });
}
