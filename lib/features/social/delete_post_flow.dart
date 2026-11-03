import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/nostr/models/media_event.dart';
import '../../l10n/strings.dart';
import 'post_deletion.dart';

/// What to tell the person once a deletion is over: what happened, and what
/// could not be done on top of it.
String deletionMessage(AppLocalizations l10n, DeletionReport report) {
  final failure = report.failure;
  if (failure != null) {
    return switch (failure) {
      DeletionFailure.notAllowed => l10n.deleteNotAllowed,
      DeletionFailure.signerRefused => l10n.deleteFailed(report.detail ?? ''),
      DeletionFailure.noRelayAccepted => l10n.deleteNoRelay,
      DeletionFailure.failed => l10n.deleteFailed(report.detail ?? ''),
    };
  }
  final left = report.mediaLeft.join(', ');
  final missed = report.friendsAsked - report.friendsReached;
  return [
    l10n.postDeleted,
    if (report.mediaError != null)
      l10n.deleteMediaNotAuthorized
    else if (left.isNotEmpty)
      l10n.deleteMediaLeft(left),
    if (missed > 0) l10n.deleteFriendsMissed(missed),
  ].join(' ');
}

/// Asks whether to delete [post], deletes it while a dialog says so, and
/// tells how it went. True when the post was deleted.
///
/// Safe to call from a widget that goes away meanwhile (a card that scrolls
/// off, a screen that closes): everything the end needs is taken first.
Future<bool> confirmAndDeletePost(
  BuildContext context,
  WidgetRef ref,
  MediaPost post,
) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context, rootNavigator: true);
  final service = ref.read(postDeletionProvider);
  final sure = await showDialog<bool>(
    context: context,
    builder: (dialog) => _ConfirmDelete(post: post),
  );
  if (sure != true) return false;

  // The wait can be closed (a signer that never answers must not trap the
  // screen); the deletion carries on and the outcome still comes up.
  var waiting = false;
  if (context.mounted) {
    waiting = true;
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) => _Deleting(l10n.deletingPost),
      ).then((_) => waiting = false),
    );
  }
  DeletionReport report;
  try {
    report = await service.delete(post);
  } catch (e) {
    report = DeletionReport(failure: DeletionFailure.failed, detail: '$e');
  }
  if (waiting && navigator.mounted) navigator.pop();
  if (messenger.mounted) {
    messenger.showSnackBar(
      SnackBar(content: Text(deletionMessage(l10n, report))),
    );
  }
  return report.ok;
}

class _ConfirmDelete extends StatelessWidget {
  final MediaPost post;
  const _ConfirmDelete({required this.post});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(post.isStory ? l10n.deleteStoryTitle : l10n.deletePostTitle),
      content: Text(
        post.isPrivate ? l10n.deletePrivateBody : l10n.deletePostBody,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.deletePost),
        ),
      ],
    );
  }
}

/// The wait. Closing it does not stop the deletion.
class _Deleting extends StatelessWidget {
  final String label;
  const _Deleting(this.label);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        children: [
          const SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
