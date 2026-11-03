import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart' show addTearDown;
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/models/media_event.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/messages/dm_controller.dart';
import 'package:mialuna/features/stories/stories_controller.dart';
import 'package:mialuna/features/stories/story_views.dart';

import 'fake_relay.dart';

NsecSigner newSigner() => NsecSigner.fromNsec(NsecSigner.generatePrivateKey());

/// A clock the test moves by hand (seconds since the epoch).
class TestClock {
  int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  int call() => now;
  void advance(int seconds) => now += seconds;
}

/// A real key that can be told to misbehave: refuse to encrypt or to sign the
/// seal, or wait (like a person looking at an Amber dialog) before answering.
class ScriptedSigner extends Signer {
  final NsecSigner inner;
  final SignerType kind;

  bool refuseEncrypt = false;
  bool refuseSeal = false;

  /// While set, [nip44Encrypt] waits for it: a signer request on screen.
  Completer<void>? gate;

  int encryptCalls = 0;
  int decryptCalls = 0;
  int _active = 0;
  int maxConcurrent = 0;

  ScriptedSigner(this.inner, {this.kind = SignerType.nsec});

  @override
  SignerType get type => kind;
  @override
  String? get publicKey => inner.publicKey;
  @override
  bool get canSign => true;
  @override
  bool get canEncrypt => true;

  @override
  Future<String> nip44Encrypt(String peerPubkey, String plaintext) async {
    encryptCalls++;
    _active++;
    if (_active > maxConcurrent) maxConcurrent = _active;
    try {
      final g = gate;
      if (g != null) await g.future;
      if (refuseEncrypt) throw const SignerException('refused');
      return await inner.nip44Encrypt(peerPubkey, plaintext);
    } finally {
      _active--;
    }
  }

  @override
  Future<String> nip44Decrypt(String peerPubkey, String ciphertext) {
    decryptCalls++;
    return inner.nip44Decrypt(peerPubkey, ciphertext);
  }

  @override
  Future<NostrEvent> signEvent({
    required int kind,
    required List<List<String>> tags,
    required String content,
    int? createdAt,
  }) {
    if (refuseSeal && kind == NostrKinds.seal) {
      throw const SignerException('refused to sign');
    }
    return inner.signEvent(
      kind: kind,
      tags: tags,
      content: content,
      createdAt: createdAt,
    );
  }
}

/// The signed-in account, which the test can change.
class SwitchableAuth extends AuthController {
  Signer signer;
  SwitchableAuth(this.signer);

  @override
  AuthState build() => AuthState(signer);

  void switchTo(Signer next) {
    signer = next;
    state = AuthState(next);
  }
}

/// Containers wired to one [FakeRelay], the way the app is wired to its pool.
class StoryHarness {
  final FakeRelay relay;
  final TestClock clock = TestClock();

  /// Extra relays every container also talks to.
  final List<FakeRelay> more;

  StoryHarness(this.relay, {this.more = const []});

  ProviderContainer app(
    Signer signer, {
    Directory? dir,
    SwitchableAuth? auth,
    List<Override> overrides = const [],
  }) {
    final cache = dir ?? Directory.systemTemp.createTempSync('mialuna_story_');
    final c = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => auth ?? SwitchableAuth(signer)),
        indexerRelaysProvider.overrideWithValue(const []),
        localCacheProvider.overrideWithValue(LocalCache(directory: cache)),
        unixClockProvider.overrideWithValue(clock.call),
        relayPoolProvider.overrideWith((ref) {
          final pool = RelayPool([
            RelayConfig(relay.url),
            for (final r in more) RelayConfig(r.url),
          ]);
          ref.listen<AuthState>(authProvider, (_, a) {
            final s = a.signer;
            pool.authSigner = s.canSign
                ? (url, challenge) => s.signEvent(
                    kind: NostrKinds.clientAuth,
                    tags: [
                      ['relay', url],
                      ['challenge', challenge],
                    ],
                    content: '',
                  )
                : null;
          }, fireImmediately: true);
          ref.onDispose(pool.dispose);
          return pool;
        }),
        ...overrides,
      ],
    );
    addTearDown(() {
      try {
        c.dispose();
      } catch (_) {
        // A test that restarts the app has already closed it.
      }
    });
    return c;
  }

  /// A signed-in account whose inbox is ready.
  Future<ProviderContainer> online(
    Signer signer, {
    Directory? dir,
    SwitchableAuth? auth,
    List<Override> overrides = const [],
  }) async {
    final c = app(signer, dir: dir, auth: auth, overrides: overrides);
    c.listen(dmProvider, (_, _) {});
    c.listen(storyViewsProvider, (_, _) {});
    await eventually(() => c.read(dmProvider).inboxConfigured == true);
    return c;
  }

  /// Tells the relays where [signer] receives private messages.
  Future<void> registerInbox(Signer signer) async {
    final event = await signed(
      signer,
      kind: NostrKinds.dmRelayList,
      tags: [
        for (final r in [relay, ...more]) ['relay', r.url],
      ],
    );
    for (final r in [relay, ...more]) {
      r.add(event);
    }
  }

  int get wraps =>
      relay.stored.where((e) => e.kind == NostrKinds.giftWrap).length;

  /// A story by [author]. It is [live] for the next [lifetime] seconds.
  Future<MediaPost> story(
    Signer author,
    String text, {
    int? createdAt,
    int lifetime = 86400,
    List<List<String>>? tags,
  }) async {
    final at = createdAt ?? clock.now;
    final event = await signed(
      author,
      kind: NostrKinds.picture,
      content: text,
      createdAt: at,
      tags:
          tags ??
          [
            [
              'imeta',
              'url https://cdn.example.com/${text.hashCode.abs()}.jpg',
              'm image/jpeg',
            ],
            ['L', 'mialuna.story'],
            ['l', 'story', 'mialuna.story'],
            ['expiration', '${at + lifetime}'],
          ],
    );
    return MediaPost.tryParse(event)!;
  }

  /// A story its author has just published, as the composer does: it is in
  /// the author's rail at once, so the author's phone knows it is theirs.
  Future<MediaPost> publish(
    ProviderContainer authorApp,
    Signer author,
    String text,
  ) async {
    final post = await story(author, text);
    authorApp.read(storiesProvider.notifier).addPublished(post.event);
    return post;
  }
}
