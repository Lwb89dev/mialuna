import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/models/comment.dart';
import '../../core/nostr/models/media_event.dart';

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

/// Reactions and comments for a single post, live from the relays.
/// Counts are relay-scoped: they reflect what the configured relays return,
/// not a guaranteed global total.
class InteractionsController
    extends FamilyNotifier<PostInteractions, MediaPost> {
  StreamSubscription? _sub;
  String? _subId;
  final Set<String> _likers = {};
  final Map<String, Comment> _comments = {};

  @override
  PostInteractions build(MediaPost arg) {
    ref.onDispose(() {
      _sub?.cancel();
      if (_subId != null) ref.read(relayPoolProvider).unsubscribe(_subId!);
    });
    _subscribe(arg);
    return const PostInteractions();
  }

  void _subscribe(MediaPost post) {
    final pool = ref.read(relayPoolProvider);
    pool.connect();
    final (:id, :stream) = pool.subscribe([
      NostrFilter(
        kinds: const [NostrKinds.reaction, NostrKinds.comment],
        tagFilters: {
          '#e': [post.id],
        },
        limit: 500,
      ),
    ]);
    _subId = id;
    _sub = stream.listen((event) => _ingest(event, post));
  }

  void _ingest(NostrEvent event, MediaPost post) {
    if (event.kind == NostrKinds.reaction) {
      // Count one reaction per author; content '-' or '' counts as unlike.
      if (event.content == '-') {
        _likers.remove(event.pubkey);
      } else {
        _likers.add(event.pubkey);
      }
    } else if (event.kind == NostrKinds.comment) {
      final comment = Comment.tryParse(event, forRootId: post.id);
      if (comment != null) _comments[comment.id] = comment;
    }
    final myPub = ref.read(authProvider).publicKey;
    final comments = _comments.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    state = PostInteractions(
      likeCount: _likers.length,
      likedByMe: myPub != null && _likers.contains(myPub),
      comments: comments,
    );
  }

  /// Publishes a kind 7 like. No-op for guests.
  Future<bool> like(MediaPost post) async {
    final signer = ref.read(authProvider).signer;
    if (!signer.canSign) return false;
    try {
      final event = await signer.signEvent(
        kind: NostrKinds.reaction,
        tags: buildReactionTags(post.event),
        content: '+',
      );
      final report = await ref.read(relayPoolProvider).publish(event);
      if (report.publishedSomewhere) {
        _likers.add(signer.publicKey!);
        state = PostInteractions(
          likeCount: _likers.length,
          likedByMe: true,
          comments: state.comments,
        );
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Publishes a NIP-22 comment. Returns the new comment on success.
  Future<Comment?> comment(
    MediaPost post,
    String text, {
    NostrEvent? parentComment,
  }) async {
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
      if (report.publishedSomewhere) {
        final comment = Comment.tryParse(event, forRootId: post.id);
        if (comment != null) {
          _comments[comment.id] = comment;
          final comments = _comments.values.toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
          state = PostInteractions(
            likeCount: _likers.length,
            likedByMe: state.likedByMe,
            comments: comments,
          );
        }
        return comment;
      }
    } catch (_) {}
    return null;
  }
}

final interactionsProvider =
    NotifierProvider.family<
      InteractionsController,
      PostInteractions,
      MediaPost
    >(InteractionsController.new);
