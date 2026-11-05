import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/models/comment.dart';
import '../../core/nostr/models/media_event.dart';
import '../private/private_delivery.dart';
import '../private/private_posts.dart';
import '../social/interactions_controller.dart';
import '../social/moderation_controller.dart';

class CommentLikes {
  final int count;
  final bool likedByMe;
  const CommentLikes({this.count = 0, this.likedByMe = false});
}

typedef CommentLikeTarget = ({MediaPost post, Comment comment});

class CommentLikesController
    extends AutoDisposeFamilyNotifier<CommentLikes, CommentLikeTarget> {
  @override
  CommentLikes build(CommentLikeTarget arg) {
    final me = ref.watch(authProvider).publicKey;
    if (arg.post.isPrivate) {
      final likers = ref.watch(
        privatePostsProvider.select(
          (state) => state.commentLikers(arg.comment.id),
        ),
      );
      return CommentLikes(
        count: likers.length,
        likedByMe: me != null && likers.contains(me),
      );
    }

    final repo = ref.watch(interactionsRepositoryProvider);
    final blocked = ref.watch(blockProvider);
    final link = ref.keepAlive();
    final keep = Timer(const Duration(minutes: 2), link.close);
    final sub = repo.changes.where((id) => id == arg.comment.id).listen((_) {
      final interactions = repo.snapshot(
        arg.comment.id,
        me: me,
        blocked: blocked,
      );
      state = CommentLikes(
        count: interactions.likeCount,
        likedByMe: interactions.likedByMe,
      );
    });
    ref.onDispose(() {
      keep.cancel();
      link.close();
      sub.cancel();
    });
    repo.requestCommentLikes(arg.comment.id);
    final interactions = repo.snapshot(
      arg.comment.id,
      me: me,
      blocked: blocked,
    );
    return CommentLikes(
      count: interactions.likeCount,
      likedByMe: interactions.likedByMe,
    );
  }

  Future<bool> like() async {
    final comment = arg.comment;
    if (arg.post.isPrivate) {
      return ref.read(privateDeliveryProvider).likeComment(arg.post, comment);
    }
    final signer = ref.read(authProvider).signer;
    final me = signer.publicKey;
    if (!signer.canSign || me == null) return false;
    final repo = ref.read(interactionsRepositoryProvider);
    final pool = ref.read(relayPoolProvider);
    try {
      final existing = repo.reactionOf(comment.id, me);
      if (existing != null && existing.content != '-') {
        final deletion = await signer.signEvent(
          kind: NostrKinds.deletion,
          tags: [
            ['e', existing.id],
            ['k', '${NostrKinds.reaction}'],
          ],
          content: '',
        );
        repo.removeLocalReaction(comment.id, me);
        final report = await pool.publish(deletion);
        if (!report.publishedSomewhere) {
          repo.addLocalReaction(comment.id, existing);
          return false;
        }
        return true;
      }
      final event = await signer.signEvent(
        kind: NostrKinds.reaction,
        tags: buildReactionTags(comment.event),
        content: '+',
      );
      repo.addLocalReaction(comment.id, event);
      final report = await pool.publish(event);
      if (!report.publishedSomewhere) {
        repo.removeLocalReaction(comment.id, me);
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}

final commentLikesProvider = NotifierProvider.autoDispose
    .family<CommentLikesController, CommentLikes, CommentLikeTarget>(
      CommentLikesController.new,
    );
