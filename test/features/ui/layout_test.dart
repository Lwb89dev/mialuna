import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/models/media_event.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/core/theme/mialuna_theme.dart';
import 'package:mialuna/features/create/create_controller.dart';
import 'package:mialuna/features/create/create_screen.dart';
import 'package:mialuna/features/explore/explore_screen.dart';
import 'package:mialuna/features/feed/feed_screen.dart';
import 'package:mialuna/features/feed/widgets/post_card.dart';
import 'package:mialuna/features/messages/chat_screen.dart';
import 'package:mialuna/features/messages/dm_controller.dart';
import 'package:mialuna/features/messages/inbox_screen.dart';
import 'package:mialuna/features/notifications/notifications_controller.dart';
import 'package:mialuna/features/notifications/notifications_screen.dart';
import 'package:mialuna/features/private/close_friends.dart';
import 'package:mialuna/features/private/close_friends_screen.dart';
import 'package:mialuna/features/profile/profile_screen.dart';
import 'package:mialuna/features/settings/settings_screen.dart';
import 'package:mialuna/features/stories/stories_controller.dart';
import 'package:mialuna/features/stories/stories_rail.dart';
import 'package:mialuna/features/stories/story_composer_screen.dart';
import 'package:mialuna/features/stories/story_text_editor.dart';
import 'package:mialuna/core/nostr/models/story_text.dart';
import 'package:mialuna/l10n/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/story_fixtures.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

class _FakeDm extends DmController {
  final DmState fixed;
  _FakeDm(this.fixed);
  @override
  DmState build() => fixed;

  // The real one schedules a disk write; not needed for layout checks.
  @override
  void markRead(String peer) {}
}

class _FakeNotifications extends NotificationsController {
  final NotificationsState fixed;
  _FakeNotifications(this.fixed);
  @override
  NotificationsState build() => fixed;
}

NotificationsState unreadNotifications(int count) => NotificationsState(
  items: [
    for (var i = 0; i < count; i++)
      NotificationItem(
        event: NostrEvent(
          id: '$i'.padLeft(64, '0'),
          pubkey: _peer,
          createdAt: 1700000000 + i,
          kind: NostrKinds.reaction,
          tags: const [],
          content: '+',
          sig: '',
        ),
        kind: NotificationKind.reaction,
        actor: _peer,
      ),
  ],
);

class _FakeStories extends StoriesController {
  final List<StoryGroup> groups;
  _FakeStories(this.groups);
  @override
  StoriesState build() => StoriesState(groups: groups, isLoading: false);
}

Uint8List _picture() {
  final image = img.Image(width: 40, height: 30);
  img.fill(image, color: img.ColorRgb8(220, 90, 50));
  return Uint8List.fromList(img.encodeJpg(image));
}

/// A composer holding one picture, with no network behind it.
class _StoryComposer extends ComposerController {
  final bool withPicture;
  _StoryComposer({this.withPicture = true});

  @override
  ComposerState build() => ComposerState(
    mode: ComposerMode.story,
    media: withPicture
        ? [
            PickedMedia(
              file: XFile.fromData(_picture(), name: 'a.jpg'),
              bytes: _picture(),
              mimeType: 'image/jpeg',
            ),
          ]
        : const [],
    overlays: const [
      StoryText(text: 'Una frase lunga che va a capo #hashtag', y: 0.4),
    ],
  );

  @override
  Future<({Uint8List? bytes, double? aspect})> storyBackdrop() async =>
      (bytes: _picture(), aspect: 40 / 30);
}

class _Friends extends CloseFriendsController {
  @override
  CloseFriendsState build() => CloseFriendsState(
    members: [for (var i = 0; i < 9; i++) '${i}1' * 32],
    synced: true,
  );

  @override
  Future<void> sync() async {}
}

class _EmptyFriends extends CloseFriendsController {
  @override
  CloseFriendsState build() => const CloseFriendsState(synced: true);

  @override
  Future<void> sync() async {}
}

class _ClosePref extends AudiencePreference {
  @override
  Audience build() => Audience.closeFriends;
}

final _me = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
final _peer = 'ab' * 32;
const _longText =
    'Una didascalia molto lunga che continua per diverse righe, con parole '
    'lunghissime come supercalifragilistichespiralidoso e un po\' di #hashtag '
    'per vedere come si comporta il testo quando lo schermo è stretto. '
    'Ancora testo, ancora testo, ancora testo, ancora testo, ancora testo.';

MediaPost post({
  int kind = 20,
  List<MediaItem>? media,
  String caption = _longText,
  bool sensitive = false,
}) {
  final items =
      media ??
      [
        const MediaItem(
          url: 'https://x.example/a.jpg',
          mimeType: 'image/jpeg',
          width: 1080,
          height: 1350,
        ),
      ];
  return MediaPost.tryParse(
    NostrEvent(
      id: '1' * 64,
      pubkey: _peer,
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000 - 3600,
      kind: kind,
      tags: [
        for (final m in items) m.toImetaTag(),
        if (sensitive) ['content-warning', 'spoiler'],
      ],
      content: caption,
      sig: '',
    ),
  )!;
}

DmState dmWith(List<DmMessage> messages) => DmState(
  conversations: {_peer: Conversation(_peer, messages, 0)},
  inboxConfigured: true,
);

final _messages = [
  for (var i = 0; i < 12; i++)
    DmMessage(
      id: 'm$i',
      peer: _peer,
      fromMe: i.isEven,
      createdAt: 1700000000 + i * 60,
      text: i == 5
          ? 'nostr:nevent1qqs0000000000000000000000000000000000000000000000000000000q9ed5'
          : (i == 6 ? _longText : 'messaggio numero $i'),
    ),
];

void main() {
  late Directory tmp;

  /// Every screen is laid out in each language: translations change lengths.
  var activeLocale = 'en';

  setUp(() {
    activeLocale = 'en';
    SharedPreferences.setMockInitialValues({});
    tmp = Directory.systemTemp.createTempSync('mialuna_ui_');
  });

  Future<void> pumpScreen(
    WidgetTester tester,
    Widget screen, {
    required Size size,
    double textScale = 1,
    DmState? dm,
    bool dark = false,
    List<Override> extra = const [],
  }) async {
    tester.view.physicalSize = size * 2;
    tester.view.devicePixelRatio = 2;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          indexerRelaysProvider.overrideWithValue(const []),
          relayPoolProvider.overrideWithValue(RelayPool(const [])),
          localCacheProvider.overrideWithValue(LocalCache(directory: tmp)),
          authProvider.overrideWith(() => _FixedAuth(_me)),
          dmProvider.overrideWith(() => _FakeDm(dm ?? const DmState())),
          friendReachableProvider.overrideWith(
            (ref, pk) async => !pk.startsWith('11'),
          ),
          ...extra,
        ],
        child: MaterialApp(
          locale: Locale(activeLocale),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) {
            AppStrings.current = AppLocalizations.of(context);
            return child!;
          },
          theme: dark ? MialunaTheme.dark() : MialunaTheme.light(),
          home: screen,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// Fails on any layout exception (RenderFlex overflow included), then
  /// lets the screen's own timeouts run out so none is left pending.
  Future<void> expectClean(WidgetTester tester, String label) async {
    final error = tester.takeException();
    // The full description names the widget that overflowed.
    final detail = error is FlutterError ? error.toStringDeep() : '$error';
    expect(error, isNull, reason: '$label: $detail');
    // Screens start background loads with timeouts: tear the tree down and
    // let them elapse so no timer is left pending.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 40));
  }

  // 411x923 is the Pixel the bug was reported on; 320x568 the smallest
  // phone; 800x1280 a tablet.
  const sizes = {
    'small phone': Size(320, 568),
    'pixel': Size(411, 923),
    'tablet': Size(800, 1280),
  };

  for (final lang in AppLocalizations.supportedLocales.map(
    (l) => l.languageCode,
  )) {
    group('[$lang]', () {
      setUp(() => activeLocale = lang);

      for (final entry in sizes.entries) {
        for (final scale in [1.0, 2.0]) {
          final where = '${entry.key} x$scale';

          testWidgets('photo post card · $where', (tester) async {
            await pumpScreen(
              tester,
              Scaffold(
                body: SingleChildScrollView(child: PostCard(post: post())),
              ),
              size: entry.value,
              textScale: scale,
            );
            await expectClean(tester, where);
          });

          testWidgets('video and carousel posts · $where', (tester) async {
            await pumpScreen(
              tester,
              Scaffold(
                body: ListView(
                  children: [
                    PostCard(
                      post: post(
                        kind: 22,
                        media: [
                          const MediaItem(
                            url: 'https://x.example/v.mp4',
                            mimeType: 'video/mp4',
                            width: 1080,
                            height: 1920,
                            duration: 44,
                          ),
                        ],
                      ),
                    ),
                    PostCard(
                      post: post(
                        media: [
                          for (var i = 0; i < 3; i++)
                            MediaItem(
                              url: 'https://x.example/$i.jpg',
                              mimeType: 'image/jpeg',
                              width: 1920,
                              height: 1080,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              size: entry.value,
              textScale: scale,
            );
            await expectClean(tester, where);
          });

          testWidgets('own profile · $where', (tester) async {
            await pumpScreen(
              tester,
              const ProfileScreen(),
              size: entry.value,
              textScale: scale,
            );
            await expectClean(tester, where);
          });

          testWidgets('inbox · $where', (tester) async {
            await pumpScreen(
              tester,
              const InboxScreen(),
              size: entry.value,
              textScale: scale,
              dm: dmWith(_messages),
            );
            await expectClean(tester, where);
          });

          testWidgets('message requests · $where', (tester) async {
            final requests = DmState(
              conversations: {
                _peer: Conversation(_peer, _messages, 0, isRequest: true),
              },
              inboxConfigured: true,
            );
            // The inbox points at them…
            await pumpScreen(
              tester,
              const InboxScreen(),
              size: entry.value,
              textScale: scale,
              dm: requests,
            );
            expect(
              find.byIcon(Icons.mark_email_unread_outlined),
              findsOneWidget,
            );
            await expectClean(tester, '$where (inbox)');
            // …and this is where they are.
            await pumpScreen(
              tester,
              const InboxScreen(requests: true),
              size: entry.value,
              textScale: scale,
              dm: requests,
            );
            await expectClean(tester, '$where (requests)');
          });

          testWidgets('chat · $where', (tester) async {
            await pumpScreen(
              tester,
              ChatScreen(peer: _peer),
              size: entry.value,
              textScale: scale,
              dm: dmWith(_messages),
            );
            await expectClean(tester, where);
          });

          testWidgets('settings · $where', (tester) async {
            await pumpScreen(
              tester,
              const SettingsScreen(),
              size: entry.value,
              textScale: scale,
            );
            await expectClean(tester, where);
          });

          testWidgets('create · $where', (tester) async {
            await pumpScreen(
              tester,
              const CreateScreen(),
              size: entry.value,
              textScale: scale,
            );
            await expectClean(tester, where);
          });

          testWidgets('create with photos · $where', (tester) async {
            await pumpScreen(
              tester,
              const CreateScreen(),
              size: entry.value,
              textScale: scale,
            );
            final container = ProviderScope.containerOf(
              tester.element(find.byType(CreateScreen)),
            );
            final photo = Uint8List.fromList(
              img.encodeJpg(img.Image(width: 30, height: 20)),
            );
            for (var i = 0; i < 2; i++) {
              container
                  .read(composerProvider.notifier)
                  .addPicked(
                    PickedMedia(
                      file: XFile.fromData(photo, name: 'p$i.jpg'),
                      bytes: photo,
                      mimeType: 'image/jpeg',
                    ),
                  );
            }
            await tester.pump();
            await tester.scrollUntilVisible(
              find.byIcon(Icons.tune),
              200,
              scrollable: find.byType(Scrollable).first,
            );
            expect(find.byIcon(Icons.tune), findsOneWidget);
            await expectClean(tester, where);
          });

          testWidgets('explore · $where', (tester) async {
            await pumpScreen(
              tester,
              const ExploreScreen(),
              size: entry.value,
              textScale: scale,
            );
            await expectClean(tester, where);
          });

          testWidgets('close friends list · $where', (tester) async {
            await pumpScreen(
              tester,
              const CloseFriendsScreen(),
              size: entry.value,
              textScale: scale,
              extra: [closeFriendsProvider.overrideWith(_Friends.new)],
            );
            await expectClean(tester, where);
          });

          testWidgets('close friends list, empty · $where', (tester) async {
            await pumpScreen(
              tester,
              const CloseFriendsScreen(),
              size: entry.value,
              textScale: scale,
              extra: [closeFriendsProvider.overrideWith(_EmptyFriends.new)],
            );
            await expectClean(tester, where);
          });

          testWidgets('create for close friends · $where', (tester) async {
            await pumpScreen(
              tester,
              const CreateScreen(),
              size: entry.value,
              textScale: scale,
              extra: [
                audiencePreferenceProvider.overrideWith(_ClosePref.new),
                closeFriendsProvider.overrideWith(_Friends.new),
              ],
            );
            await expectClean(tester, where);
          });

          testWidgets('close friends explainer · $where', (tester) async {
            await pumpScreen(
              tester,
              const Scaffold(
                body: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: CloseFriendsExplainer(),
                ),
              ),
              size: entry.value,
              textScale: scale,
            );
            await expectClean(tester, where);
          });

          testWidgets('private post card · $where', (tester) async {
            final private = MediaPost.tryParse(
              NostrEvent(
                id: '2' * 64,
                pubkey: _peer,
                createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000 - 60,
                kind: 20,
                tags: [
                  [
                    'imeta',
                    'url https://x.example/blob',
                    'm image/jpeg',
                    'dim 800x1000',
                    'decryption-key ${'a' * 64}',
                    'decryption-nonce ${'b' * 24}',
                  ],
                  ['audience', 'close-friends'],
                  ['p', _peer],
                ],
                content: _longText,
                sig: '',
              ),
              allowPrivate: true,
            )!;
            await pumpScreen(
              tester,
              Scaffold(
                body: SingleChildScrollView(child: PostCard(post: private)),
              ),
              size: entry.value,
              textScale: scale,
            );
            expect(find.byIcon(Icons.star), findsOneWidget);
            expect(find.byIcon(Icons.bolt_outlined), findsNothing); // no zaps
            expect(
              find.byIcon(Icons.send_outlined),
              findsNothing,
            ); // no forwarding
            expect(
              find.byIcon(Icons.bookmark_border),
              findsNothing,
            ); // no saving
            await expectClean(tester, where);
          });

          testWidgets('home bar with unread badges · $where', (tester) async {
            await pumpScreen(
              tester,
              const FeedScreen(),
              size: entry.value,
              textScale: scale,
              dm: DmState(
                conversations: {
                  _peer: Conversation(_peer, _messages, 0), // 6 from them
                },
                inboxConfigured: true,
              ),
              extra: [
                notificationsProvider.overrideWith(
                  () => _FakeNotifications(unreadNotifications(150)),
                ),
              ],
            );
            expect(find.text('99+'), findsOneWidget); // the bell
            expect(find.text('6'), findsOneWidget); // the paper plane
            await expectClean(tester, where);
          });

          testWidgets('stories rail · $where', (tester) async {
            await pumpScreen(
              tester,
              const Scaffold(body: StoriesRail()),
              size: entry.value,
              textScale: scale,
              extra: [
                storiesProvider.overrideWith(
                  () => _FakeStories([
                    storiesOf(_me.publicKey, 3),
                    storiesOf(_peer, 7),
                    storiesOf('cd' * 32, 1, private: true),
                  ]),
                ),
              ],
            );
            await expectClean(tester, where);
          });

          testWidgets('story composer · $where', (tester) async {
            await pumpScreen(
              tester,
              const StoryComposerScreen(fresh: false),
              size: entry.value,
              textScale: scale,
              extra: [composerProvider.overrideWith(_StoryComposer.new)],
            );
            await tester.pump(const Duration(milliseconds: 300));
            await expectClean(tester, where);
          });

          testWidgets('story composer, nothing chosen · $where', (
            tester,
          ) async {
            await pumpScreen(
              tester,
              const StoryComposerScreen(fresh: false),
              size: entry.value,
              textScale: scale,
              extra: [
                composerProvider.overrideWith(
                  () => _StoryComposer(withPicture: false),
                ),
              ],
            );
            await expectClean(tester, where);
          });

          testWidgets('story text editor · $where', (tester) async {
            await pumpScreen(
              tester,
              const StoryTextEditorScreen(
                mediaAspect: 0.75,
                initial: [StoryText(text: 'Ciao #mare')],
              ),
              size: entry.value,
              textScale: scale,
            );
            await tester.tap(find.byTooltip(AppStrings.current.storyAddText));
            await tester.pump(const Duration(milliseconds: 300));
            await expectClean(tester, where);
          });

          testWidgets('notifications · $where', (tester) async {
            await pumpScreen(
              tester,
              const NotificationsScreen(),
              size: entry.value,
              textScale: scale,
            );
            await expectClean(tester, where);
          });
        }
      }
    });
  }

  testWidgets('sensitive posts stay covered until tapped', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: PostCard(post: post(sensitive: true)),
        ),
      ),
      size: sizes['pixel']!,
    );
    expect(find.text('Show'), findsOneWidget);
    await tester.tap(find.text('Show'));
    await tester.pump();
    expect(find.text('Show'), findsNothing);
    await expectClean(tester, 'sensitive');
  });

  testWidgets('dark theme renders too', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: SingleChildScrollView(child: PostCard(post: post())),
      ),
      size: sizes['pixel']!,
      dark: true,
    );
    await expectClean(tester, 'dark');
  });

  testWidgets('long captions collapse and expand on tap', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: SingleChildScrollView(child: PostCard(post: post())),
      ),
      size: sizes['small phone']!,
    );
    final collapsed = tester.getSize(find.byType(CaptionText)).height;
    await tester.tap(find.byType(CaptionText));
    await tester.pump();
    expect(
      tester.getSize(find.byType(CaptionText)).height,
      greaterThan(collapsed),
    );
  });
}
