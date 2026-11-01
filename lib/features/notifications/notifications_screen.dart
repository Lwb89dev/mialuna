import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/zap_service.dart';

class NotificationItem {
  final NostrEvent event;
  final String kind; // 'reaction' | 'comment' | 'follow'
  const NotificationItem(this.event, this.kind);
}

/// Reactions, comments and new followers addressed to the current user.
/// Counts reflect only what the configured relays return.
class NotificationsController extends Notifier<List<NotificationItem>> {
  StreamSubscription? _sub;
  String? _subId;
  final Set<String> _seen = {};

  @override
  List<NotificationItem> build() {
    ref.onDispose(() {
      _sub?.cancel();
      if (_subId != null) ref.read(relayPoolProvider).unsubscribe(_subId!);
    });
    final pub = ref.watch(authProvider).publicKey;
    if (pub != null) _start(pub);
    return const [];
  }

  void _start(String pubkey) {
    final pool = ref.read(relayPoolProvider);
    pool.connect();
    final (:id, :stream) = pool.subscribe([
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
    _subId = id;
    _sub = stream.listen((event) {
      if (_seen.contains(event.id) || event.pubkey == pubkey) return;
      _seen.add(event.id);
      final kind = switch (event.kind) {
        NostrKinds.reaction => 'reaction',
        NostrKinds.comment => 'comment',
        NostrKinds.zapReceipt => 'zap',
        _ => 'follow',
      };
      state = [NotificationItem(event, kind), ...state];
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
      appBar: AppBar(title: const Text('Notifiche')),
      body: items.isEmpty
          ? Center(
              child: Text(
                'Nessuna notifica al momento.',
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
                    'Le notifiche dipendono dai relay: potrebbero non essere complete.',
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
                          'ha reagito a un tuo momento',
                        ),
                        'comment' => (
                          Icons.chat_bubble_outline,
                          'ha commentato: ${n.event.content}',
                        ),
                        'zap' => () {
                          final receipt = ZapReceipt.fromEvent(n.event);
                          return (
                            Icons.bolt,
                            receipt != null
                                ? 'ti ha inviato ${receipt.amountSats} sats'
                                      '${receipt.comment.isNotEmpty ? ': ${receipt.comment}' : ''}'
                                : 'ti ha inviato uno zap',
                          );
                        }(),
                        _ => (Icons.person_add_alt, 'ha iniziato a seguirti'),
                      };
                      final receipt = n.kind == 'zap'
                          ? ZapReceipt.fromEvent(n.event)
                          : null;
                      final sender = receipt?.sender ?? n.event.pubkey;
                      return ListTile(
                        leading: Icon(icon, color: theme.colorScheme.secondary),
                        title: Text(
                          '${sender.substring(0, 8)}… $text',
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
