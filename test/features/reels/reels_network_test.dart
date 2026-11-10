import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/reels/reels_controller.dart';
import 'package:mialuna/features/social/moderation_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_relay.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

/// Reels show you, the people you follow and your web of trust, newest
/// first. The rest of the relays' short videos stay out.
void main() {
  late FakeRelay relay;
  late NsecSigner me;
  late NsecSigner friend;
  late NsecSigner stranger;
  late Directory tmp;

  Future<NostrEvent> reel(
    NsecSigner who,
    String text, {
    required int at,
    List<List<String>> extra = const [],
  }) => signed(
    who,
    kind: 22,
    content: text,
    createdAt: at,
    tags: [
      [
        'imeta',
        'url https://cdn.example.com/${text.hashCode.abs()}.mp4',
        'm video/mp4',
        'dim 1080x1920',
      ],
      ...extra,
    ],
  );

  ProviderContainer app() {
    final c = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => _FixedAuth(me)),
        indexerRelaysProvider.overrideWithValue(const []),
        localCacheProvider.overrideWithValue(LocalCache(directory: tmp)),
        relayPoolProvider.overrideWith((ref) {
          final pool = RelayPool([RelayConfig(relay.url)]);
          ref.onDispose(pool.dispose);
          return pool;
        }),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  List<String> captions(ProviderContainer c) => [
    for (final r in c.read(reelsProvider).reels) r.caption,
  ];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    relay = await FakeRelay().start();
    me = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
    friend = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
    stranger = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
    tmp = Directory.systemTemp.createTempSync('mialuna_reels_');
    relay.add(
      await signed(
        me,
        kind: 3,
        tags: [
          ['p', friend.publicKey],
        ],
      ),
    );
    addTearDown(() => tmp.deleteSync(recursive: true));
    addTearDown(relay.stop);
  });

  test('only your network, newest first', () async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    relay.add(await reel(friend, 'friend old', at: now - 300));
    relay.add(await reel(stranger, 'stranger', at: now - 100));
    relay.add(await reel(me, 'mine', at: now - 200));
    relay.add(await reel(friend, 'friend new', at: now - 50));
    final c = app();
    c.listen(reelsProvider, (_, _) {});
    await eventually(
      () => captions(c).length >= 3,
      timeout: const Duration(seconds: 20),
    );
    await c.read(reelsProvider.notifier).refresh();
    expect(captions(c), ['friend new', 'mine', 'friend old']);
  });

  test('a reel dated in the future cannot pin itself on top', () async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    relay.add(await reel(friend, 'today', at: now - 60));
    relay.add(await reel(friend, 'next year', at: now + 365 * 86400));
    final c = app();
    c.listen(reelsProvider, (_, _) {});
    await eventually(
      () => captions(c).isNotEmpty,
      timeout: const Duration(seconds: 20),
    );
    await c.read(reelsProvider.notifier).refresh();
    expect(captions(c), ['today']);
  });

  test('muted hashtags apply to reels too', () async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    relay.add(await reel(friend, 'cats', at: now - 60));
    relay.add(
      await reel(
        friend,
        'nope',
        at: now - 30,
        extra: [
          ['t', 'nsfw'],
        ],
      ),
    );
    final c = app();
    c.listen(reelsProvider, (_, _) {});
    await eventually(
      () => captions(c).length == 2,
      timeout: const Duration(seconds: 20),
    );
    await c.read(muteControllerProvider.notifier).muteHashtag('nsfw');
    expect(captions(c), ['cats']);
  });
}
