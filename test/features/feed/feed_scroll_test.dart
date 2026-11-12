import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/models/media_event.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/feed/feed_controller.dart';
import 'package:mialuna/features/feed/feed_screen.dart';
import 'package:mialuna/features/feed/widgets/post_card.dart';
import 'package:mialuna/features/messages/dm_controller.dart';
import 'package:mialuna/features/notifications/notifications_controller.dart';
import 'package:mialuna/l10n/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

class _FakeDm extends DmController {
  @override
  DmState build() => const DmState(inboxConfigured: true);
}

class _FakeNotifications extends NotificationsController {
  @override
  NotificationsState build() => const NotificationsState();
}

/// A feed whose content the test decides.
class _Feed extends FeedController {
  FeedState initial;
  _Feed(super.arg, this.initial);

  @override
  FeedState build() => initial;

  void show(FeedState next) => state = next;
}

final _peer = 'ab' * 32;
int _n = 0;

MediaPost _post(List<MediaItem> media) {
  final id = '${++_n}'.padLeft(64, '0');
  return MediaPost.tryParse(
    NostrEvent(
      id: id,
      pubkey: _peer,
      createdAt: 1700000000 + _n,
      kind: NostrKinds.picture,
      tags: [for (final m in media) m.toImetaTag()],
      content: 'post $_n',
      sig: '',
    ),
  )!;
}

MediaItem _picture(String name, {bool sized = true}) => MediaItem(
  url: 'https://x.example/$name.jpg',
  mimeType: 'image/jpeg',
  width: sized ? 1080 : null,
  height: sized ? 1350 : null,
);

FeedState _showing(List<MediaPost> posts) =>
    FeedState(posts: posts, isLoading: false, hasMore: false);

/// Scrolling Home: cards that did not change are not rebuilt, a single
/// picture does not fight the vertical scroll with a carousel, and a card
/// that comes back keeps its height.
void main() {
  late Directory tmp;
  late _Feed feed;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    tmp = Directory.systemTemp.createTempSync('mialuna_scroll_');
  });

  Future<void> pumpHome(WidgetTester tester, List<MediaPost> posts) async {
    tester.view.physicalSize = const Size(822, 1846);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          indexerRelaysProvider.overrideWithValue(const []),
          relayPoolProvider.overrideWithValue(RelayPool(const [])),
          localCacheProvider.overrideWithValue(LocalCache(directory: tmp)),
          authProvider.overrideWith(
            () => _FixedAuth(
              NsecSigner.fromNsec(NsecSigner.generatePrivateKey()),
            ),
          ),
          dmProvider.overrideWith(_FakeDm.new),
          notificationsProvider.overrideWith(_FakeNotifications.new),
          feedProvider.overrideWith2(
            (mode) => feed = _Feed(mode, _showing(posts)),
          ),
        ],
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const FeedScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> tearDownTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 40));
  }

  PostCard cardOf(WidgetTester tester, MediaPost post) =>
      tester.widget<PostCard>(find.byKey(ValueKey(post.id)));

  testWidgets('a new post on top does not rebuild the cards below', (
    tester,
  ) async {
    final a = _post([_picture('a')]);
    final b = _post([_picture('b')]);
    await pumpHome(tester, [a, b]);
    final before = cardOf(tester, a);

    feed.show(
      _showing([
        _post([_picture('c')]),
        a,
        b,
      ]),
    );
    await tester.pump();
    expect(identical(cardOf(tester, a), before), true);
    await tearDownTree(tester);
  });

  testWidgets('only a carousel has a carousel', (tester) async {
    final single = _post([_picture('solo')]);
    final carousel = _post([_picture('x'), _picture('y'), _picture('z')]);
    await pumpHome(tester, [single, carousel]);

    PageView? pagerIn(MediaPost p) {
      final found = find.descendant(
        of: find.byKey(ValueKey(p.id)),
        matching: find.byType(PageView),
      );
      return found.evaluate().isEmpty ? null : tester.widget(found);
    }

    expect(pagerIn(single), isNull, reason: 'a drag to fight the scroll');
    expect(pagerIn(carousel), isNotNull);
    await tearDownTree(tester);
  });

  testWidgets('a card that comes back has its real shape at once', (
    tester,
  ) async {
    final unsized = _post([_picture('senza-dim', sized: false)]);
    // Learned the first time its picture loaded.
    rememberMediaAspect(unsized.media.first.url, 1.5);
    await pumpHome(tester, [unsized]);

    final ratio = tester.widget<AspectRatio>(
      find
          .descendant(
            of: find.byType(PostMedia),
            matching: find.byType(AspectRatio),
          )
          .first,
    );
    expect(ratio.aspectRatio, 1.5);
    await tearDownTree(tester);
  });
}
