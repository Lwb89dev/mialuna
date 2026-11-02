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
  /// The user turned the filter on (off by default, per account).
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
  /// turning the switch on must not hide everything until the first
  /// computation ends — it shows everything, unfiltered, until then.
  bool get filtering => enabled && computedAt > 0;

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

/// A local, opt-in web of trust against spam, after Outkast's: an account is
/// trusted when you follow it, or when enough of the people you follow also
/// follow it. Nothing here asks any scoring service; it is a reading of the
/// follow lists (NIP-02) that every client already fetches, kept on this
/// phone. It filters what strangers can push at you — comments, notifications,
/// private posts and messages — never Discover, whose purpose is meeting
/// people you do not know yet.
class WebOfTrustController extends Notifier<WotState> {
  /// A computed network older than this is refreshed when the app starts.
  static const staleAfter = Duration(hours: 12);

  String? _pub;
  int _generation = 0;
  bool _running = false;

  String get _file => 'wot_$_pub.json';

  @override
  WotState build() {
    final generation = ++_generation;
    ref.onDispose(() => _generation++);
    _running = false;
    final pub = ref.watch(authProvider.select((a) => a.publicKey));
    _pub = pub;
    if (pub == null) return const WotState();
    Future.microtask(() => _start(pub, generation));
    return const WotState();
  }

  static int _now() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  Future<void> _start(String pub, int generation) async {
    final json = await ref.read(localCacheProvider).readJson(_file);
    if (generation != _generation) return;
    if (json is Map) {
      state = WotState(
        enabled: json['enabled'] == true,
        computedAt: (json['at'] as num?)?.toInt() ?? 0,
        directCount: (json['direct'] as num?)?.toInt() ?? 0,
        qualified: {
          for (final p in (json['q'] as List? ?? const []))
            if (p is String) p,
        },
        phase: (json['at'] as num? ?? 0) > 0
            ? WotPhase.complete
            : WotPhase.idle,
      );
    }
    final stale = _now() - state.computedAt > staleAfter.inSeconds;
    if (state.enabled && stale) {
      try {
        await ref.read(followListProvider.notifier).usable;
      } catch (_) {}
      if (generation == _generation) unawaited(refresh());
    }
  }

  void _save() {
    if (_pub == null) return;
    ref.read(localCacheProvider).writeJson(_file, {
      'enabled': state.enabled,
      'at': state.computedAt,
      'direct': state.directCount,
      'q': state.qualified.toList(),
    });
  }

  /// Turns the filter on or off. Turning it on is the moment to build the
  /// network for the first time: otherwise the switch would do nothing until
  /// the user found the refresh button.
  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(enabled: enabled, error: state.error);
    _save();
    if (enabled && state.computedAt == 0) await refresh();
  }

  /// Reads the follow list of every account you follow and recomputes who
  /// qualifies. A chunk that cannot be fetched just contributes nothing: for
  /// a trust computation, failing towards "fewer people trusted" is the safe
  /// direction.
  Future<void> refresh() async {
    final generation = _generation;
    if (_running || _pub == null) return;
    _running = true;
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
    } finally {
      _running = false;
    }
  }

  Future<void> _compute(int generation) async {
    final me = _pub!;
    final follows = {...ref.read(followListProvider)}..remove(me);
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

/// Who passes the filter: everyone while it is off (or not yet computed);
/// otherwise you, the people you follow, and your web of trust. Watch it and
/// call [TrustFilter.allows].
final trustFilterProvider = Provider<TrustFilter>((ref) {
  final filtering = ref.watch(webOfTrustProvider.select((s) => s.filtering));
  if (!filtering) return TrustFilter.open;
  final qualified = ref.watch(webOfTrustProvider.select((s) => s.qualified));
  final me = ref.watch(authProvider.select((a) => a.publicKey));
  final follows = ref.watch(followListProvider);
  return TrustFilter(true, {...qualified, ...follows, ?me});
});
