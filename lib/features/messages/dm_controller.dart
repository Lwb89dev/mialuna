import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/nip59.dart';
import '../../core/nostr/relay.dart';
import '../../core/nostr/relay_pool.dart';
import '../../core/nostr/signer.dart';
import '../../core/notify/system_notifier.dart';
import '../../l10n/strings.dart';
import '../notifications/system_notifications.dart';
import '../private/private_posts.dart';
import '../social/moderation_controller.dart';
import '../stories/story_views.dart';
import '../trust/web_of_trust_controller.dart';

/// Relays suggested when a user turns on private messages for the first
/// time (kind 10050). They accept gift wraps without authentication.
const defaultInboxRelays = ['wss://relay.damus.io', 'wss://nos.lol'];

class DmException implements Exception {
  final String message;
  const DmException(this.message);
  @override
  String toString() => message;
}

enum DmStatus { sent, pending, failed }

class DmMessage {
  final String id; // rumor id
  final String peer; // the other person of the conversation
  final bool fromMe;
  final int createdAt;
  final String text;
  final DmStatus status;

  const DmMessage({
    required this.id,
    required this.peer,
    required this.fromMe,
    required this.createdAt,
    required this.text,
    this.status = DmStatus.sent,
  });

  DmMessage copyWith({DmStatus? status}) => DmMessage(
    id: id,
    peer: peer,
    fromMe: fromMe,
    createdAt: createdAt,
    text: text,
    status: status ?? this.status,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'peer': peer,
    'me': fromMe,
    'at': createdAt,
    'text': text,
  };

  static DmMessage? fromJson(Object? json) {
    if (json is! Map) return null;
    try {
      return DmMessage(
        id: json['id'] as String,
        peer: json['peer'] as String,
        fromMe: json['me'] as bool,
        createdAt: (json['at'] as num).toInt(),
        text: json['text'] as String,
      );
    } catch (_) {
      return null;
    }
  }
}

class Conversation {
  final String peer;
  final List<DmMessage> messages; // oldest first

  /// Everything up to this time counts as read: the later of the last time
  /// the conversation was opened and the moment private messages were first
  /// synced on this device (history that predates it is not "new").
  final int lastRead;

  /// Written by somebody outside your web of trust (and never answered by
  /// you): it waits in "message requests" instead of the inbox, and does not
  /// count as unread. Only with the web of trust filter on.
  final bool isRequest;

  const Conversation(
    this.peer,
    this.messages,
    this.lastRead, {
    this.isRequest = false,
  });

  DmMessage? get last => messages.isEmpty ? null : messages.last;
  int get unread =>
      messages.where((m) => !m.fromMe && m.createdAt > lastRead).length;
}

class DmState {
  final Map<String, Conversation> conversations;
  final bool loading;

  /// null while unknown; false when the user has no kind 10050 inbox list.
  final bool? inboxConfigured;
  final List<String> inboxRelays;
  final String? error;
  final bool supported; // signer can encrypt

  const DmState({
    this.conversations = const {},
    this.loading = false,
    this.inboxConfigured,
    this.inboxRelays = const [],
    this.error,
    this.supported = true,
  });

  List<Conversation> _sortedWhere(bool Function(Conversation) test) =>
      conversations.values
          .where((c) => c.messages.isNotEmpty && test(c))
          .toList()
        ..sort((a, b) => b.last!.createdAt.compareTo(a.last!.createdAt));

  /// The inbox: everything except message requests.
  List<Conversation> get sorted => _sortedWhere((c) => !c.isRequest);

  /// Conversations started by people outside your web of trust.
  List<Conversation> get requests => _sortedWhere((c) => c.isRequest);

  int get unreadCount => conversations.values
      .where((c) => !c.isRequest)
      .fold(0, (n, c) => n + c.unread);

  DmState copyWith({
    Map<String, Conversation>? conversations,
    bool? loading,
    bool? inboxConfigured,
    List<String>? inboxRelays,
    String? error,
    bool clearError = false,
    bool? supported,
  }) => DmState(
    conversations: conversations ?? this.conversations,
    loading: loading ?? this.loading,
    inboxConfigured: inboxConfigured ?? this.inboxConfigured,
    inboxRelays: inboxRelays ?? this.inboxRelays,
    error: clearError ? null : (error ?? this.error),
    supported: supported ?? this.supported,
  );
}

/// NIP-17 private messages: gift-wrapped (NIP-59), NIP-44 encrypted chat
/// messages delivered through the recipient's own inbox relays (kind 10050).
class DmController extends Notifier<DmState> {
  static const _fileMax = 3000;

  /// Wrap ids kept in memory: twice what is saved, so a flood of junk wraps
  /// cannot grow it without bound.
  static const _wrapsMax = 2 * _fileMax;
  final Map<String, DmMessage> _messages = {};
  final Set<String> _seenWraps = {};
  final Map<String, int> _lastRead = {};
  final Map<String, List<String>> _inboxCache = {};
  PoolSubscription? _sub;
  Timer? _saveTimer;
  Future<void> _queue = Future.value();
  int _newestWrap = 0;
  int _baseline = 0; // first sync time (seconds); 0 = not synced yet

  /// The inbox has caught up with what was stored: a message that arrives
  /// from now on is news, and may deserve a notification on the phone.
  bool _live = false;
  String? _pub;

  /// Bumped on every rebuild/dispose so work started for a previous account
  /// (or after the provider is gone) quietly stops.
  int _generation = 0;

  String get _file => 'dm_$_pub.json';

  @override
  DmState build() {
    final auth = ref.watch(authProvider);
    final generation = ++_generation;
    ref.onDispose(() {
      _generation++;
      _sub?.close();
      _saveTimer?.cancel();
    });
    ref.listen(trustFilterProvider, (_, _) {
      if (_messages.isNotEmpty) _publishState();
    });
    _messages.clear();
    _seenWraps.clear();
    _lastRead.clear();
    _live = false;
    _baseline = 0;
    _inboxCache.clear();
    _sub?.close();
    _sub = null;
    final pub = auth.publicKey;
    _pub = pub;
    if (pub == null) return const DmState();
    if (!auth.signer.canEncrypt) return const DmState(supported: false);
    Future.microtask(() {
      if (generation == _generation) _start(pub, generation);
    });
    return const DmState(loading: true);
  }

  // ── start-up ────────────────────────────────────────────────────────

  Future<void> _start(String pub, int generation) async {
    await _loadLocal();
    if (generation != _generation) return;
    final inbox = await inboxRelaysOf(pub, force: true);
    if (generation != _generation) return;
    state = state.copyWith(
      inboxConfigured: inbox.isNotEmpty,
      inboxRelays: inbox,
    );
    _subscribe(pub, inbox);
  }

  void _subscribe(String pub, List<String> inbox) {
    final generation = _generation;
    final since = _newestWrap > 0
        ? _newestWrap - 3 * 24 * 3600
        : DateTime.now().millisecondsSinceEpoch ~/ 1000 - 30 * 24 * 3600;
    _sub?.close();
    final sub = ref
        .read(relayPoolProvider)
        .subscribe(
          [
            NostrFilter(
              kinds: const [NostrKinds.giftWrap],
              tagFilters: {
                '#p': [pub],
              },
              since: since < 0 ? 0 : since,
            ),
          ],
          extraRelays: inbox,
          authRequired: true,
          eoseTimeout: const Duration(seconds: 15),
        );
    _sub = sub;
    sub.events.listen((wrap) {
      if (generation != _generation) return;
      _newestWrap = _newestWrap > wrap.createdAt ? _newestWrap : wrap.createdAt;
      _queue = _queue.then((_) {
        if (generation == _generation) return _process(wrap);
      });
    });
    sub.eose.then((_) {
      _queue = _queue.then((_) {
        if (generation != _generation) return;
        if (_baseline == 0) {
          // First sync on this device: what is already there is history.
          _baseline = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          _scheduleSave();
        }
        _publishState(loading: false);
        _live = true;
      });
    });
  }

  Future<void> _process(NostrEvent wrap) async {
    if (_seenWraps.contains(wrap.id)) return;
    final generation = _generation;
    final signer = ref.read(authProvider).signer;
    try {
      final rumor = await GiftWrap.unwrap(signer: signer, wrap: wrap);
      // The account changed (or the app shut down) while decrypting.
      if (generation != _generation) return;
      _seenWraps.add(wrap.id);
      if (_seenWraps.length > _wrapsMax) _seenWraps.remove(_seenWraps.first);
      // Whatever the wrap held — a chat message, a close-friends post, a story
      // receipt, nothing readable — it is not decrypted again after a restart.
      // (Only chat messages used to schedule this, so a session that received
      // nothing but the others asked the signer for the same wraps next time.)
      _scheduleSave();
      if (rumor != null) _addRumor(rumor);
    } on SignerException catch (e) {
      // Another account is signed in by now: this refusal is not theirs.
      if (generation != _generation) return;
      // The signer refused (e.g. Amber request dismissed): stop for now and
      // let the user retry from the inbox.
      state = state.copyWith(error: e.message, loading: false);
      _sub?.close();
    }
  }

  void _addRumor(Rumor rumor) {
    // Close-friends posts, stories and the likes/replies on them share the
    // inbox with chat messages; they have their own store.
    if (rumor.kind == NostrKinds.picture ||
        rumor.kind == NostrKinds.video ||
        rumor.kind == NostrKinds.shortVideo ||
        rumor.kind == NostrKinds.reaction ||
        rumor.kind == NostrKinds.comment) {
      if (ref.read(blockProvider).contains(rumor.pubkey) ||
          ref.read(muteProvider).contains(rumor.pubkey)) {
        return;
      }
      ref.read(privatePostsProvider.notifier).ingest(rumor);
      return;
    }
    // Somebody tells you they watched your stories.
    if (rumor.kind == NostrKinds.storyView) {
      if (ref.read(blockProvider).contains(rumor.pubkey) ||
          ref.read(muteProvider).contains(rumor.pubkey)) {
        return;
      }
      ref.read(storyViewsProvider.notifier).ingest(rumor);
      return;
    }
    if (rumor.kind != NostrKinds.chatMessage &&
        rumor.kind != NostrKinds.fileMessage) {
      return;
    }
    final me = _pub;
    if (me == null) return;
    final fromMe = rumor.pubkey == me;
    final others = <String>{
      for (final t in rumor.tags)
        if (t.length > 1 && t[0] == 'p' && t[1] != me) t[1],
    };
    final String peer;
    if (fromMe) {
      if (others.length != 1) return; // group chats are not supported
      peer = others.first;
    } else {
      if (others.length > 1) return;
      peer = rumor.pubkey;
    }
    if (ref.read(blockProvider).contains(peer) ||
        ref.read(muteProvider).contains(peer)) {
      return;
    }
    if (_messages.containsKey(rumor.id)) return;
    _messages[rumor.id] = DmMessage(
      id: rumor.id,
      peer: peer,
      fromMe: fromMe,
      createdAt: rumor.createdAt,
      text: rumor.content,
    );
    _publishState();
    _scheduleSave();
    if (!fromMe) _announce(peer, rumor.createdAt);
  }

  /// A message from somebody else, unread, in a conversation that is not a
  /// request: the phone is told. Its sender and text never reach the lock
  /// screen: the notification only says that a private message came.
  void _announce(String peer, int createdAt) {
    if (!_live || createdAt <= _readUpTo(peer)) return;
    final conversation = state.conversations[peer];
    if (conversation == null || conversation.isRequest) return;
    final generation = _generation;
    unawaited(() async {
      final name = await displayNameOf(ref, peer);
      if (generation != _generation) return;
      final l10n = AppStrings.current;
      await ref
          .read(systemNotificationsProvider)
          .post(
            SystemNotification(
              channel: NotifyChannel.messages,
              id: notificationIdFor(peer),
              title: name,
              body: l10n.systemNotificationMessage,
              publicTitle: 'Mialuna',
              publicBody: l10n.systemNotificationNewMessage,
              route: 'chat:$peer',
            ),
          );
    }());
  }

  void _publishState({bool? loading}) {
    final byPeer = <String, List<DmMessage>>{};
    for (final m in _messages.values) {
      byPeer.putIfAbsent(m.peer, () => []).add(m);
    }
    final trust = ref.read(trustFilterProvider);
    state = state.copyWith(
      conversations: {
        for (final e in byPeer.entries)
          e.key: Conversation(
            e.key,
            e.value..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
            _readUpTo(e.key),
            // Once you have written to somebody they are no stranger.
            isRequest: !trust.allows(e.key) && !e.value.any((m) => m.fromMe),
          ),
      },
      loading: loading,
    );
  }

  /// Everything up to the returned time counts as read for [peer]. Until the
  /// first sync has finished (`_baseline == 0`) the inbox is still filling up
  /// with history, none of which is new: without this the unread badge would
  /// flash a big number and then vanish.
  int _readUpTo(String peer) {
    if (_baseline == 0) return _everythingRead;
    final read = _lastRead[peer] ?? 0;
    return read > _baseline ? read : _baseline;
  }

  static const _everythingRead = 1 << 50;

  // ── persistence ─────────────────────────────────────────────────────

  Future<void> _loadLocal() async {
    final json = await ref.read(localCacheProvider).readJson(_file);
    if (json is! Map) return;
    for (final raw in (json['messages'] as List? ?? const [])) {
      final m = DmMessage.fromJson(raw);
      if (m != null) _messages[m.id] = m;
    }
    for (final id in (json['wraps'] as List? ?? const [])) {
      _seenWraps.add('$id');
    }
    final reads = json['read'];
    if (reads is Map) {
      reads.forEach((k, v) => _lastRead['$k'] = (v as num).toInt());
    }
    _newestWrap = (json['newest'] as num?)?.toInt() ?? 0;
    _baseline = (json['baseline'] as num?)?.toInt() ?? 0;
    _publishState();
  }

  /// Writes within a couple of seconds, however often it is asked: a request
  /// while one is pending joins it (the file is built when the timer fires),
  /// so a steady stream of wraps cannot keep postponing the write.
  void _scheduleSave() {
    if (_saveTimer?.isActive ?? false) return;
    final generation = _generation;
    _saveTimer = Timer(const Duration(seconds: 2), () {
      if (generation != _generation) return;
      final msgs = _messages.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final wraps = _seenWraps.toList();
      ref.read(localCacheProvider).writeJson(_file, {
        'messages': [for (final m in msgs.take(_fileMax)) m.toJson()],
        'wraps': wraps.length > _fileMax
            ? wraps.sublist(wraps.length - _fileMax)
            : wraps,
        'read': _lastRead,
        'newest': _newestWrap,
        'baseline': _baseline,
      });
    });
  }

  // ── inbox relays ────────────────────────────────────────────────────

  /// Where [pubkey] receives private messages: their kind 10050 relays, or —
  /// for people who never published one — their NIP-65 read relays.
  Future<List<String>> inboxRelaysOf(
    String pubkey, {
    bool force = false,
  }) async {
    if (!force && _inboxCache.containsKey(pubkey)) return _inboxCache[pubkey]!;
    final pool = ref.read(relayPoolProvider);
    final sub = pool.subscribe(
      [
        NostrFilter(
          kinds: const [NostrKinds.dmRelayList],
          authors: [pubkey],
          limit: 3,
        ),
      ],
      extraRelays: ref.read(indexerRelaysProvider),
      eoseTimeout: const Duration(seconds: 6),
    );
    NostrEvent? newest;
    final listener = sub.events.listen((e) {
      if (newest == null || e.createdAt > newest!.createdAt) newest = e;
    });
    await sub.eose;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    await listener.cancel();
    sub.close();

    var relays =
        <String>[
              for (final t in newest?.tags ?? const <List<String>>[])
                if (t.length > 1 && t[0] == 'relay') ?normalizeRelayUrl(t[1]),
            ]
            .where(
              (u) =>
                  isSafeRemoteRelayUrl(u) || pool.relays.any((c) => c.url == u),
            )
            .take(4)
            .toList();
    if (relays.isEmpty && pubkey != _pub) {
      final outbox = ref.read(outboxProvider);
      await outbox.ensure([pubkey]);
      relays = outbox.readRelays(pubkey);
    }
    // "Nothing found" is not remembered: they may publish a list tomorrow, and
    // a retry must be able to see it.
    if (relays.isNotEmpty) _inboxCache[pubkey] = relays;
    return relays;
  }

  /// Turns private messages on: publishes the user's kind 10050 list.
  Future<bool> publishInboxRelays(List<String> relays) async {
    final signer = ref.read(authProvider).signer;
    final pub = _pub;
    if (!signer.canSign || pub == null) return false;
    final clean = [for (final r in relays) ?normalizeRelayUrl(r)];
    if (clean.isEmpty) return false;
    try {
      final event = await signer.signEvent(
        kind: NostrKinds.dmRelayList,
        tags: [
          for (final r in clean) ['relay', r],
        ],
        content: '',
      );
      final report = await ref
          .read(relayPoolProvider)
          .publish(
            event,
            extraRelays: [...ref.read(indexerRelaysProvider), ...clean],
          );
      if (!report.publishedSomewhere) return false;
      _inboxCache[pub] = clean;
      state = state.copyWith(inboxConfigured: true, inboxRelays: clean);
      _subscribe(pub, clean);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── sending ─────────────────────────────────────────────────────────

  /// Sends [text] to [peer]. The message is shown immediately and marked
  /// failed if no relay of the recipient accepts it. Throws [DmException]
  /// only for setup problems the user must fix.
  Future<void> send(String peer, String text) async {
    final signer = ref.read(authProvider).signer;
    final me = _pub;
    final body = text.trim();
    if (me == null || !signer.canEncrypt) {
      throw DmException(AppStrings.current.signInToSendPrivateMessages);
    }
    if (body.isEmpty) return;
    if (peer == me) throw DmException(AppStrings.current.cannotMessageYourself);

    final rumor = Rumor.create(
      pubkey: me,
      kind: NostrKinds.chatMessage,
      tags: [
        ['p', peer],
      ],
      content: body,
    );
    _messages[rumor.id] = DmMessage(
      id: rumor.id,
      peer: peer,
      fromMe: true,
      createdAt: rumor.createdAt,
      text: body,
      status: DmStatus.pending,
    );
    _publishState();

    void mark(DmStatus status) {
      final m = _messages[rumor.id];
      if (m != null) {
        _messages[rumor.id] = m.copyWith(status: status);
        _publishState();
        _scheduleSave();
      }
    }

    try {
      final peerRelays = await inboxRelaysOf(peer);
      if (peerRelays.isEmpty) {
        mark(DmStatus.failed);
        throw DmException(AppStrings.current.recipientNoPrivateMessages);
      }
      final pool = ref.read(relayPoolProvider);
      final toPeer = await GiftWrap.wrap(
        signer: signer,
        rumor: rumor,
        recipient: peer,
      );
      final report = await pool.publish(
        toPeer,
        extraRelays: peerRelays,
        onlyExtra: true,
      );
      if (!report.publishedSomewhere) {
        mark(DmStatus.failed);
        throw DmException(
          AppStrings.current.noRecipientRelayAccepted(
            report.firstFailureReason != null
                ? ' (${report.firstFailureReason})'
                : '',
          ),
        );
      }
      mark(DmStatus.sent);
      // Copy for the sender's own devices (best effort).
      unawaited(() async {
        try {
          final mine = state.inboxRelays;
          final toMe = await GiftWrap.wrap(
            signer: signer,
            rumor: rumor,
            recipient: me,
          );
          await pool.publish(
            toMe,
            extraRelays: mine,
            onlyExtra: mine.isNotEmpty,
          );
        } catch (_) {}
      }());
    } on DmException {
      rethrow;
    } on SignerException catch (e) {
      mark(DmStatus.failed);
      throw DmException(e.message);
    } catch (e) {
      mark(DmStatus.failed);
      throw DmException(AppStrings.current.sendFailed(e));
    }
  }

  /// Sends the same message to several people; returns how many succeeded.
  Future<({int sent, List<String> failures})> sendToMany(
    Iterable<String> peers,
    String text,
  ) async {
    var sent = 0;
    final failures = <String>[];
    for (final peer in peers) {
      try {
        await send(peer, text);
        sent++;
      } on DmException catch (e) {
        failures.add(e.message);
      }
    }
    return (sent: sent, failures: failures);
  }

  void markRead(String peer) {
    final conv = state.conversations[peer];
    if (conv == null || conv.last == null) return;
    final latest = conv.last!.createdAt;
    if (conv.lastRead >= latest) return;
    _lastRead[peer] = latest;
    _publishState();
    _scheduleSave();
  }

  /// Restarts the inbox subscription (after a refused signer request).
  Future<void> retry() async {
    final pub = _pub;
    if (pub == null) return;
    state = state.copyWith(loading: true, clearError: true);
    _subscribe(pub, state.inboxRelays);
  }
}

final dmProvider = NotifierProvider<DmController, DmState>(DmController.new);
