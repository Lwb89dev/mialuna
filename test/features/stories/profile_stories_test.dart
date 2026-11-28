import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/core/theme/mialuna_theme.dart';
import 'package:mialuna/features/profile/profile_screen.dart';
import 'package:mialuna/features/social/moderation_controller.dart';
import 'package:mialuna/features/stories/stories_controller.dart';
import 'package:mialuna/features/stories/story_ring.dart';
import 'package:mialuna/features/stories/story_viewer.dart';
import 'package:mialuna/l10n/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/story_fixtures.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

class _Stories extends StoriesController {
  final List<StoryGroup> groups;
  _Stories(this.groups);
  @override
  StoriesState build() => StoriesState(groups: groups, isLoading: false);
}

class _Blocked extends BlockController {
  final Set<String> blocked;
  _Blocked(this.blocked);
  @override
  Set<String> build() => blocked;
}

final _me = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
final _ana = 'a1' * 32;

void main() {
  late Directory tmp;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    tmp = Directory.systemTemp.createTempSync('mialuna_profile_stories_');
  });

  Future<void> pump(
    WidgetTester tester,
    List<StoryGroup> groups, {
    Set<String> blocked = const {},
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          indexerRelaysProvider.overrideWithValue(const []),
          relayPoolProvider.overrideWithValue(RelayPool(const [])),
          localCacheProvider.overrideWithValue(LocalCache(directory: tmp)),
          authProvider.overrideWith(() => _FixedAuth(_me)),
          storiesProvider.overrideWith(() => _Stories(groups)),
          blockProvider.overrideWith(() => _Blocked(blocked)),
        ],
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: MialunaTheme.light(),
          home: ProfileScreen(pubkey: _ana),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 40));
  }

  testWidgets('a profile with stories up has the ring of the Home rail', (
    tester,
  ) async {
    await pump(tester, [storiesOf(_ana, 3)]);

    final ring = tester.widget<StoryRing>(find.byType(StoryRing));
    expect(ring.segments, List.filled(3, StorySegment.unseen));
    await finish(tester);
  });

  testWidgets('tapping it plays their stories', (tester) async {
    await pump(tester, [storiesOf(_ana, 2)]);

    await tester.tap(find.byType(StoryRing));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final viewer = tester.widget<StoryViewerScreen>(
      find.byType(StoryViewerScreen),
    );
    expect(viewer.groups.single.author, _ana);
    expect(viewer.groups.single.stories, hasLength(2));
    await finish(tester);
  });

  testWidgets('no stories, no ring', (tester) async {
    await pump(tester, [storiesOf(_me.publicKey, 1)]);

    expect(find.byType(StoryRing), findsNothing);
    await finish(tester);
  });

  testWidgets('nor for someone you blocked', (tester) async {
    await pump(tester, [storiesOf(_ana, 1)], blocked: {_ana});

    expect(find.byType(StoryRing), findsNothing);
    await finish(tester);
  });
}
