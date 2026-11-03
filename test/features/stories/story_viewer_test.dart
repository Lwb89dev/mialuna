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
import 'package:mialuna/core/nostr/nip59.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/core/theme/mialuna_theme.dart';
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

/// Close-friends pictures come from here instead of a server: a url mapped
/// to bytes is a picture that loads, to null one that does not.
class _Media extends PrivateMediaService {
  final Map<String, Uint8List?> pictures;
  _Media(this.pictures) : super(http.Client());

  @override
  Future<Uint8List> imageBytes(MediaItem item, {bool preview = false}) {
    final bytes = pictures[item.url];
    return bytes == null
        ? Future.error(StateError('cannot be downloaded'))
        : Future.value(bytes);
  }
}

/// Writes down what the viewer tells it, sends nothing.
class _Reporter extends StoryViewReporter {
  final List<String> viewedIds = [];
  int flushes = 0;

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
  Future<void> viewed(MediaPost story) async => viewedIds.add(story.id);

  @override
  Future<void> flush({String? author}) async => flushes++;
}

/// A delivery that must never be used.
class _NoDelivery extends PrivateDelivery {
  int sends = 0;
  _NoDelivery(super.ref);

  @override
  Future<DeliveryReport> send(
    Rumor rumor,
    Iterable<String> recipients, {
    int? expiresAt,
    void Function(int done, int total)? onProgress,
    bool copyToSelf = true,
    bool Function()? shouldContinue,
  }) async {
    sends++;
    return const DeliveryReport();
  }
}

Uint8List _picture() {
  final image = img.Image(width: 8, height: 8);
  img.fill(image, color: img.ColorRgb8(200, 80, 40));
  return Uint8List.fromList(img.encodePng(image));
}

int _n = 0;

/// A close-friends story by [author] whose picture is at [url].
MediaPost _story(String author, String url) {
  final id = '${++_n}'.padLeft(64, '0');
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return MediaPost.tryParse(
    NostrEvent(
      id: id,
      pubkey: author,
      createdAt: now - 60,
      kind: NostrKinds.picture,
      tags: [
        [
          'imeta',
          'url $url',
          'm image/png',
          'decryption-key ${'a' * 64}',
          'decryption-nonce ${'b' * 24}',
        ],
        ['L', 'mialuna.story'],
        ['l', 'story', 'mialuna.story'],
        [MediaPost.audienceTag, MediaPost.closeFriendsAudience],
        ['expiration', '${now + 86400}'],
      ],
      content: '',
      sig: '',
    ),
    allowPrivate: true,
  )!;
}

final _viewer = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
final _author = 'a1' * 32;

void main() {
  late Directory tmp;
  late _Reporter reporter;
  late _NoDelivery delivery;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    tmp = Directory.systemTemp.createTempSync('mialuna_viewer_');
  });

  /// Opens the viewer on [stories] (one creator) and lets the pictures load.
  Future<void> open(
    WidgetTester tester,
    List<MediaPost> stories,
    Map<String, Uint8List?> pictures, {
    Signer? as,
    bool realReporter = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          indexerRelaysProvider.overrideWithValue(const []),
          relayPoolProvider.overrideWithValue(RelayPool(const [])),
          localCacheProvider.overrideWithValue(LocalCache(directory: tmp)),
          authProvider.overrideWith(() => _FixedAuth(as ?? _viewer)),
          privateMediaProvider.overrideWithValue(_Media(pictures)),
          privateDeliveryProvider.overrideWith((ref) {
            return delivery = _NoDelivery(ref);
          }),
          if (!realReporter)
            storyViewReporterProvider.overrideWith((ref) {
              return reporter = _Reporter(ref);
            }),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return MaterialApp(
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              theme: MialunaTheme.dark(),
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => StoryViewerScreen(
                            groups: [
                              StoryGroup(author: _author, stories: stories),
                            ],
                          ),
                        ),
                      ),
                      child: const Text('open'),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump(); // the route
    await tester.pump(const Duration(milliseconds: 400)); // and its first frame
    // Decoding a picture happens off the test clock.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();
    // Make the reporter now, so tests can look at it before it is first used.
    if (!realReporter) container.read(storyViewReporterProvider);
  }

  /// Lets [span] of story time go by, a tick at a time.
  Future<void> watch(WidgetTester tester, Duration span) async {
    for (
      var t = Duration.zero;
      t < span;
      t += const Duration(milliseconds: 50)
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 40));
  }

  Set<String> seen() => container.read(seenStoriesProvider);

  testWidgets('a picture that is on screen counts after a second', (
    tester,
  ) async {
    final story = _story(_author, 'https://x.example/ok');
    await open(tester, [story], {'https://x.example/ok': _picture()});

    await watch(tester, const Duration(milliseconds: 600));
    expect(reporter.viewedIds, isEmpty, reason: 'not watched yet');
    expect(seen(), isNot(contains(story.id)));

    await watch(tester, const Duration(milliseconds: 600));
    expect(reporter.viewedIds, [story.id]);
    expect(seen(), contains(story.id), reason: 'seen and reported together');

    await watch(tester, const Duration(seconds: 6));
    expect(reporter.viewedIds, [story.id], reason: 'counted once');
    expect(find.byType(StoryViewerScreen), findsNothing, reason: 'it ended');
    expect(reporter.flushes, greaterThan(0));
    await finish(tester);
  });

  testWidgets('a picture that cannot be shown is not a view', (tester) async {
    final broken = _story(_author, 'https://x.example/broken');
    final fine = _story(_author, 'https://x.example/fine');
    await open(
      tester,
      [broken, fine],
      {'https://x.example/broken': null, 'https://x.example/fine': _picture()},
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // The viewer has moved on without counting the first.
    await watch(tester, const Duration(seconds: 2));
    expect(reporter.viewedIds, isNot(contains(broken.id)));
    expect(seen(), isNot(contains(broken.id)));
    expect(reporter.viewedIds, contains(fine.id));
    await finish(tester);
  });

  testWidgets('a picture that is not decodable is not a view either', (
    tester,
  ) async {
    final story = _story(_author, 'https://x.example/garbage');
    await open(
      tester,
      [story],
      {
        'https://x.example/garbage': Uint8List.fromList([1, 2, 3, 4]),
      },
    );
    await watch(tester, const Duration(seconds: 3));
    expect(reporter.viewedIds, isEmpty);
    expect(seen(), isEmpty);
    await finish(tester);
  });

  testWidgets('holding the story stops the count', (tester) async {
    final story = _story(_author, 'https://x.example/hold');
    await open(tester, [story], {'https://x.example/hold': _picture()});

    final hold = await tester.startGesture(
      tester.getCenter(find.byType(StoryViewerScreen)),
    );
    await tester.pump(const Duration(milliseconds: 700)); // a long press
    await watch(tester, const Duration(seconds: 3));
    expect(reporter.viewedIds, isEmpty);

    await hold.up();
    await watch(tester, const Duration(milliseconds: 1200));
    expect(reporter.viewedIds, [story.id]);
    await finish(tester);
  });

  testWidgets('the app in the background is not watching', (tester) async {
    final story = _story(_author, 'https://x.example/bg');
    await open(tester, [story], {'https://x.example/bg': _picture()});
    await watch(tester, const Duration(milliseconds: 300));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await watch(tester, const Duration(seconds: 4));
    expect(reporter.viewedIds, isEmpty);
    expect(find.byType(StoryViewerScreen), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await watch(tester, const Duration(milliseconds: 1000));
    expect(reporter.viewedIds, [story.id]);
    await finish(tester);
  });

  testWidgets('moving on at once leaves the story unseen', (tester) async {
    final first = _story(_author, 'https://x.example/one');
    final second = _story(_author, 'https://x.example/two');
    await open(
      tester,
      [first, second],
      {
        'https://x.example/one': _picture(),
        'https://x.example/two': _picture(),
      },
    );
    await watch(tester, const Duration(milliseconds: 300));

    // A tap on the right side: next story.
    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    await tester.tapAt(Offset(size.width * 0.9, size.height / 2));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await watch(tester, const Duration(milliseconds: 1300));

    expect(reporter.viewedIds, [second.id]);
    expect(seen(), {second.id});
    await finish(tester);
  });

  testWidgets('a story watched again is not counted twice', (tester) async {
    final first = _story(_author, 'https://x.example/a');
    final second = _story(_author, 'https://x.example/b');
    await open(
      tester,
      [first, second],
      {'https://x.example/a': _picture(), 'https://x.example/b': _picture()},
    );
    await watch(tester, const Duration(milliseconds: 1300));
    expect(reporter.viewedIds, [first.id]);

    // Back to it, and watch it all over again.
    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    await tester.tapAt(Offset(size.width * 0.9, size.height / 2));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await watch(tester, const Duration(milliseconds: 600));
    await tester.tapAt(Offset(size.width * 0.1, size.height / 2));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await watch(tester, const Duration(milliseconds: 1300));

    expect(reporter.viewedIds.where((id) => id == first.id).length, 2);
    // ...the viewer tells the reporter each time; the reporter and the seen
    // list make a repeat a no-op (see story_receipts_test).
    expect(seen(), contains(first.id));
    await finish(tester);
  });

  testWidgets('a guest watches without sending anything', (tester) async {
    final story = _story(_author, 'https://x.example/guest');
    await open(
      tester,
      [story],
      {'https://x.example/guest': _picture()},
      as: GuestSigner(),
      realReporter: true,
    );
    final real = container.read(storyViewReporterProvider);
    expect(real.owner, isNull);

    await watch(tester, const Duration(seconds: 6));
    expect(real.pendingCount, 0);
    await finish(tester);
    expect(delivery.sends, 0);
  });

  testWidgets('closing the viewer flushes once and does not throw', (
    tester,
  ) async {
    final story = _story(_author, 'https://x.example/close');
    await open(tester, [story], {'https://x.example/close': _picture()});
    await watch(tester, const Duration(milliseconds: 1500));
    final before = reporter.flushes;

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump(); // the route starts leaving
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(StoryViewerScreen), findsNothing);
    expect(reporter.flushes, before + 1);
    expect(tester.takeException(), isNull);
    await finish(tester);
  });
}
