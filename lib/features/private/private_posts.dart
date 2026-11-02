import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/models/comment.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/nip59.dart';
import '../trust/web_of_trust_controller.dart';

/// What a close-friends post gathered: likes and private replies, all of
/// them delivered to the author inside gift wraps — never on a public relay.
class PrivateInteractions {
  final Set<String> likers;
  final List<Comment> replies;
  const PrivateInteractions({this.likers = const {}, this.replies = const []});
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
}

/// Store of everything that arrives through gift wraps and is a media post
/// (kinds 20/21/22) or a reaction/comment on one (kinds 7/1111). The inbox
/// pump ([DmController]) hands rumors over; they are kept on disk so a
/// message is decrypted once, not at every start.
class PrivatePostsController extends Notifier<PrivatePostsState> {
  static const _maxStored = 600;
  static const _maxInteractions = 3000;

  final Map<String, Rumor> _posts = {};
  final Map<String, Rumor> _interactions = {};
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
        if (_posts.containsKey(rumor.id)) return true;
        _posts[rumor.id] = rumor;
        if (_posts.length > _maxStored) {
          final oldest = _posts.values.toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
          _posts.remove(oldest.first.id);
        }
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
    final byPost = <String, List<Rumor>>{};
    for (final r in _interactions.values) {
      final target = r.firstTag('e');
      if (target != null) byPost.putIfAbsent(target, () => []).add(r);
    }
    final interactions = <String, PrivateInteractions>{};
    for (final post in posts) {
      final raw = byPost[post.id];
      if (raw == null) continue;
      // Anyone could address a reply to any id: the author sees what
      // friends sent; a friend only sees what they wrote and what the author
      // wrote back.
      final visible = post.author == me
          ? raw
          : [
              for (final r in raw)
                if (r.pubkey == me || r.pubkey == post.author) r,
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
      );
    }
    state = PrivatePostsState(posts: posts, interactions: interactions);
  }

  Future<void> _load(int generation) async {
    final json = await ref.read(localCacheProvider).readJson(_file);
    if (generation != _generation || json is! Map) return;
    for (final raw in (json['posts'] as List? ?? const [])) {
      final r = Rumor.tryParse(Map<String, dynamic>.from(raw as Map));
      if (r != null) _posts[r.id] = r;
    }
    for (final raw in (json['interactions'] as List? ?? const [])) {
      final r = Rumor.tryParse(Map<String, dynamic>.from(raw as Map));
      if (r != null) _interactions[r.id] = r;
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
      });
    });
  }

  static bool _expired(Rumor r, int now) {
    for (final t in r.tags) {
      if (t.length > 1 && t[0] == 'expiration') {
        final exp = int.tryParse(t[1]);
        if (exp != null && exp <= now) return true;
      }
    }
    return false;
  }

  /// Forgets everything (logout, "clear cache").
  Future<void> clear() async {
    _posts.clear();
    _interactions.clear();
    state = const PrivatePostsState();
    await ref.read(localCacheProvider).deleteFile(_file);
  }
}

final privatePostsProvider =
    NotifierProvider<PrivatePostsController, PrivatePostsState>(
      PrivatePostsController.new,
    );
