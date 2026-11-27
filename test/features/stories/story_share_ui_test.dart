import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/media/private_media.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/models/media_event.dart';
import 'package:mialuna/core/nostr/models/story_link.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/feed/widgets/post_card.dart';
import 'package:mialuna/features/messages/send_to_sheet.dart';
import 'package:mialuna/features/messages/share_utils.dart';
import 'package:mialuna/features/private/private_delivery.dart';
import 'package:mialuna/features/stories/stories_controller.dart';
import 'package:mialuna/features/stories/story_receipts.dart';
import 'package:mialuna/features/stories/story_viewer.dart';
import 'package:mialuna/l10n/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

class _Media extends PrivateMediaService {
  final Uint8List picture;
  _Media(this.picture) : super(http.Client());

  @override
  Future<Uint8List> imageBytes(MediaItem item, {bool preview = false}) =>
      Future.value(picture);
}

/// Sends no view receipts: not what is looked at here.
class _Reporter extends StoryViewReporter {
  _Reporter(Ref ref)
    : super(
        owner: null,
        container: ref.container,
        cache: ref.read(localCacheProvider),
        prefs: ref.read(sharedPreferencesLoader),
        delivery: ref.read(privateDeliveryProvider),
        consent: ref.read(storyViewReceiptsProvider.notifier),
        now: () => 0,
      );

  @override
  Future<void> viewed(MediaPost story) async {}

  @override
  Future<void> flush({String? author}) async {}
}

Uint8List _png() =>
    Uint8List.fromList(img.encodePng(img.Image(width: 9, height: 16)));

final _viewer = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
final _author = 'a1' * 32;
final _linkedId = 'c' * 64;

MediaPost _event(
  String id, {
  required int kind,
  List<List<String>> tags = const [],
  bool private = false,
}) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return MediaPost.tryParse(
    NostrEvent(
      id: id,
      pubkey: _author,
      createdAt: now - 60,
      kind: kind,
      tags: [
        [
          'imeta',
          'url https://cdn.example.com/$id.png',
          'm image/png',
          'dim 1080x1920',
          // The viewer's picture comes from [_Media], with no network.
          'decryption-key ${'a' * 64}',
          'decryption-nonce ${'b' * 24}',
        ],
        if (private) [MediaPost.audienceTag, MediaPost.closeFriendsAudience],
        ...tags,
      ],
      content: '',
      sig: '',
    ),
    allowPrivate: private,
  )!;
}

MediaPost _storyOfAPost() => _event(
  'd' * 64,
  kind: NostrKinds.story,
  private: true,
  tags: [
    ...StoryPostLink(
      eventId: _linkedId,
      author: _author,
      area: const StoryArea(left: 0.12, top: 0.2, width: 0.76, height: 0.6),
    ).toTags(),
    ['L', 'mialuna.story'],
  ],
);

void main() {
  late Directory tmp;
  final asked = <String>[];

  setUp(() {
    asked.clear();
    SharedPreferences.setMockInitialValues({});
    tmp = Directory.systemTemp.createTempSync('mialuna_share_');
  });

  Future<void> pump(
    WidgetTester tester,
    Widget home, {
    MediaPost? found,
    Signer? as,
  }) async {
    tester.view.physicalSize = const Size(450, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          indexerRelaysProvider.overrideWithValue(const []),
          relayPoolProvider.overrideWithValue(RelayPool(const [])),
          localCacheProvider.overrideWithValue(LocalCache(directory: tmp)),
          authProvider.overrideWith(() => _FixedAuth(as ?? _viewer)),
          privateMediaProvider.overrideWithValue(_Media(_png())),
          storyViewReporterProvider.overrideWith(_Reporter.new),
          sharedPostProvider.overrideWith((ref, reference) async {
            asked.add(reference);
            return found;
          }),
        ],
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: home,
        ),
      ),
    );
    // Made now rather than when the viewer closes: it reads a preference,
    // which must not be left for after the test.
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
        .read(storyViewReporterProvider);
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 40));
  }

  Widget viewer(MediaPost story) => StoryViewerScreen(
    groups: [
      StoryGroup(author: _author, stories: [story]),
    ],
  );

  testWidgets('tapping the preview of a post opens the post', (tester) async {
    final linked = _event(_linkedId, kind: NostrKinds.picture);
    await pump(tester, viewer(_storyOfAPost()), found: linked);
    expect(find.text('View post'), findsOneWidget);

    // The middle of the card.
    await tester.tapAt(const Offset(225, 360));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(asked.single, startsWith('nostr:nevent1'));
    expect(find.byType(PostScreen), findsOneWidget);
    await close(tester);
  });

  testWidgets('so does the "View post" button', (tester) async {
    final linked = _event(_linkedId, kind: NostrKinds.picture);
    await pump(tester, viewer(_storyOfAPost()), found: linked);

    await tester.tap(find.text('View post'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(PostScreen), findsOneWidget);
    await close(tester);
  });

  testWidgets('a post that cannot be found is said so', (tester) async {
    await pump(tester, viewer(_storyOfAPost()));

    await tester.tap(find.text('View post'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(PostScreen), findsNothing);
    expect(find.textContaining('Content not available'), findsOneWidget);
    await close(tester);
  });

  testWidgets('outside the preview a tap still moves through the stories', (
    tester,
  ) async {
    await pump(tester, viewer(_storyOfAPost()));

    // Below the card, and the left edge across it.
    await tester.tapAt(const Offset(40, 360));
    await tester.pump(const Duration(milliseconds: 300));

    expect(asked, isEmpty);
    await close(tester);
  });

  Widget sheet(MediaPost post) => Scaffold(body: SendToSheet(post: post));

  testWidgets('a public post can be added to your story', (tester) async {
    await pump(tester, sheet(_event('1' * 64, kind: NostrKinds.picture)));
    expect(find.text('Add to your story'), findsOneWidget);
    await close(tester);
  });

  testWidgets('a story, a private post and a guest get no such button', (
    tester,
  ) async {
    await pump(tester, sheet(_storyOfAPost()));
    expect(find.text('Add to your story'), findsNothing);
    await close(tester);

    await pump(
      tester,
      sheet(_event('2' * 64, kind: NostrKinds.picture, private: true)),
    );
    expect(find.text('Add to your story'), findsNothing);
    await close(tester);

    await pump(
      tester,
      sheet(_event('3' * 64, kind: NostrKinds.picture)),
      as: GuestSigner(),
    );
    expect(find.text('Add to your story'), findsNothing);
    await close(tester);
  });
}
