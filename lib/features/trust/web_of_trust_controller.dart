import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/trust/trust_network.dart';
import '../../l10n/strings.dart';
import '../social/follow_controller.dart';

enum WotPhase { idle, discovering, complete, failed }

class WotState {
  /// Always on for a signed-in account. Guests have no follow list to read.
  final bool enabled;

  /// Accounts followed by at least [wotThreshold] of your follows. (Your own
  /// follows are not in here: they are read live from the follow list.)
  final Set<String> qualified;

  /// When the network was last computed (seconds); 0 = never.
  final int computedAt;
  final int directCount;

  final WotPhase phase;
  final int fetched;
  final int total;
  final String? error;

  const WotState({
    this.enabled = false,
    this.qualified = const {},
    this.computedAt = 0,
    this.directCount = 0,
    this.phase = WotPhase.idle,
    this.fetched = 0,
    this.total = 0,
    this.error,
  });

  /// Whether content is actually being filtered. Needs a computed network:
  /// the first build must not hide everything until it ends.
  bool get filtering => enabled && computedAt > 0;

  /// The follow lists are being read and the Discover feed is being prepared.
  bool get building => phase == WotPhase.discovering;

  WotState copyWith({
    bool? enabled,
    Set<String>? qualified,
    int? computedAt,
    int? directCount,
    WotPhase? phase,
    int? fetched,
    int? total,
    String? error,
  }) => WotState(
    enabled: enabled ?? this.enabled,
    qualified: qualified ?? this.qualified,
    computedAt: computedAt ?? this.computedAt,
    directCount: directCount ?? this.directCount,
    phase: phase ?? this.phase,
    fetched: fetched ?? this.fetched,
    total: total ?? this.total,
    error: error,
  );
}

/// A local web of trust, after Outkast's: an account is trusted when you
/// follow it, or when enough of the people you follow also follow it.
///
/// It is always on. The first time an account is opened, the follow lists
/// (NIP-02) are read on this phone and the Discover feed is built from the
/// result. Later launches reuse that network; it is read again only when
/// the user asks. Nothing here calls a scoring service. It decides which
/// posts Discover shows, and what strangers can push at you — comments,
/// notifications, private posts and messages.
class WebOfTrustController extends Notifier<WotState> {
  String? _pub;
  int _generation = 0;
  Future<void>? _inflight;
  final List<Completer<void>> _waiters = [];

  String get _file => 'wot_$_pub.json';

  bool get _settled =>
      _pub == null ||
      state.computedAt > 0 ||
      state.phase == WotPhase.failed ||
      state.phase == WotPhase.complete;

  /// Completes when this account's network has been loaded or the build has
  /// finished (including a failure, such as following nobody).
  Future<void> get ready {
    if (_settled) return Future.value();
    final waiter = Completer<void>();
    _waiters.add(waiter);
    return waiter.future;
  }

  void _release({bool force = false}) {
    if (!force && !_settled) return;
    for (final waiter in _waiters) {
      if (!waiter.isCompleted) waiter.complete();
    }
    _waiters.clear();
  }

  @override
  WotState build() {
    final generation = ++_generation;
    _inflight = null;
    _release(force: true);
    ref.onDispose(() {
      _generation++;
      _release(force: true);
    });
    final pub = ref.watch(authProvider.select((a) => a.publicKey));
    _pub = pub;
    if (pub == null) return const WotState();
    Future.microtask(() => _start(pub, generation));
    return const WotState(enabled: true);
  }

  static int _now() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  Future<void> _start(String pub, int generation) async {
    final json = await ref.read(localCacheProvider).readJson(_file);
    if (generation != _generation) return;
    // A build started before the cache was read (for example the user opened
    // Discover immediately) already owns the state.
    if (state.computedAt > 0 || _inflight != null) return;
    final at = json is Map ? (json['at'] as num?)?.toInt() ?? 0 : 0;
    if (json is Map && at > 0) {
      state = WotState(
        enabled: true,
        computedAt: at,
        directCount: (json['direct'] as num?)?.toInt() ?? 0,
        qualified: {
          for (final p in (json['q'] as List? ?? const []))
            if (p is String) p,
        },
        phase: WotPhase.complete,
      );
      _save();
      _release();
      return;
    }
    // First launch for this account: there is no network yet.
    state = const WotState(enabled: true);
    _save();
    unawaited(refresh());
  }

  void _save() {
    if (_pub == null) return;
    ref.read(localCacheProvider).writeJson(_file, {
      'enabled': true,
      'at': state.computedAt,
      'direct': state.directCount,
      'q': state.qualified.toList(),
    });
  }

  /// The switch no longer turns the network off. Passing false does nothing;
  /// passing true builds the network when it has never been computed.
  Future<void> setEnabled(bool enabled) async {
    if (!enabled || _pub == null) return;
    state = state.copyWith(enabled: true);
    _save();
    if (state.computedAt == 0) await refresh();
  }

  /// Reads the follow list of every account you follow and recomputes who
  /// qualifies. A chunk that cannot be fetched just contributes nothing: for
  /// a trust computation, failing towards "fewer people trusted" is the safe
  /// direction.
  Future<void> refresh() {
    if (_pub == null) return Future.value();
    final running = _inflight;
    if (running != null) return running;
    final generation = _generation;
    final job = _run(generation);
    _inflight = job;
    return job.whenComplete(() {
      if (identical(_inflight, job)) _inflight = null;
    });
  }

  Future<void> _run(int generation) async {
    if (generation != _generation || _pub == null) return;
    state = state.copyWith(phase: WotPhase.discovering, fetched: 0, total: 0);
    try {
      try {
        await ref
            .read(followListProvider.notifier)
            .ready
            .timeout(const Duration(seconds: 10));
      } on TimeoutException {
        // Go on with what is known.
      }
      if (generation != _generation) return;
      await _compute(generation);
    } catch (e) {
      if (generation == _generation) {
        state = state.copyWith(phase: WotPhase.failed, error: '$e');
      }
    } finally {
      if (generation == _generation) _finishRun();
    }
  }

  void _finishRun() {
    if (state.phase == WotPhase.discovering) {
      state = state.copyWith(
        phase: WotPhase.failed,
        error: AppStrings.current.loadFailed,
      );
    }
    _release();
  }

  Future<void> _compute(int generation) async {
    final me = _pub!;
    final follows = {...ref.read(followListProvider)}..remove(me);
    if (generation != _generation) return;
    if (follows.isEmpty) {
      state = state.copyWith(
        phase: WotPhase.failed,
        error: AppStrings.current.wotNoFollows,
      );
      return;
    }
    state = state.copyWith(
      phase: WotPhase.discovering,
      fetched: 0,
      total: follows.length,
    );
    final counter = FollowCounter();
    final list = follows.toList()..sort();
    for (var i = 0; i < list.length; i += wotChunkSize) {
      final chunk = list.sublist(i, (i + wotChunkSize).clamp(0, list.length));
      for (final event in await _fetchFollowLists(chunk)) {
        counter.add(followedBy(event));
      }
      if (generation != _generation) return;
      state = state.copyWith(fetched: i + chunk.length);
    }
    final qualified = counter.reaching()
      ..removeAll(follows)
      ..remove(me);
    state = state.copyWith(
      qualified: qualified,
      computedAt: _now(),
      directCount: follows.length,
      phase: WotPhase.complete,
    );
    _save();
  }

  /// The newest kind 3 of each author in [authors]. Never mixed with another
  /// kind, and the limit matches the chunk: a relay answers with one event
  /// per author anyway.
  Future<List<NostrEvent>> _fetchFollowLists(List<String> authors) async {
    try {
      final sub = ref
          .read(relayPoolProvider)
          .subscribe(
            [
              NostrFilter(
                kinds: const [NostrKinds.followList],
                authors: authors,
                limit: authors.length,
              ),
            ],
            extraRelays: ref.read(indexerRelaysProvider),
            eoseTimeout: const Duration(seconds: 8),
          );
      final newest = <String, NostrEvent>{};
      final listener = sub.events.listen((e) {
        final prev = newest[e.pubkey];
        if (prev == null || e.createdAt > prev.createdAt) newest[e.pubkey] = e;
      });
      await sub.eose;
      await Future<void>.delayed(const Duration(milliseconds: 250));
      await listener.cancel();
      sub.close();
      return newest.values.toList();
    } catch (_) {
      return const [];
    }
  }
}

final webOfTrustProvider = NotifierProvider<WebOfTrustController, WotState>(
  WebOfTrustController.new,
);

/// Who Discover may show: you, the people you follow, and whoever enough of
/// them follow. Strangers are absent even before the first build finishes.
final wotAuthorsProvider = Provider<Set<String>>((ref) {
  final me = ref.watch(authProvider.select((a) => a.publicKey));
  if (me == null) return const {};
  final follows = ref.watch(followListProvider);
  final qualified = ref.watch(webOfTrustProvider.select((s) => s.qualified));
  return {me, ...follows, ...qualified};
});

/// Who passes the spam filter: everyone while the network is not computed
/// yet; otherwise you, the people you follow, and your web of trust. Watch
/// it and call [TrustFilter.allows].
final trustFilterProvider = Provider<TrustFilter>((ref) {
  final filtering = ref.watch(webOfTrustProvider.select((s) => s.filtering));
  if (!filtering) return TrustFilter.open;
  final authors = ref.watch(wotAuthorsProvider);
  return TrustFilter(true, authors);
});
