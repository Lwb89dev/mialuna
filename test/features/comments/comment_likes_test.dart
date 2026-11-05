import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/models/comment.dart';
import 'package:mialuna/core/nostr/models/media_event.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/comments/comment_likes_controller.dart';
import 'package:mialuna/features/comments/comments_sheet.dart';
import 'package:mialuna/features/social/interactions_controller.dart';
import 'package:mialuna/l10n/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_relay.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);

  @override
  AuthState build() => AuthState(signer);
}

class _FakeInteractions extends InteractionsController {
  final PostInteractions fixed;
  _FakeInteractions(this.fixed);

  @override
  PostInteractions build(MediaPost arg) => fixed;
}

class _FakeCommentLikes extends CommentLikesController {
  @override
  CommentLikes build(CommentLikeTarget arg) => const CommentLikes(count: 2);

  @override
  Future<bool> like() async {
    state = const CommentLikes(count: 3, likedByMe: true);
    return true;
  }
}

void main() {
  late FakeRelay relay;
  late NsecSigner me;
  late NsecSigner bob;
  late NsecSigner carol;
  late Directory dir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    relay = await FakeRelay().start();
    me = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
    bob = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
    carol = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
    dir = Directory.systemTemp.createTempSync('mialuna_comment_likes_');
  });

  tearDown(() => relay.stop());

  test('comment likes are counted and can be toggled', () async {
    final rootEvent = await signed(
      me,
      tags: [
        ['imeta', 'url https://cdn.example.com/moment.jpg', 'm image/jpeg'],
      ],
    );
    final post = MediaPost.tryParse(rootEvent)!;
    final commentEvent = await signed(
      bob,
      kind: NostrKinds.comment,
      tags: Comment.buildTags(rootEvent: rootEvent),
      content: 'bella!',
    );
    final comment = Comment.tryParse(commentEvent, forRootId: post.id)!;
    for (final signer in [bob, carol]) {
      relay.add(
        await signed(
          signer,
          kind: NostrKinds.reaction,
          tags: buildReactionTags(commentEvent),
          content: '+',
        ),
      );
    }
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => _FixedAuth(me)),
        indexerRelaysProvider.overrideWithValue(const []),
        localCacheProvider.overrideWithValue(LocalCache(directory: dir)),
        relayPoolProvider.overrideWith((ref) {
          final pool = RelayPool([RelayConfig(relay.url)]);
          ref.onDispose(pool.dispose);
          return pool;
        }),
      ],
    );
    addTearDown(container.dispose);
    final target = (post: post, comment: comment);
    container.listen(commentLikesProvider(target), (_, _) {});
    await eventually(
      () => container.read(commentLikesProvider(target)).count == 2,
      reason: 'comment likes never arrived',
    );
    expect(container.read(commentLikesProvider(target)).likedByMe, isFalse);

    expect(
      await container.read(commentLikesProvider(target).notifier).like(),
      isTrue,
    );
    await eventually(
      () => container.read(commentLikesProvider(target)).count == 3,
      reason: 'the local like was not reflected in the count',
    );
    expect(container.read(commentLikesProvider(target)).likedByMe, isTrue);
    final reaction = relay.stored.last;
    expect(reaction.kind, NostrKinds.reaction);
    expect(reaction.firstTagValue('e'), comment.id);
    expect(reaction.firstTagValue('k'), '${NostrKinds.comment}');

    expect(
      await container.read(commentLikesProvider(target).notifier).like(),
      isTrue,
    );
    await eventually(
      () => container.read(commentLikesProvider(target)).count == 2,
      reason: 'the local unlike was not reflected in the count',
    );
    expect(container.read(commentLikesProvider(target)).likedByMe, isFalse);
    container.read(interactionsRepositoryProvider).ingest(reaction);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(commentLikesProvider(target)).count, 2);
    expect(container.read(commentLikesProvider(target)).likedByMe, isFalse);
    final deletion = relay.stored.last;
    expect(deletion.kind, NostrKinds.deletion);
    expect(deletion.firstTagValue('e'), reaction.id);
  });

  testWidgets('the comment row shows the counter and the active heart', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 1136);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final rootEvent = NostrEvent(
      id: 'a' * 64,
      pubkey: me.publicKey,
      createdAt: 1700000000,
      kind: NostrKinds.picture,
      tags: const [
        ['imeta', 'url https://cdn.example.com/moment.jpg', 'm image/jpeg'],
      ],
      content: '',
      sig: '',
    );
    final post = MediaPost.tryParse(rootEvent)!;
    final commentEvent = NostrEvent(
      id: 'b' * 64,
      pubkey: bob.publicKey,
      createdAt: 1700000001,
      kind: NostrKinds.comment,
      tags: Comment.buildTags(rootEvent: rootEvent),
      content: 'bella!',
      sig: '',
    );
    final comment = Comment.tryParse(commentEvent, forRootId: post.id)!;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => _FixedAuth(me)),
          indexerRelaysProvider.overrideWithValue(const []),
          localCacheProvider.overrideWithValue(LocalCache(directory: dir)),
          relayPoolProvider.overrideWith((ref) {
            final pool = RelayPool(const []);
            ref.onDispose(pool.dispose);
            return pool;
          }),
          interactionsProvider.overrideWith(
            () => _FakeInteractions(PostInteractions(comments: [comment])),
          ),
          commentLikesProvider.overrideWith(_FakeCommentLikes.new),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: CommentsSheet(post: post)),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('2'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 40));
  });
}
