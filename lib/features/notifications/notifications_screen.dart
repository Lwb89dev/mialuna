import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/relay_pool.dart';
import '../../core/nostr/zap_service.dart';
import '../../l10n/strings.dart';
import '../profile/profile_widgets.dart';
import '../social/moderation_controller.dart';

class NotificationItem {
  final NostrEvent event;
  final String kind; // 'reaction' | 'comment' | 'follow'
  const NotificationItem(this.event, this.kind);
}

/// Reactions, comments and new followers addressed to the current user.
/// Counts reflect only what the configured relays return.
class NotificationsController extends Notifier<List<NotificationItem>> {
  StreamSubscription? _sub;
  PoolSubscription? _poolSub;
  final Set<String> _seen = {};

  @override
  List<NotificationItem> build() {
    ref.onDispose(() {
      _sub?.cancel();
      _poolSub?.close();
    });
    _seen.clear();
    final pub = ref.watch(authProvider).publicKey;
    if (pub != null) _start(pub);
    return const [];
  }

  void _start(String pubkey) {
    final pool = ref.read(relayPoolProvider);
    final poolSub = pool.subscribe([
      NostrFilter(
        kinds: const [
          NostrKinds.reaction,
          NostrKinds.comment,
          NostrKinds.zapReceipt,
        ],
        tagFilters: {
          '#p': [pubkey],
        },
        limit: 100,
      ),
      NostrFilter(
        kinds: const [NostrKinds.followList],
        tagFilters: {
          '#p': [pubkey],
        },
        limit: 20,
      ),
    ]);
    _poolSub = poolSub;
    _sub = poolSub.events.listen((event) {
      if (_seen.contains(event.id) || event.pubkey == pubkey) return;
      if (ref.read(blockProvider).contains(event.pubkey)) return;
      _seen.add(event.id);
      final kind = switch (event.kind) {
        NostrKinds.reaction => 'reaction',
        NostrKinds.comment => 'comment',
        NostrKinds.zapReceipt => 'zap',
        _ => 'follow',
      };
      state = ([NotificationItem(event, kind), ...state]
        ..sort((a, b) => b.event.createdAt.compareTo(a.event.createdAt)));
    });
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsController, List<NotificationItem>>(
      NotificationsController.new,
    );

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(notificationsProvider);
    final theme = Theme.of(context);
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
                      final (icon, text) = switch (n.kind) {
                        'reaction' => (
                          Icons.favorite,
                          context.l10n.reactedToYourMoment,
                        ),
                        'comment' => (
                          Icons.chat_bubble_outline,
                          context.l10n.commentedText(n.event.content),
                        ),
                        'zap' => () {
                          final receipt = ZapReceipt.fromEvent(n.event);
                          return (
                            Icons.bolt,
                            receipt != null
                                ? context.l10n.sentYouSats(
                                    receipt.amountSats,
                                    receipt.comment.isNotEmpty
                                        ? ': ${receipt.comment}'
                                        : '',
                                  )
                                : context.l10n.sentYouZap,
                          );
                        }(),
                        _ => (
                          Icons.person_add_alt,
                          context.l10n.startedFollowingYou,
                        ),
                      };
                      final receipt = n.kind == 'zap'
                          ? ZapReceipt.fromEvent(n.event)
                          : null;
                      final sender = receipt?.sender ?? n.event.pubkey;
                      return ListTile(
                        leading: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ProfileAvatar(pubkey: sender, radius: 22),
                            Positioned(
                              right: -4,
                              bottom: -4,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: theme.colorScheme.surface,
                                child: Icon(
                                  icon,
                                  size: 13,
                                  color: theme.colorScheme.secondary,
                                ),
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
                                  pubkey: sender,
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
                          DateTime.fromMillisecondsSinceEpoch(
                            n.event.createdAt * 1000,
                          ).toLocal().toString().substring(0, 16),
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
