import 'dart:async';
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
import 'package:mialuna/features/feed/widgets/post_card.dart';
import 'package:mialuna/features/social/delete_post_flow.dart';
import 'package:mialuna/features/social/deleted_posts.dart';
import 'package:mialuna/features/social/post_deletion.dart';
import 'package:mialuna/l10n/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

/// Stands in for the deletion itself: records what it was asked, and answers
/// when the test says so.
class _FakeDeletion implements PostDeletion {
  final List<MediaPost> calls = [];
  Completer<DeletionReport>? gate;
  DeletionReport report = const DeletionReport();
  Object? error;

  @override
  Future<DeletionReport> delete(MediaPost post) {
    calls.add(post);
    if (error != null) return Future.error(error!);
    return gate?.future ?? Future.value(report);
  }
}

void main() {
  late Directory tmp;
  late NsecSigner me;
  late NsecSigner someone;
  late _FakeDeletion deletion;
  var locale = 'en';

  setUp(() {
    locale = 'en';
    SharedPreferences.setMockInitialValues({});
    tmp = Directory.systemTemp.createTempSync('mialuna_del_ui_');
    me = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
    someone = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
    deletion = _FakeDeletion();
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  MediaPost post(
    Signer author, {
    List<List<String>> extra = const [],
    bool private = false,
  }) => MediaPost.tryParse(
    NostrEvent(
      id: (author == me ? 'a' : 'b') * 64,
      pubkey: author.publicKey!,
      createdAt: 1700000000,
      kind: NostrKinds.picture,
      tags: [
        ['imeta', 'url https://x.example/a.jpg', 'm image/jpeg'],
        if (private) ...[
          ['audience', 'close-friends'],
          ['p', me.publicKey],
        ],
        ...extra,
      ],
      content: 'a caption',
      sig: '',
    ),
    allowPrivate: private,
  )!;

  Future<void> pump(
    WidgetTester tester,
    Widget screen, {
    bool bare = false,
  }) async {
    tester.view.physicalSize = const Size(822, 1846);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          indexerRelaysProvider.overrideWithValue(const []),
          relayPoolProvider.overrideWithValue(RelayPool(const [])),
          localCacheProvider.overrideWithValue(LocalCache(directory: tmp)),
          authProvider.overrideWith(() => _FixedAuth(me)),
          postDeletionProvider.overrideWithValue(deletion),
        ],
        child: MaterialApp(
          locale: Locale(locale),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) {
            AppStrings.current = AppLocalizations.of(context);
            return child!;
          },
          home: bare
              ? screen
              : Scaffold(body: SingleChildScrollView(child: screen)),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// A route that was just pushed or popped needs a frame to start moving
  /// and then some time to arrive.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byType(PopupMenuButton<String>));
    await settle(tester);
  }

  Future<void> chooseDelete(
    WidgetTester tester, [
    String label = 'Delete',
  ]) async {
    await openMenu(tester);
    await tester.tap(find.widgetWithText(PopupMenuItem<String>, label));
    // The menu closes, and only then does the choice take effect.
    await settle(tester);
  }

  /// The red button in the dialog, not the menu entry.
  Finder confirmButton() => find.byType(FilledButton);

  group('the post menu', () {
    testWidgets(
      'of your own post offers Delete, and nothing aimed at an author',
      (tester) async {
        await pump(tester, PostCard(post: post(me)));
        await openMenu(tester);

        expect(find.text('Delete'), findsOneWidget);
        expect(find.text('Save'), findsOneWidget);
        expect(find.text('Copy link'), findsOneWidget);
        expect(find.text('Mute author'), findsNothing);
        expect(find.text('Block author'), findsNothing);
        expect(find.text('Report'), findsNothing);
      },
    );

    testWidgets('of somebody else\'s post has no Delete', (tester) async {
      await pump(tester, PostCard(post: post(someone)));
      await openMenu(tester);

      expect(find.text('Delete'), findsNothing);
      expect(find.text('Mute author'), findsOneWidget);
      expect(find.text('Block author'), findsOneWidget);
      expect(find.text('Report'), findsOneWidget);
    });

    testWidgets(
      'of your own close-friends post offers Delete, but no Save or Report',
      (tester) async {
        await pump(tester, PostCard(post: post(me, private: true)));
        await openMenu(tester);

        expect(find.text('Delete'), findsOneWidget);
        expect(find.text('Report'), findsNothing);
        expect(find.text('Save'), findsNothing);
      },
    );

    testWidgets('is in Italian too', (tester) async {
      locale = 'it';
      await pump(tester, PostCard(post: post(me)));
      await openMenu(tester);

      expect(find.text('Elimina'), findsOneWidget);
    });
  });

  group('deleting from the menu', () {
    testWidgets('asks first, and Cancel does nothing', (tester) async {
      final p = post(me);
      await pump(tester, PostCard(post: p));

      await chooseDelete(tester);
      expect(find.text('Delete this post?'), findsOneWidget);
      expect(
        find.textContaining('ask your relays to delete it'),
        findsOneWidget,
      );
      await tester.tap(find.text('Cancel'));
      await settle(tester);

      expect(deletion.calls, isEmpty);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('a story is asked about as a story', (tester) async {
      final story = post(
        me,
        extra: [
          ['L', 'mialuna.story'],
          ['l', 'story', 'mialuna.story'],
        ],
      );
      await pump(tester, PostCard(post: story));

      await chooseDelete(tester);

      expect(find.text('Delete this story?'), findsOneWidget);
    });

    testWidgets('a close-friends post explains that relays cannot recall it', (
      tester,
    ) async {
      await pump(tester, PostCard(post: post(me, private: true)));

      await chooseDelete(tester);

      expect(find.textContaining("can't be recalled"), findsOneWidget);
    });

    testWidgets('shows that it is working, then says it is done', (
      tester,
    ) async {
      final p = post(me);
      deletion.gate = Completer();
      await pump(tester, PostCard(post: p));

      await chooseDelete(tester);
      await tester.tap(confirmButton());
      await settle(tester);

      expect(deletion.calls, [p]);
      expect(find.text('Deleting…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      deletion.gate!.complete(const DeletionReport());
      await settle(tester);

      expect(find.text('Deleting…'), findsNothing);
      expect(find.text('Deleted.'), findsOneWidget);
    });

    testWidgets('a refusal from every relay is said plainly', (tester) async {
      deletion.report = const DeletionReport(
        failure: DeletionFailure.noRelayAccepted,
      );
      await pump(tester, PostCard(post: post(me)));

      await chooseDelete(tester);
      await tester.tap(confirmButton());
      await settle(tester);

      expect(find.textContaining('still online'), findsOneWidget);
      expect(find.text('Deleted.'), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('says what could not be done on top of the deletion', (
      tester,
    ) async {
      deletion.report = const DeletionReport(
        mediaLeft: ['cdn.example.com', 'files.example.org'],
        friendsAsked: 3,
        friendsReached: 1,
      );
      await pump(tester, PostCard(post: post(me)));

      await chooseDelete(tester);
      await tester.tap(confirmButton());
      await settle(tester);

      final text = tester.widget<Text>(
        find.descendant(of: find.byType(SnackBar), matching: find.byType(Text)),
      );
      expect(text.data, startsWith('Deleted.'));
      expect(text.data, contains('cdn.example.com, files.example.org'));
      expect(text.data, contains('2 of your close friends'));
    });

    testWidgets('the wait can be closed, and the outcome still comes up', (
      tester,
    ) async {
      deletion.gate = Completer();
      await pump(tester, PostCard(post: post(me)));
      await chooseDelete(tester);
      await tester.tap(confirmButton());
      await settle(tester);
      expect(find.text('Deleting…'), findsOneWidget);

      await tester.tapAt(const Offset(5, 5)); // outside the dialog
      await settle(tester);
      expect(find.text('Deleting…'), findsNothing);

      deletion.gate!.complete(const DeletionReport());
      await settle(tester);

      expect(find.text('Deleted.'), findsOneWidget);
      expect(
        find.byType(PostCard),
        findsOneWidget,
        reason: 'no screen was closed',
      );
    });

    testWidgets('an unforeseen error closes the wait and is shown', (
      tester,
    ) async {
      deletion.error = StateError('boom');
      await pump(tester, PostCard(post: post(me)));

      await chooseDelete(tester);
      await tester.tap(confirmButton());
      await settle(tester);

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.textContaining('boom'), findsOneWidget);
    });

    testWidgets('still finishes when the card has scrolled away meanwhile', (
      tester,
    ) async {
      deletion.gate = Completer();
      await pump(tester, PostCard(post: post(me)));
      await chooseDelete(tester);
      await tester.tap(confirmButton());
      await tester.pump(const Duration(milliseconds: 100));

      // The card leaves the tree (a list that rebuilt without it).
      await tester.pumpWidget(const SizedBox());
      deletion.gate!.complete(const DeletionReport());
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
    });
  });

  group('deletionMessage', () {
    final en = lookupAppLocalizations(const Locale('en'));

    test('a clean deletion is one word', () {
      expect(deletionMessage(en, const DeletionReport()), 'Deleted.');
    });

    test('names why the signer refused', () {
      const report = DeletionReport(
        failure: DeletionFailure.signerRefused,
        detail: 'Amber said no',
      );
      expect(deletionMessage(en, report), contains('Amber said no'));
    });

    test('a refused authorization for the media is its own sentence', () {
      const report = DeletionReport(mediaError: 'denied', mediaLeft: ['a.com']);
      final text = deletionMessage(en, report);
      expect(text, contains('did not authorize'));
      expect(text, isNot(contains('a.com')));
    });

    test('an unforeseen error shows its words', () {
      const report = DeletionReport(
        failure: DeletionFailure.failed,
        detail: 'boom',
      );
      expect(deletionMessage(en, report), contains('boom'));
    });

    test('not the author', () {
      const report = DeletionReport(failure: DeletionFailure.notAllowed);
      expect(deletionMessage(en, report), contains('Only the account'));
    });

    test('friends all reached add nothing', () {
      const report = DeletionReport(friendsAsked: 2, friendsReached: 2);
      expect(deletionMessage(en, report), 'Deleted.');
    });
  });

  group('the post screen', () {
    testWidgets('shows the post, and a note instead once it is deleted', (
      tester,
    ) async {
      final p = post(someone);
      await pump(tester, PostScreen(post: p), bare: true);
      expect(find.byType(PostCard), findsOneWidget);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(PostScreen)),
      );
      container.read(deletedPostsProvider.notifier).add([p.id]);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(PostCard), findsNothing);
      expect(find.text('This post was deleted.'), findsOneWidget);
    });
  });
}
