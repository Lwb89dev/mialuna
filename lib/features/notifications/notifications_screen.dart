import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/strings.dart';
import '../feed/widgets/inline_video.dart';
import '../feed/widgets/nostr_image.dart';
import '../feed/widgets/post_card.dart' show PostScreen, formatPostTime;
import '../profile/profile_widgets.dart';
import 'notifications_controller.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  /// What had been seen when the screen opened: the newer items stay
  /// highlighted for as long as the screen is open, even though they count
  /// as seen from the first frame.
  late final int _seenAtOpen;

  @override
  void initState() {
    super.initState();
    _seenAtOpen = ref.read(notificationsProvider).seenUpTo;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    final items = state.items;
    final theme = Theme.of(context);

    if (state.unreadCount > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(notificationsProvider.notifier).markAllSeen();
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.notifications)),
      body: items.isEmpty
          ? Center(
              child: Text(
                context.l10n.noNotifications,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    context.l10n.notificationsDependOnRelays,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final n = items[i];
                      return _NotificationTile(
                        item: n,
                        highlighted:
                            _seenAtOpen > 0 &&
                            n.isNew &&
                            n.createdAt > _seenAtOpen,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final NotificationItem item;
  final bool highlighted;
  const _NotificationTile({required this.item, required this.highlighted});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final postId = item.postId;
    final post = postId == null
        ? null
        : ref.watch(notificationPostProvider(postId));
    final mediaPost = post?.value;
    final (icon, text) = switch (item.kind) {
      NotificationKind.reaction => (Icons.favorite, l10n.reactedToYourMoment),
      NotificationKind.comment => (
        Icons.chat_bubble_outline,
        l10n.commentedText(item.event.content),
      ),
      NotificationKind.zap => (
        Icons.bolt,
        item.zap != null
            ? l10n.sentYouSats(
                item.zap!.amountSats,
                item.zap!.comment.isNotEmpty ? ': ${item.zap!.comment}' : '',
              )
            : l10n.sentYouZap,
      ),
      NotificationKind.follow => (
        Icons.person_add_alt,
        l10n.startedFollowingYou,
      ),
    };
    return ListTile(
      tileColor: highlighted
          ? theme.colorScheme.secondary.withValues(alpha: 0.12)
          : null,
      onTap: postId == null
          ? null
          : () async {
              final post = await ref.read(
                notificationPostProvider(postId).future,
              );
              if (post != null && context.mounted) {
                await PostScreen.open(context, post);
              }
            },
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          ProfileAvatar(pubkey: item.actor, radius: 22),
          Positioned(
            right: -4,
            bottom: -4,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: theme.colorScheme.surface,
              child: Icon(icon, size: 13, color: theme.colorScheme.secondary),
            ),
          ),
        ],
      ),
      title: Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: AuthorName(
                pubkey: item.actor,
                style: theme.textTheme.titleSmall,
              ),
            ),
            TextSpan(text: ' $text'),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        formatPostTime(item.createdAt),
        style: theme.textTheme.bodySmall,
      ),
      trailing: mediaPost == null
          ? null
          : SizedBox.square(
              dimension: 48,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: mediaPost.media.first.isVideo
                    ? VideoPoster(item: mediaPost.media.first)
                    : NostrImage(
                        item: mediaPost.media.first,
                        preferThumbnail: true,
                      ),
              ),
            ),
    );
  }
}
