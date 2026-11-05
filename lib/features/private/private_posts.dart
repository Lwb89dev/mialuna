import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/models/comment.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/nip59.dart';
import '../social/deleted_posts.dart';
import '../stories/story_cleanup.dart';
import '../trust/web_of_trust_controller.dart';

/// What a close-friends post gathered: likes and private replies, all of
/// them delivered to the author inside gift wraps — never on a public relay.
class PrivateInteractions {
  final Set<String> likers;
  final List<Comment> replies;
  final Map<String, Set<String>> commentLikers;
  const PrivateInteractions({
    this.likers = const {},
    this.replies = const [],
    this.commentLikers = const {},
  });
}

class PrivatePostsState {
  /// Close-friends posts and stories visible to this account (those sent to
  /// it and its own), newest first, expired stories removed.
  final List<MediaPost> posts;
  final Map<String, PrivateInteractions> interactions;

  const PrivatePostsState({
    this.posts = const [],
    this.interactions = const {},
  });

  PrivateInteractions of(String postId) =>
      interactions[postId] ?? const PrivateInteractions();

  Set<String> commentLikers(String commentId) => {
    for (final interaction in interactions.values)
      ...?interaction.commentLikers[commentId],
  };
}

/// Store of everything that arrives through gift wraps and is a media post
/// (kinds 20/21/22) or a reaction/comment on one (kinds 7/1111). The inbox
/// pump ([DmController]) hands rumors over; they are kept on disk so a
/// message is decrypted once, not at every start.
class PrivatePostsController extends Notifier<PrivatePostsState> {
  static const _maxStored = 600;
  static const _maxInteractions = 3000;
  static const _maxDeletions = 600;

  final Map<String, Rumor> _posts = {};
  final Map<String, Rumor> _interactions = {};

  /// Posts that were taken back, by id, with the account that said so. The
  /// notice can arrive before the post does, and the post must then be let
  /// go as it comes in (provided its author is the one who deleted it).
  final Map<String, String> _deletions = {};
  Timer? _saveTimer;
  Timer? _expiryTimer;
  String? _pub;
  int _generation = 0;

  String get _file => 'private_posts_$_pub.json';

  @override
  PrivatePostsState build() {
    final pub = ref.watch(authProvider.select((a) => a.publicKey));
    final generation = ++_generation;
    ref.onDispose(() {
      _generation++;
      _saveTimer?.cancel();
      _expiryTimer?.cancel();
    });
    ref.listen(trustFilterProvider, (_, _) => _publish());
    _posts.clear();
    _interactions.clear();
    _deletions.clear();
    _pub = pub;
    // Stories disappear by themselves after 24 hours.
    _expiryTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      // Rebuilding the state every minute would redraw every private card.
      if (state.posts.any((p) => p.isExpired(now))) _publish();
    });
    if (pub == null) return const PrivatePostsState();
    Future.microtask(() => _load(generation));
    return const PrivatePostsState();
  }

  /// Offers a decrypted rumor; returns true when it belongs here.
  bool ingest(Rumor rumor) {
    switch (rumor.kind) {
      case NostrKinds.picture || NostrKinds.video || NostrKinds.shortVideo:
        final post = _toPost(rumor);
        if (post == null || post.isExpired()) return false;
        if (_deletions[rumor.id] == rumor.pubkey) return true; // taken back
        if (_posts.containsKey(rumor.id)) return true;
        _posts[rumor.id] = rumor;
        _trackOwnStory(rumor);
        if (_posts.length > _maxStored) {
          final oldest = _posts.values.toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
          _posts.remove(oldest.first.id);
        }
      case NostrKinds.deletion:
        if (!_ingestDeletion(rumor)) return false;
      case NostrKinds.reaction || NostrKinds.comment:
        if (rumor.firstTag('e') == null) return false;
        if (_interactions.containsKey(rumor.id)) return true;
        _interactions[rumor.id] = rumor;
        if (_interactions.length > _maxInteractions) {
          _interactions.remove(_interactions.keys.first);
        }
      default:
        return false;
    }
    _publish();
    _scheduleSave();
    return true;
  }

  /// Your own close-friends story is written down, to be taken down once it
  /// expires: by then it is gone from this store, and its files are not.
  void _trackOwnStory(Rumor rumor) {
    if (rumor.pubkey != _pub) return;
    final post = _toPost(rumor);
    if (post != null && post.isStory) {
      ref.read(storyCleanupProvider.notifier).track(post);
    }
  }

  /// An author takes posts back (NIP-09 inside the gift wrap, so only the
  /// people the post went to ever see it). Only the author of a post can
  /// delete it: a notice naming somebody else's post does nothing.
  bool _ingestDeletion(Rumor rumor) {
    final targets = [
      for (final tag in rumor.tags)
        if (tag.length > 1 && tag[0] == 'e') tag[1],
    ];
    if (targets.isEmpty) return false;
    final dropped = <String>[];
    for (final id in targets) {
      _deletions.remove(id); // newest last
      _deletions[id] = rumor.pubkey;
      if (_dropPost(id, rumor.pubkey)) dropped.add(id);
    }
    while (_deletions.length > _maxDeletions) {
      _deletions.remove(_deletions.keys.first);
    }
    // The lists that already hold the post (Home) let go of it too.
    if (dropped.isNotEmpty) {
      ref.read(deletedPostsProvider.notifier).add(dropped);
    }
    return true;
  }

  /// Forgets post [id] and what it gathered, when [author] wrote it.
  bool _dropPost(String id, String author) {
    final post = _posts[id];
    if (post == null || post.pubkey != author) return false;
    _posts.remove(id);
    _interactions.removeWhere((_, r) => r.firstTag('e') == id);
    return true;
  }

  static MediaPost? _toPost(Rumor rumor) {
    final event = NostrEvent(
      id: rumor.id,
      pubkey: rumor.pubkey,
      createdAt: rumor.createdAt,
      kind: rumor.kind,
      tags: rumor.tags,
      content: rumor.content,
      sig: '', // a rumor is never signed: authorship comes from the seal
    );
    final post = MediaPost.tryParse(event, allowPrivate: true);
    // Only posts meant for a close-friends audience belong in this store.
    if (post == null || !post.isPrivate) return null;
    return post;
  }

  void _publish() {
    final me = _pub;
    final trust = ref.read(trustFilterProvider);
    final posts = <MediaPost>[];
    for (final rumor in _posts.values) {
      final post = _toPost(rumor);
      if (post == null || post.isExpired()) continue;
      // Anybody can gift-wrap a "close friends" post to anybody: with the web
      // of trust on, only those of people you trust reach Home and the rail.
      if (post.author != me && !trust.allows(post.author)) continue;
      posts.add(post);
    }
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final byTarget = <String, List<Rumor>>{};
    for (final r in _interactions.values) {
      final target = r.firstTag('e');
      if (target != null) byTarget.putIfAbsent(target, () => []).add(r);
    }
    final interactions = <String, PrivateInteractions>{};
    for (final post in posts) {
      final raw = byTarget[post.id];
      if (raw == null) continue;
      // Anyone could address a reply to any id: the author sees what
      // friends sent; a friend only sees what they wrote and what the author
      // wrote back.
      bool canSee(Rumor r) =>
          post.author == me || r.pubkey == me || r.pubkey == post.author;
      final visible = [
        for (final r in raw)
          if (canSee(r)) r,
      ];
      final likers = <String>{};
      final replies = <Comment>[];
      for (final r in visible) {
        if (r.kind == NostrKinds.reaction) {
          if (r.content != '-') likers.add(r.pubkey);
        } else {
          final comment = Comment.tryParse(
            NostrEvent(
              id: r.id,
              pubkey: r.pubkey,
              createdAt: r.createdAt,
              kind: r.kind,
              tags: r.tags,
              content: r.content,
              sig: '',
            ),
            forRootId: post.id,
          );
          if (comment != null) replies.add(comment);
        }
      }
      replies.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      interactions[post.id] = PrivateInteractions(
        likers: likers,
        replies: replies,
        commentLikers: {
          for (final comment in replies)
            comment.id: {
              for (final r in byTarget[comment.id] ?? const <Rumor>[])
                if (r.kind == NostrKinds.reaction &&
                    r.content != '-' &&
                    canSee(r))
                  r.pubkey,
            },
        },
      );
    }
    state = PrivatePostsState(posts: posts, interactions: interactions);
  }

  Future<void> _load(int generation) async {
    final json = await ref.read(localCacheProvider).readJson(_file);
    if (generation != _generation || json is! Map) return;
    for (final raw in (json['posts'] as List? ?? const [])) {
      final r = Rumor.tryParse(Map<String, dynamic>.from(raw as Map));
      if (r == null) continue;
      _posts[r.id] = r;
      _trackOwnStory(r);
    }
    for (final raw in (json['interactions'] as List? ?? const [])) {
      final r = Rumor.tryParse(Map<String, dynamic>.from(raw as Map));
      if (r != null) _interactions[r.id] = r;
    }
    final deletions = json['deletions'];
    if (deletions is Map) {
      for (final entry in deletions.entries) {
        final id = entry.key;
        final author = entry.value;
        if (id is! String || author is! String) continue;
        _deletions.putIfAbsent(id, () => author);
        _dropPost(id, author);
      }
    }
    _publish();
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    final generation = _generation;
    _saveTimer = Timer(const Duration(seconds: 2), () {
      if (generation != _generation) return;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      ref.read(localCacheProvider).writeJson(_file, {
        'posts': [
          for (final r in _posts.values)
            if (!_expired(r, now)) r.toJson(),
        ],
        'interactions': [for (final r in _interactions.values) r.toJson()],
        'deletions': _deletions,
      });
    });
  }

  static bool _expired(Rumor r, int now) {
    final post = _toPost(r);
    return post == null || post.isExpired(now);
  }

  /// Forgets everything (logout, "clear cache").
  Future<void> clear() async {
    _posts.clear();
    _interactions.clear();
    _deletions.clear();
    state = const PrivatePostsState();
    await ref.read(localCacheProvider).deleteFile(_file);
  }
}

final privatePostsProvider =
    NotifierProvider<PrivatePostsController, PrivatePostsState>(
      PrivatePostsController.new,
    );
