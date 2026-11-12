import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/models/comment.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/relay_pool.dart';
import '../private/private_delivery.dart';
import '../private/private_posts.dart';
import '../trust/web_of_trust_controller.dart';
import 'moderation_controller.dart';

class PostInteractions {
  final int likeCount;
  final bool likedByMe;
  final List<Comment> comments;

  const PostInteractions({
    this.likeCount = 0,
    this.likedByMe = false,
    this.comments = const [],
  });
}

class _PostData {
  final Map<String, NostrEvent> reactions = {}; // author -> newest reaction
  final Map<String, Comment> comments = {};
}

/// Reactions and comments for posts, fetched in batches: every post asked
/// for within a short window is covered by a single REQ, so scrolling a feed
/// never opens a subscription per card. Counts are relay-scoped: they
/// reflect what the configured relays return, not a global total.
class InteractionsRepository {
  final RelayPool pool;
  final Map<String, _PostData> _data = {};
  final Set<String> _requested = {};
  final Set<String> _wanted = {};
  final Set<String> _wantedCommentLikes = {};
  final Set<String> _removedReactionIds = {};
  final _changes = StreamController<String>.broadcast();
  Timer? _timer;
  Timer? _commentLikesTimer;
  bool _disposed = false;

  InteractionsRepository(this.pool);

  Stream<String> get changes => _changes.stream;

  void request(String postId) {
    if (_disposed || !_requested.add(postId)) return;
    _data.putIfAbsent(postId, _PostData.new);
    _wanted.add(postId);
    _timer ??= Timer(const Duration(milliseconds: 120), _flush);
  }

  Future<void> _flush() async {
    _timer = null;
    if (_wanted.isEmpty || _disposed) return;
    final batch = _wanted.take(40).toList();
    _wanted.removeAll(batch);
    if (_wanted.isNotEmpty) {
      _timer = Timer(const Duration(milliseconds: 60), _flush);
    }

    final sub = pool.subscribe([
      NostrFilter(
        kinds: const [NostrKinds.reaction],
        tagFilters: {'#e': batch},
        limit: batch.length * 40,
      ),
      NostrFilter(
        kinds: const [NostrKinds.comment],
        tagFilters: {'#E': batch},
        limit: batch.length * 30,
      ),
      NostrFilter(
        kinds: const [NostrKinds.comment],
        tagFilters: {'#e': batch},
        limit: batch.length * 30,
      ),
    ], eoseTimeout: const Duration(seconds: 8));
    final listener = sub.events.listen((e) => ingest(e, batch));
    await sub.eose;
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await listener.cancel();
    sub.close();
  }

  void requestCommentLikes(String commentId) {
    if (_disposed || !_requested.add(commentId)) return;
    _data.putIfAbsent(commentId, _PostData.new);
    _wantedCommentLikes.add(commentId);
    _commentLikesTimer ??= Timer(
      const Duration(milliseconds: 120),
      _flushCommentLikes,
    );
  }

  Future<void> _flushCommentLikes() async {
    _commentLikesTimer = null;
    if (_wantedCommentLikes.isEmpty || _disposed) return;
    final batch = _wantedCommentLikes.take(40).toList();
    _wantedCommentLikes.removeAll(batch);
    if (_wantedCommentLikes.isNotEmpty) {
      _commentLikesTimer = Timer(
        const Duration(milliseconds: 60),
        _flushCommentLikes,
      );
    }
    final sub = pool.subscribe([
      NostrFilter(
        kinds: const [NostrKinds.reaction],
        tagFilters: {'#e': batch},
        limit: batch.length * 40,
      ),
    ], eoseTimeout: const Duration(seconds: 8));
    final listener = sub.events.listen((e) => ingest(e, batch));
    await sub.eose;
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await listener.cancel();
    sub.close();
  }

  void ingest(NostrEvent event, [Iterable<String>? known]) {
    final ids = known ?? _data.keys;
    if (event.kind == NostrKinds.reaction) {
      // NIP-25: the last `e` tag is the reacted-to event.
      String? target;
      for (final t in event.tags) {
        if (t.length >= 2 && t[0] == 'e') target = t[1];
      }
      final data = target == null ? null : _data[target];
      if (data == null || _removedReactionIds.contains(event.id)) return;
      final prev = data.reactions[event.pubkey];
      if (prev != null && prev.createdAt >= event.createdAt) return;
      data.reactions[event.pubkey] = event;
      _changes.add(target!);
    } else if (event.kind == NostrKinds.comment) {
      for (final id in ids) {
        final comment = Comment.tryParse(event, forRootId: id);
        if (comment == null) continue;
        final data = _data[id];
        if (data == null || data.comments.containsKey(comment.id)) return;
        data.comments[comment.id] = comment;
        _changes.add(id);
        return;
      }
    }
  }

  PostInteractions snapshot(
    String postId, {
    String? me,
    Set<String> blocked = const {},

    /// Comments are kept only from accounts this lets through (the web of
    /// trust). Likes are counted from everyone.
    bool Function(String pubkey)? allowCommenter,
  }) {
    final data = _data[postId];
    if (data == null) return const PostInteractions();
    final likers = {
      for (final e in data.reactions.values)
        if (e.content != '-' && !blocked.contains(e.pubkey)) e.pubkey,
    };
    final comments = [
      for (final c in data.comments.values)
        if (!blocked.contains(c.author) &&
            (allowCommenter?.call(c.author) ?? true))
          c,
    ]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return PostInteractions(
      likeCount: likers.length,
      likedByMe: me != null && likers.contains(me),
      comments: comments,
    );
  }

  NostrEvent? reactionOf(String postId, String pubkey) =>
      _data[postId]?.reactions[pubkey];

  void addLocalReaction(String postId, NostrEvent reaction) {
    final data = _data.putIfAbsent(postId, _PostData.new);
    _removedReactionIds.remove(reaction.id);
    data.reactions[reaction.pubkey] = reaction;
    _changes.add(postId);
  }

  void removeLocalReaction(String postId, String pubkey) {
    final removed = _data[postId]?.reactions.remove(pubkey);
    if (removed != null) _removedReactionIds.add(removed.id);
    _changes.add(postId);
  }

  void addLocalComment(String postId, Comment comment) {
    _data.putIfAbsent(postId, _PostData.new).comments[comment.id] = comment;
    _changes.add(postId);
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _commentLikesTimer?.cancel();
    _changes.close();
  }
}

final interactionsRepositoryProvider = Provider<InteractionsRepository>((ref) {
  final repo = InteractionsRepository(ref.read(relayPoolProvider));
  ref.onDispose(repo.dispose);
  return repo;
});

/// View of one post's reactions/comments plus the actions on them.
class InteractionsController extends Notifier<PostInteractions> {
  InteractionsController(this.arg);

  final MediaPost arg;

  @override
  PostInteractions build() {
    final me0 = ref.watch(authProvider).publicKey;
    if (arg.isPrivate) {
      // Close-friends post: likes and replies travel in gift wraps and are
      // read from the private store; nothing is asked of public relays.
      final shared = ref.watch(privatePostsProvider).of(arg.id);
      return PostInteractions(
        likeCount: shared.likers.length,
        likedByMe: me0 != null && shared.likers.contains(me0),
        comments: shared.replies,
      );
    }
    final repo = ref.watch(interactionsRepositoryProvider);
    final blocked = ref.watch(blockProvider);
    final me = ref.watch(authProvider).publicKey;
    final trust = ref.watch(trustFilterProvider);
    // The author of the post may always be heard on it.
    bool allow(String pk) => pk == arg.author || trust.allows(pk);
    // Keep counts for a while after the card leaves the screen, so scrolling
    // back does not flash zeros.
    final link = ref.keepAlive();
    final keep = Timer(const Duration(minutes: 2), link.close);
    final sub = repo.changes.where((id) => id == arg.id).listen((_) {
      state = repo.snapshot(
        arg.id,
        me: me,
        blocked: blocked,
        allowCommenter: allow,
      );
    });
    ref.onDispose(() {
      keep.cancel();
      // A rebuild creates a new link: leaving this one open would keep the
      // provider alive for good.
      link.close();
      sub.cancel();
    });
    repo.request(arg.id);
    return repo.snapshot(
      arg.id,
      me: me,
      blocked: blocked,
      allowCommenter: allow,
    );
  }

  /// Likes the post, or takes the like back (NIP-09 deletion of the
  /// reaction) when it was already liked. Returns false on failure.
  Future<bool> like(MediaPost post) async {
    if (post.isPrivate) {
      return ref.read(privateDeliveryProvider).like(post);
    }
    final signer = ref.read(authProvider).signer;
    final me = signer.publicKey;
    if (!signer.canSign || me == null) return false;
    final repo = ref.read(interactionsRepositoryProvider);
    final pool = ref.read(relayPoolProvider);
    try {
      final existing = repo.reactionOf(post.id, me);
      if (existing != null && existing.content != '-') {
        final deletion = await signer.signEvent(
          kind: NostrKinds.deletion,
          tags: [
            ['e', existing.id],
            ['k', '${NostrKinds.reaction}'],
          ],
          content: '',
        );
        repo.removeLocalReaction(post.id, me);
        final report = await pool.publish(deletion);
        if (!report.publishedSomewhere) {
          repo.addLocalReaction(post.id, existing);
          return false;
        }
        return true;
      }
      final event = await signer.signEvent(
        kind: NostrKinds.reaction,
        tags: buildReactionTags(post.event),
        content: '+',
      );
      repo.addLocalReaction(post.id, event); // optimistic
      final report = await pool.publish(event);
      if (!report.publishedSomewhere) {
        repo.removeLocalReaction(post.id, me);
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Publishes a NIP-22 comment. Returns the new comment on success.
  Future<Comment?> comment(
    MediaPost post,
    String text, {
    NostrEvent? parentComment,
  }) async {
    if (post.isPrivate) {
      return ref
          .read(privateDeliveryProvider)
          .reply(post, text, parent: parentComment);
    }
    final signer = ref.read(authProvider).signer;
    if (!signer.canSign || text.trim().isEmpty) return null;
    try {
      final event = await signer.signEvent(
        kind: NostrKinds.comment,
        tags: Comment.buildTags(
          rootEvent: post.event,
          parentComment: parentComment,
        ),
        content: text.trim(),
      );
      final report = await ref.read(relayPoolProvider).publish(event);
      if (!report.publishedSomewhere) return null;
      final comment = Comment.tryParse(event, forRootId: post.id);
      if (comment != null) {
        ref
            .read(interactionsRepositoryProvider)
            .addLocalComment(post.id, comment);
      }
      return comment;
    } catch (_) {
      return null;
    }
  }
}

final interactionsProvider = NotifierProvider.autoDispose
    .family<InteractionsController, PostInteractions, MediaPost>(
      InteractionsController.new,
    );
