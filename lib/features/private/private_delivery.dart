import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/models/comment.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/nip59.dart';
import '../../l10n/strings.dart';
import '../messages/dm_controller.dart';
import 'private_posts.dart';

/// Outcome of sending a private post.
class DeliveryReport {
  /// People (other than yourself) whose inbox accepted the wrap.
  final List<String> delivered;

  /// Why somebody did not get it.
  final Map<String, String> failed;

  /// Your own copy (for your other devices) was accepted.
  final bool selfCopy;

  const DeliveryReport({
    this.delivered = const [],
    this.failed = const {},
    this.selfCopy = false,
  });

  bool get reachedSomeone => delivered.isNotEmpty;
}

/// Sends close-friends posts, likes and replies: the same unsigned event
/// wrapped (NIP-59) once per recipient and published only to each
/// recipient's inbox relays. Relays see a wrap from a throw-away key to the
/// recipient — not who wrote it, not what it says, not that it is a post.
class PrivateDelivery {
  /// The reason recorded for somebody who was not sent anything because
  /// `shouldContinue` said no.
  static const _cancelled = 'cancelled';

  final Ref _ref;
  PrivateDelivery(this._ref);

  /// Wraps [rumor] for every pubkey in [recipients] and for yourself.
  /// The post is added to your own store first, so it is on screen at once
  /// even if every relay is down.
  Future<DeliveryReport> send(
    Rumor rumor,
    Iterable<String> recipients, {
    int? expiresAt,
    void Function(int done, int total)? onProgress,

    /// Also wrap it for yourself (your other devices, your own copy). Not
    /// wanted for something only the recipient needs, like a story receipt.
    bool copyToSelf = true,

    /// Asked before every signer round trip and again before a wrap is
    /// handed to a relay; when it answers no, nothing more is sent. A wrap a
    /// relay already accepted cannot be taken back.
    bool Function()? shouldContinue,
  }) async {
    final auth = _ref.read(authProvider);
    final me = auth.publicKey;
    if (me == null || !auth.signer.canEncrypt) {
      throw DmException(AppStrings.current.signInToSendPrivateContent);
    }
    // The seal is signed by whoever is signed in now: a rumor written by
    // somebody else (the account changed while it waited) would be unreadable
    // at best and attributed to the wrong person at worst.
    if (rumor.pubkey != me) {
      throw DmException(AppStrings.current.signInToSendPrivateContent);
    }
    _ref.read(privatePostsProvider.notifier).ingest(rumor);

    final others = <String>{
      for (final r in recipients)
        if (r != me) r,
    }.toList();
    final targets = [...others, if (copyToSelf) me];
    final wrapTags = [
      if (expiresAt != null) ['expiration', '$expiresAt'],
    ];
    final dm = _ref.read(dmProvider.notifier);
    final pool = _ref.read(relayPoolProvider);

    final delivered = <String>[];
    final failed = <String, String>{};
    var selfCopy = false;
    bool cancelled(String pk, bool isMe) {
      if (shouldContinue?.call() ?? true) return false;
      if (!isMe) failed[pk] = _cancelled;
      return true;
    }

    for (var i = 0; i < targets.length; i++) {
      final pk = targets[i];
      onProgress?.call(i, targets.length);
      final isMe = pk == me;
      if (cancelled(pk, isMe)) continue;
      final relays = isMe
          ? _ref.read(dmProvider).inboxRelays
          : await dm.inboxRelaysOf(pk);
      if (!isMe && relays.isEmpty) {
        failed[pk] = AppStrings.current.reasonNoPrivateMessages;
        continue;
      }
      if (cancelled(pk, isMe)) continue;
      final wrap = await GiftWrap.wrap(
        signer: auth.signer,
        rumor: rumor,
        recipient: pk,
        wrapTags: wrapTags,
      );
      // The signer may have taken a while (a dialog in Amber): the sender
      // can have changed their mind, or their account, in the meantime.
      if (cancelled(pk, isMe)) continue;
      final report = await pool.publish(
        wrap,
        extraRelays: relays,
        onlyExtra: relays.isNotEmpty,
      );
      if (report.publishedSomewhere) {
        if (isMe) {
          selfCopy = true;
        } else {
          delivered.add(pk);
        }
      } else if (!isMe) {
        failed[pk] =
            report.firstFailureReason ??
            AppStrings.current.reasonNoRelayAnswered;
      }
    }
    onProgress?.call(targets.length, targets.length);
    return DeliveryReport(
      delivered: delivered,
      failed: failed,
      selfCopy: selfCopy,
    );
  }

  /// A private like: delivered to the author only.
  Future<bool> like(MediaPost post) async {
    final me = _ref.read(authProvider).publicKey;
    if (me == null) return false;
    final rumor = Rumor.create(
      pubkey: me,
      kind: NostrKinds.reaction,
      tags: [
        ['e', post.id],
        ['p', post.author],
        ['k', '${post.kind}'],
      ],
      content: '+',
    );
    if (post.author == me) {
      return _ref.read(privatePostsProvider.notifier).ingest(rumor);
    }
    final report = await send(rumor, [post.author]);
    return report.reachedSomeone;
  }

  /// A private reply: delivered to the author (and the person answered).
  Future<Comment?> reply(
    MediaPost post,
    String text, {
    NostrEvent? parent,
  }) async {
    final me = _ref.read(authProvider).publicKey;
    final body = text.trim();
    if (me == null || body.isEmpty) return null;
    final rumor = Rumor.create(
      pubkey: me,
      kind: NostrKinds.comment,
      tags: Comment.buildTags(rootEvent: post.event, parentComment: parent),
      content: body,
    );
    final to = {post.author, ?parent?.pubkey}..remove(me);
    if (to.isNotEmpty) {
      final report = await send(rumor, to);
      if (!report.reachedSomeone) return null;
    } else {
      _ref.read(privatePostsProvider.notifier).ingest(rumor);
    }
    return Comment.tryParse(
      NostrEvent(
        id: rumor.id,
        pubkey: rumor.pubkey,
        createdAt: rumor.createdAt,
        kind: rumor.kind,
        tags: rumor.tags,
        content: rumor.content,
        sig: '',
      ),
      forRootId: post.id,
    );
  }
}

final privateDeliveryProvider = Provider<PrivateDelivery>(PrivateDelivery.new);
