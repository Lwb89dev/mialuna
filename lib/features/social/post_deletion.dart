import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/media/blossom.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/nip59.dart';
import '../../core/nostr/profile_repository.dart';
import '../../core/nostr/signer.dart';
import '../messages/dm_controller.dart' show DmException;
import '../private/private_delivery.dart';
import 'deleted_posts.dart';
import 'moderation_controller.dart';

/// Why a post could not be deleted at all.
enum DeletionFailure {
  /// The post is somebody else's, or this account cannot sign.
  notAllowed,

  /// The signer (Amber, a remote signer) declined or failed.
  signerRefused,

  /// No relay accepted the deletion request: the post is still out there.
  noRelayAccepted,

  /// Something unforeseen went wrong; [DeletionReport.detail] has the words.
  failed,
}

/// What deleting a post achieved. A report with no [failure] means the post is
/// gone from this phone and was asked to be gone elsewhere; the rest says what
/// could not be done on top of that.
class DeletionReport {
  final DeletionFailure? failure;

  /// The signer's or the relay's own words, when they help.
  final String? detail;

  /// Close-friends posts: the people it went to, and those who were told it
  /// was taken back.
  final int friendsAsked;
  final int friendsReached;

  /// Servers (by host) that still hold a file of the post, because they
  /// refused, did not answer, or are not Blossom servers at all.
  final List<String> mediaLeft;

  /// Files left alone because another post of the same account uses them.
  final int mediaKept;

  /// The signer declined to authorize the removal of the media.
  final String? mediaError;

  const DeletionReport({
    this.failure,
    this.detail,
    this.friendsAsked = 0,
    this.friendsReached = 0,
    this.mediaLeft = const [],
    this.mediaKept = 0,
    this.mediaError,
  });

  bool get ok => failure == null;

  /// Everything that could be asked was done and answered.
  bool get complete =>
      ok &&
      mediaLeft.isEmpty &&
      mediaError == null &&
      friendsReached >= friendsAsked;
}

/// What happened to the files of a post.
class _MediaOutcome {
  final List<String> left;
  final String? error;
  const _MediaOutcome({this.left = const [], this.error});
}

/// The files of one or more posts, by Blossom address.
class _PostFiles {
  /// File address → the servers the post's URLs for it point at. Those are
  /// the servers that hold the file for certain; an empty set is a file only
  /// declared (`x`), whose server is not known.
  final Map<String, Set<String>> origins = {};

  /// Hosts of URLs that are not Blossom addresses: nothing can be asked of
  /// them.
  final Set<String> unaddressed = {};

  _PostFiles(Iterable<MediaPost> posts) {
    for (final post in posts) {
      for (final item in post.media) {
        _addItem(item);
      }
    }
  }

  void _addItem(MediaItem item) {
    for (final url in [item.url, ?item.previewUrl, ...item.fallbackUrls]) {
      _add(url);
    }
    final declared = item.sha256?.toLowerCase();
    if (declared != null && isBlobHash(declared)) {
      origins.putIfAbsent(declared, () => {});
    }
  }

  void _add(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || uri.host.isEmpty) return;
    final hash = blobHashOfUrl(url);
    if (hash == null) {
      unaddressed.add(uri.host);
      return;
    }
    origins.putIfAbsent(hash, () => {}).add(originOf(uri));
  }

  /// Every host that holds, or is said to hold, a file of the post.
  Set<String> get hosts => {
    for (final servers in origins.values) ...servers.map(hostOf),
    ...unaddressed,
  };

  /// `https://host[:port]`, the way [BlossomClient] names a server.
  static String originOf(Uri uri) => Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
  ).toString();

  static String hostOf(String origin) => Uri.parse(origin).host;
}

/// Takes a post back: the deletion request to the relays (NIP-09), the notice
/// to the friends of a close-friends post, and the removal of its photos and
/// videos from the media servers (BUD-02).
///
/// Nothing here can force anything: a relay may ignore the request, someone
/// may have saved the file. What it does is ask everyone who holds a copy, and
/// make sure this device never shows the post again ([deletedPostsProvider]).
class PostDeletion {
  final Ref _ref;
  PostDeletion(this._ref);

  /// Deletes [post], which must be the signed-in account's own.
  Future<DeletionReport> delete(MediaPost post) async {
    final auth = _ref.read(authProvider);
    final me = auth.publicKey;
    if (me == null || post.author != me || !auth.signer.canSign) {
      return const DeletionReport(failure: DeletionFailure.notAllowed);
    }
    try {
      return await (post.isPrivate
          ? _deletePrivate(post, auth.signer)
          : _deletePublic(post, auth.signer, me));
    } catch (e) {
      return DeletionReport(failure: DeletionFailure.failed, detail: '$e');
    }
  }

  Future<DeletionReport> _deletePublic(
    MediaPost post,
    Signer signer,
    String me,
  ) async {
    final request = await _requestDeletion([post], signer);
    if (request.failure != null) {
      return DeletionReport(failure: request.failure, detail: request.detail);
    }
    _forget(post);
    // The files go last: had the request failed, the post would still be
    // there, with its pictures gone.
    return _removePublicMedia([post], signer, me);
  }

  /// One NIP-09 request naming all of [posts] (the standard allows many `e`
  /// tags), signed once and sent to every relay the pool knows, those it only
  /// reads from as well: the post may have travelled further than where it
  /// was published.
  Future<({DeletionFailure? failure, String? detail})> _requestDeletion(
    List<MediaPost> posts,
    Signer signer,
  ) async {
    final NostrEvent request;
    try {
      request = await signer.signEvent(
        kind: NostrKinds.deletion,
        tags: [
          for (final post in posts) ['e', post.id],
          for (final post in posts)
            if (_addressOf(post) case final address?) ['a', address],
          for (final kind in {for (final post in posts) post.kind})
            ['k', '$kind'],
        ],
        content: '',
      );
    } on SignerException catch (e) {
      return (failure: DeletionFailure.signerRefused, detail: e.message);
    }
    final pool = _ref.read(relayPoolProvider);
    final report = await pool.publish(request, extraRelays: pool.readRelays);
    if (!report.publishedSomewhere) {
      return (
        failure: DeletionFailure.noRelayAccepted,
        detail: report.firstFailureReason,
      );
    }
    return (failure: null, detail: null);
  }

  /// Takes the files of [posts] down from the media servers, apart from those
  /// another post of the account still shows.
  Future<DeletionReport> _removePublicMedia(
    List<MediaPost> posts,
    Signer signer,
    String me,
  ) async {
    final files = _PostFiles(posts);
    try {
      final inUse = await _usedByOtherPosts({for (final p in posts) p.id}, me);
      final owned = {
        for (final hash in files.origins.keys)
          if (!inUse.contains(hash)) hash: signer,
      };
      final outcome = await _removeFiles(files, owned, keep: inUse);
      return DeletionReport(
        mediaLeft: outcome.left,
        mediaKept: files.origins.keys.where(inUse.contains).length,
        mediaError: outcome.error,
      );
    } catch (e) {
      // The post is deleted; only its files could not be looked after.
      return DeletionReport(
        mediaLeft: files.hosts.toList()..sort(),
        mediaError: '$e',
      );
    }
  }

  Future<DeletionReport> _deletePrivate(MediaPost post, Signer signer) async {
    final me = post.author;
    final rumor = Rumor.create(
      pubkey: me,
      kind: NostrKinds.deletion,
      tags: [
        ['e', post.id],
        ['k', '${post.kind}'],
      ],
      content: '',
    );
    // A close-friends post lives in gift wraps signed by throw-away keys, so
    // no relay can be told to delete them. The friends' apps are told
    // instead, inside a wrap of their own. This also drops the post here.
    final friends = {
      for (final p in post.recipients)
        if (p != me) p,
    };
    final DeliveryReport delivery;
    try {
      delivery = await _ref.read(privateDeliveryProvider).send(rumor, friends);
    } on DmException catch (e) {
      return DeletionReport(
        failure: DeletionFailure.signerRefused,
        detail: e.message,
      );
    } on SignerException catch (e) {
      return DeletionReport(
        failure: DeletionFailure.signerRefused,
        detail: e.message,
      );
    }
    _forget(post);

    return _removePrivateMedia(
      [post],
      friendsAsked: friends.length,
      friendsReached: delivery.delivered.length,
    );
  }

  /// Takes the encrypted files of close-friends [posts] down, with the one-off
  /// keys that uploaded them (no signer is asked: they are on the phone).
  Future<DeletionReport> _removePrivateMedia(
    List<MediaPost> posts, {
    int friendsAsked = 0,
    int friendsReached = 0,
  }) async {
    final files = _PostFiles(posts);
    try {
      final store = _ref.read(uploadKeysProvider);
      final keys = await store.keysFor(files.origins.keys);
      final byKey = <String, Signer>{};
      final owned = {
        for (final entry in keys.entries)
          entry.key: byKey.putIfAbsent(
            entry.value,
            () => NsecSigner.fromNsec(entry.value),
          ),
      };
      final outcome = await _removeFiles(files, owned);
      // The one-time keys of files that are gone are of no more use.
      if (outcome.left.isEmpty && outcome.error == null) {
        await store.forget(keys.keys);
      }
      return DeletionReport(
        friendsAsked: friendsAsked,
        friendsReached: friendsReached,
        mediaLeft: outcome.left,
        mediaError: outcome.error,
      );
    } catch (e) {
      return DeletionReport(
        friendsAsked: friendsAsked,
        friendsReached: friendsReached,
        mediaLeft: files.hosts.toList()..sort(),
        mediaError: '$e',
      );
    }
  }

  /// `kind:pubkey:d` for the addressable video kinds, null for the others.
  static String? _addressOf(MediaPost post) {
    final addressable =
        post.kind == NostrKinds.addressableVideo ||
        post.kind == NostrKinds.addressableShortVideo;
    final d = post.event.firstTagValue('d');
    return addressable && d != null ? '${post.kind}:${post.author}:$d' : null;
  }

  /// The post is gone from this device: out of every list, and out of the
  /// saved ones.
  void _forget(MediaPost post) {
    _ref.read(deletedPostsProvider.notifier).add([post.id]);
    final saved = _ref.read(bookmarksProvider.notifier);
    if (saved.isSaved(post.id)) unawaited(saved.toggle(post.id));
  }

  /// Files that a post of [me] other than [excluded] still shows (the same
  /// photo, posted twice, is one file), or that their profile uses. Content is addressed by
  /// its hash, so taking such a file down would break that post as well.
  Future<Set<String>> _usedByOtherPosts(Set<String> excluded, String me) async {
    final used = <String>{};
    void note(MediaPost other) {
      if (!excluded.contains(other.id)) {
        used.addAll(_PostFiles([other]).origins.keys);
      }
    }

    final gone = _ref.read(deletedPostsProvider);
    final now = _ref.read(unixClockProvider)();
    final profile = await _profileOf(me);
    for (final url in [?profile?.picture, ?profile?.banner]) {
      if (blobHashOfUrl(url) case final hash?) used.add(hash);
    }
    final sub = _ref.read(relayPoolProvider).subscribe([
      NostrFilter(kinds: NostrKinds.mediaKinds, authors: [me], limit: 300),
    ], eoseTimeout: const Duration(seconds: 8));
    final listener = sub.events.listen((event) {
      final other = MediaPost.tryParse(event);
      // A post that has expired is not shown any more, though a relay that
      // ignores NIP-40 may still hand it out: its files are not in use.
      final shown =
          other != null && !gone.contains(other.id) && !other.isExpired(now);
      if (shown) note(other);
    });
    await sub.eose;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    await listener.cancel();
    sub.close();
    return used;
  }

  /// The account's profile, from what is known or else from the relays.
  Future<ProfileMetadata?> _profileOf(String pubkey) async {
    final known = _ref.read(profileProvider(pubkey));
    if (known != null) return known;
    try {
      final fetch = _ref.read(profileMetadataProvider(pubkey).future);
      return await fetch.timeout(const Duration(seconds: 4));
    } catch (_) {
      return null; // go on without it
    }
  }

  /// Asks the servers to delete the files in [owner] (address → the signer
  /// that may delete it), and works out where something is left. Files in
  /// [keep] are meant to stay: they are neither deleted nor reported.
  Future<_MediaOutcome> _removeFiles(
    _PostFiles files,
    Map<String, Signer> owner, {
    Set<String> keep = const {},
  }) async {
    final left = <String>{...files.unaddressed};
    // A file nobody here can delete stays where it is.
    for (final entry in files.origins.entries) {
      if (!owner.containsKey(entry.key) && !keep.contains(entry.key)) {
        left.addAll(entry.value.map(_PostFiles.hostOf));
      }
    }
    final byOwner = <Signer, List<String>>{};
    for (final entry in owner.entries) {
      if (files.origins.containsKey(entry.key)) {
        byOwner.putIfAbsent(entry.value, () => []).add(entry.key);
      }
    }
    final blossom = _ref.read(blossomClientProvider);
    String? error;
    for (final entry in byOwner.entries) {
      final hashes = entry.value;
      try {
        final results = await blossom.delete(
          signer: entry.key,
          hashes: hashes,
          extraServers: [for (final h in hashes) ...files.origins[h]!],
        );
        left.addAll(_unconfirmed(files, hashes, results));
      } on SignerException catch (e) {
        error = e.message;
        for (final hash in hashes) {
          left.addAll(files.origins[hash]!.map(_PostFiles.hostOf));
        }
      }
    }
    return _MediaOutcome(left: left.toList()..sort(), error: error);
  }

  /// Hosts that hold [hashes] for certain (the post points at them) and did
  /// not confirm the file is gone. A server the post does not point at only
  /// ever got the request as a courtesy: its refusal proves nothing.
  static Iterable<String> _unconfirmed(
    _PostFiles files,
    List<String> hashes,
    List<BlossomDeleteResult> results,
  ) sync* {
    for (final hash in hashes) {
      for (final origin in files.origins[hash]!) {
        final answers = results.where(
          (r) => r.hash == hash && _sameServer(r.server, origin),
        );
        // Not asked at all (not https): the file is still there.
        if (answers.isEmpty || answers.any((r) => !r.gone)) {
          yield _PostFiles.hostOf(origin);
        }
      }
    }
  }

  static bool _sameServer(String a, String b) =>
      a.toLowerCase() == b.toLowerCase();
}

final postDeletionProvider = Provider<PostDeletion>(PostDeletion.new);

/// The pieces of a deletion for the cleanup of expired stories (see
/// `StoryCleanup`): the same requests, in batches, with no screen, no notice
/// to friends (their apps let go of an expired story by themselves) and no
/// tombstone (an expired story is not shown any more).
class ExpiredDeletion {
  final Ref _ref;
  ExpiredDeletion(this._ref);

  PostDeletion get _deletion => _ref.read(postDeletionProvider);

  /// Asks every relay to delete [posts], all of them public and the signed-in
  /// account's own, with a single request.
  Future<DeletionReport> requestRelays(List<MediaPost> posts) =>
      _asOwner(posts, (signer, _) async {
        final request = await _deletion._requestDeletion(posts, signer);
        return DeletionReport(failure: request.failure, detail: request.detail);
      });

  /// Asks the media servers to delete the files of the public [posts], apart
  /// from those another post still shows.
  Future<DeletionReport> removePublicMedia(List<MediaPost> posts) => _asOwner(
    posts,
    (signer, me) => _deletion._removePublicMedia(posts, signer, me),
  );

  /// Asks the media servers to delete the encrypted files of close-friends
  /// [posts], with the keys that uploaded them. Needs no signer.
  Future<DeletionReport> removePrivateMedia(List<MediaPost> posts) =>
      _asOwner(posts, (_, _) => _deletion._removePrivateMedia(posts));

  /// Runs [step] when every one of [posts] is the signed-in account's own.
  Future<DeletionReport> _asOwner(
    List<MediaPost> posts,
    Future<DeletionReport> Function(Signer signer, String me) step,
  ) async {
    final auth = _ref.read(authProvider);
    final me = auth.publicKey;
    if (me == null || posts.any((p) => p.author != me)) {
      return const DeletionReport(failure: DeletionFailure.notAllowed);
    }
    try {
      return await step(auth.signer, me);
    } catch (e) {
      return DeletionReport(failure: DeletionFailure.failed, detail: '$e');
    }
  }
}

final expiredDeletionProvider = Provider<ExpiredDeletion>(ExpiredDeletion.new);
