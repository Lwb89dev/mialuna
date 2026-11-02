import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/relay_pool.dart';
import '../../core/nostr/zap_service.dart';
import '../../core/notify/system_notifier.dart';
import '../../l10n/strings.dart';
import '../social/moderation_controller.dart';
import '../trust/web_of_trust_controller.dart';
import 'system_notifications.dart';

enum NotificationKind { reaction, comment, zap, follow }

class NotificationItem {
  final NostrEvent event;
  final NotificationKind kind;

  /// The person it is about: whoever reacted, commented, followed or — for a
  /// zap — paid (the receipt itself is signed by the wallet service).
  final String actor;
  final ZapReceipt? zap;

  /// False for a follower Mialuna already told the user about: Nostr clients
  /// republish their whole follow list for any change, which must not look
  /// like a new follower every time.
  final bool isNew;

  const NotificationItem({
    required this.event,
    required this.kind,
    required this.actor,
    this.zap,
    this.isNew = true,
  });

  int get createdAt => event.createdAt;
}

class NotificationsState {
  /// Newest first.
  final List<NotificationItem> items;

  /// Everything up to this time (seconds) was seen on the notifications
  /// screen; only later items are unread.
  final int seenUpTo;

  const NotificationsState({this.items = const [], this.seenUpTo = 0});

  bool isUnread(NotificationItem n) => n.isNew && n.createdAt > seenUpTo;

  int get unreadCount => items.where(isUnread).length;

  NotificationsState copyWith({List<NotificationItem>? items, int? seenUpTo}) =>
      NotificationsState(
        items: items ?? this.items,
        seenUpTo: seenUpTo ?? this.seenUpTo,
      );
}

/// Reactions, comments, zaps and new followers addressed to the signed-in
/// user, and how many of them have not been looked at yet.
///
/// It lives for the whole session (Home watches the unread count for the
/// bell), not just while the notifications screen is open. What was already
/// there the first time this account used the device counts as seen. Counts
/// reflect only what the configured relays return.
class NotificationsController extends Notifier<NotificationsState> {
  static const _maxItems = 200;
  static const _maxFollowers = 2000;

  final Map<String, NotificationItem> _byId = {};
  final Map<String, NotificationItem> _follows = {};
  final Set<String> _knownFollowers = {};
  StreamSubscription<NostrEvent>? _listener;
  PoolSubscription? _poolSub;
  bool _publishQueued = false;
  bool _firstRun = false;

  /// The stored events have been delivered: what arrives from now on is news,
  /// and may deserve a notification on the phone.
  bool _live = false;
  String? _pub;
  int _generation = 0;

  String get _file => 'notifications_$_pub.json';

  @override
  NotificationsState build() {
    final generation = ++_generation;
    ref.onDispose(() {
      _generation++;
      _listener?.cancel();
      _poolSub?.close();
    });
    _listener?.cancel();
    _poolSub?.close();
    _byId.clear();
    _follows.clear();
    _knownFollowers.clear();
    _live = false;
    // Someone you block or mute disappears from the list, and from the count.
    ref.listen(blockProvider, (_, _) => _publish());
    ref.listen(muteProvider, (_, _) => _publish());
    ref.listen(trustFilterProvider, (_, _) => _publish());

    final pub = ref.watch(authProvider.select((a) => a.publicKey));
    _pub = pub;
    if (pub != null) {
      Future.microtask(() {
        if (generation == _generation) _start(pub, generation);
      });
    }
    return const NotificationsState();
  }

  static int _now() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  Future<void> _start(String pub, int generation) async {
    final seen = await _loadLocal();
    if (generation != _generation) return;
    state = state.copyWith(seenUpTo: seen);

    final poolSub = ref.read(relayPoolProvider).subscribe([
      NostrFilter(
        kinds: const [
          NostrKinds.reaction,
          NostrKinds.comment,
          NostrKinds.zapReceipt,
        ],
        tagFilters: {
          '#p': [pub],
        },
        limit: 100,
      ),
      NostrFilter(
        kinds: const [NostrKinds.followList],
        tagFilters: {
          '#p': [pub],
        },
        limit: 40,
      ),
    ]);
    _poolSub = poolSub;
    _listener = poolSub.events.listen((e) {
      if (generation == _generation) _ingest(e, pub);
    });
    await poolSub.eose;
    // Relays often deliver their last events right after EOSE.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (generation != _generation) return;
    _live = true;
    if (!_firstRun) return;
    // First time on this device: the followers who are already there are not
    // new, whatever date their follow list carries.
    _firstRun = false;
    _knownFollowers.addAll(_follows.keys);
    _publish();
    _saveLocal(state.seenUpTo);
  }

  /// Persisted per account: when the notifications were last looked at and
  /// the followers already announced. Returns the "seen up to" time.
  Future<int> _loadLocal() async {
    final json = await ref.read(localCacheProvider).readJson(_file);
    if (json is Map && json['seen'] is num) {
      for (final f in (json['followers'] as List? ?? const [])) {
        _knownFollowers.add('$f');
      }
      return (json['seen'] as num).toInt();
    }
    _firstRun = true;
    final now = _now();
    _saveLocal(now);
    return now;
  }

  void _saveLocal(int seen) {
    if (_pub == null) return;
    final followers = _knownFollowers.toList();
    ref.read(localCacheProvider).writeJson(_file, {
      'seen': seen,
      'followers': followers.length > _maxFollowers
          ? followers.sublist(followers.length - _maxFollowers)
          : followers,
    });
  }

  void _ingest(NostrEvent event, String me) {
    if (event.pubkey == me) return;
    final NotificationItem item;
    switch (event.kind) {
      case NostrKinds.reaction:
        // NIP-25: "-" is a dislike, not something to be notified about.
        if (event.content == '-') return;
        item = NotificationItem(
          event: event,
          kind: NotificationKind.reaction,
          actor: event.pubkey,
        );
      case NostrKinds.comment:
        item = NotificationItem(
          event: event,
          kind: NotificationKind.comment,
          actor: event.pubkey,
        );
      case NostrKinds.zapReceipt:
        final zap = ZapReceipt.fromEvent(event);
        item = NotificationItem(
          event: event,
          kind: NotificationKind.zap,
          actor: zap?.sender ?? event.pubkey,
          zap: zap,
        );
      case NostrKinds.followList:
        // A follow list is replaceable: keep one entry per follower.
        final prev = _follows[event.pubkey];
        if (prev != null && prev.createdAt >= event.createdAt) return;
        final follower = NotificationItem(
          event: event,
          kind: NotificationKind.follow,
          actor: event.pubkey,
          isNew: !_knownFollowers.contains(event.pubkey),
        );
        _follows[event.pubkey] = follower;
        _publish();
        _announce(follower);
        return;
      default:
        return;
    }
    if (_byId.containsKey(event.id)) return;
    _byId[event.id] = item;
    _publish();
    _announce(item);
  }

  /// Whether [n] is shown to the user at all (not from somebody blocked or
  /// muted, and — with the web of trust on — not from a stranger, except a
  /// new follower, who is a stranger by definition).
  bool _shows(NotificationItem n) =>
      !ref.read(blockProvider).contains(n.actor) &&
      !ref.read(muteProvider).contains(n.actor) &&
      (n.kind == NotificationKind.follow ||
          ref.read(trustFilterProvider).allows(n.actor));

  /// Tells the phone about news that is unread and visible. Never about
  /// what was already waiting when the app started.
  void _announce(NotificationItem n) {
    if (!_live || !_shows(n) || !state.isUnread(n)) return;
    final generation = _generation;
    unawaited(() async {
      final name = await displayNameOf(ref, n.actor);
      if (generation != _generation) return;
      final l10n = AppStrings.current;
      final zap = n.zap;
      final body = switch (n.kind) {
        NotificationKind.reaction => l10n.reactedToYourMoment,
        NotificationKind.comment => l10n.commentedText(_clip(n.event.content)),
        NotificationKind.zap =>
          zap == null
              ? l10n.sentYouZap
              : l10n.sentYouSats(
                  zap.amountSats,
                  zap.comment.isEmpty ? '' : ': ${_clip(zap.comment)}',
                ),
        NotificationKind.follow => l10n.startedFollowingYou,
      };
      await ref
          .read(systemNotificationsProvider)
          .post(
            SystemNotification(
              channel: NotifyChannel.social,
              id: notificationIdFor(n.event.id),
              title: name,
              body: body,
              publicTitle: 'Mialuna',
              publicBody: l10n.systemNotificationNew,
              route: 'notifications',
            ),
          );
    }());
  }

  static String _clip(String text) {
    final t = text.trim();
    return t.length <= 140 ? t : '${t.substring(0, 139)}…';
  }

  /// Rebuilds the visible list. Coalesced: a relay delivering a hundred
  /// events at once produces a single state change.
  void _publish() {
    if (_publishQueued) return;
    _publishQueued = true;
    final generation = _generation;
    scheduleMicrotask(() {
      _publishQueued = false;
      if (generation != _generation) return;
      final items = [
        for (final n in [..._byId.values, ..._follows.values])
          if (_shows(n)) n,
      ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = state.copyWith(
        items: items.length > _maxItems ? items.sublist(0, _maxItems) : items,
      );
    });
  }

  /// The user has looked at the list: nothing is unread any more.
  void markAllSeen() {
    if (state.unreadCount == 0) return;
    final newest = state.items.isEmpty ? 0 : state.items.first.createdAt;
    final seen = math.max(_now(), newest);
    for (final n in state.items) {
      if (n.kind == NotificationKind.follow) _knownFollowers.add(n.actor);
    }
    state = state.copyWith(seenUpTo: seen);
    _saveLocal(seen);
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsController, NotificationsState>(
      NotificationsController.new,
    );
