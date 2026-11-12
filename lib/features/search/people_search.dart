import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/nip05.dart';
import '../../core/nostr/nip19.dart';
import '../../core/nostr/profile_repository.dart';
import '../../core/nostr/relay_pool.dart';
import '../messages/dm_controller.dart';
import '../social/follow_controller.dart';
import '../social/moderation_controller.dart';

/// Relays that can search profiles by name (NIP-50). The user's own relays
/// usually cannot. Only profile (kind 0) searches are sent to them.
const profileSearchRelays = ['wss://search.nos.today', 'wss://nostr.wine'];

final profileSearchRelaysProvider = Provider<List<String>>(
  (ref) => profileSearchRelays,
);

const _folded = {
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'å': 'a',
  'ā': 'a',
  'ą': 'a',
  'æ': 'ae',
  'ç': 'c',
  'ć': 'c',
  'č': 'c',
  'ď': 'd',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ē': 'e',
  'ę': 'e',
  'ě': 'e',
  'ğ': 'g',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ī': 'i',
  'ı': 'i',
  'ł': 'l',
  'ñ': 'n',
  'ń': 'n',
  'ň': 'n',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ø': 'o',
  'ō': 'o',
  'œ': 'oe',
  'ř': 'r',
  'ś': 's',
  'š': 's',
  'ş': 's',
  'ß': 'ss',
  'ť': 't',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ū': 'u',
  'ů': 'u',
  'ý': 'y',
  'ÿ': 'y',
  'ź': 'z',
  'ž': 'z',
  'ż': 'z',
};

/// Lower-cases and strips accents so "José" is found by "jose" and
/// "Çağla" by "cagla".
String normalizeForSearch(String input) {
  final buffer = StringBuffer();
  for (final rune in input.toLowerCase().runes) {
    final ch = String.fromCharCode(rune);
    buffer.write(_folded[ch] ?? ch);
  }
  return buffer.toString().replaceFirst(RegExp(r'^@'), '').trim();
}

class PeopleSearchState {
  final String query;

  /// Pubkeys, best match first.
  final List<String> results;

  /// A remote (NIP-50 / NIP-05) lookup is still running.
  final bool searching;

  const PeopleSearchState({
    this.query = '',
    this.results = const [],
    this.searching = false,
  });

  PeopleSearchState copyWith({
    String? query,
    List<String>? results,
    bool? searching,
  }) => PeopleSearchState(
    query: query ?? this.query,
    results: results ?? this.results,
    searching: searching ?? this.searching,
  );
}

/// Finds people **by name**. With an empty query it lists recent chats and
/// the accounts you follow; with text it matches name, display name and
/// NIP-05 across every profile the app knows (whole follow list included —
/// they are loaded in the background), then adds what NIP-50 search relays
/// know about strangers. `npub`, `nprofile` and `name@domain` also work, but
/// are never required.
class PeopleSearchController extends Notifier<PeopleSearchState> {
  Timer? _debounce;
  Timer? _recompute;
  PoolSubscription? _remote;
  int _generation = 0;
  final List<String> _remoteFound = [];

  @override
  PeopleSearchState build() {
    ref.onDispose(() {
      _debounce?.cancel();
      _recompute?.cancel();
      _remote?.close();
      _generation++;
    });
    // Names keep arriving (the follow list loads in the background): refresh
    // the matches as they do.
    ref.listen(profilesProvider, (_, _) {
      _recompute ??= Timer(const Duration(milliseconds: 300), () {
        _recompute = null;
        if (_direct(state.query) == null) {
          _publish(_generation, searching: state.searching);
        }
      });
    });
    // Names of everyone you could look for must be loaded to be matched.
    final repo = ref.read(profileRepositoryProvider);
    for (final pk in _contacts()) {
      repo.request(pk);
    }
    return PeopleSearchState(results: _localResults(''));
  }

  /// Recent chats first, then the follow list.
  List<String> _contacts() {
    final me = ref.read(authProvider).publicKey;
    final dm = ref.read(dmProvider);
    final follows = ref.read(followListProvider);
    final blocked = ref.read(blockProvider);
    return [
      for (final c in dm.sorted) c.peer,
      ...follows,
    ].where((p) => p != me && !blocked.contains(p)).toSet().toList();
  }

  int _score(ProfileMetadata? meta, String pubkey, String q) {
    if (q.isEmpty) return 0;
    final fields = [
      meta?.displayName,
      meta?.name,
      meta?.nip05?.split('@').first,
    ].whereType<String>().map(normalizeForSearch).toList();
    var best = -1;
    for (final f in fields) {
      if (f == q) {
        best = best < 4 ? 4 : best;
      } else if (f.startsWith(q)) {
        best = best < 3 ? 3 : best;
      } else if (f.split(RegExp(r'[\s._-]+')).any((w) => w.startsWith(q))) {
        best = best < 2 ? 2 : best;
      } else if (f.contains(q)) {
        best = best < 1 ? 1 : best;
      }
    }
    if (best < 0 && pubkey.startsWith(q)) best = 0;
    return best;
  }

  /// Matches among everyone already known: contacts first, then any other
  /// cached profile (people met in feeds, comments, earlier searches).
  List<String> _localResults(String rawQuery) {
    final q = normalizeForSearch(rawQuery);
    final profiles = ref.read(profilesProvider);
    final contacts = _contacts();
    final contactSet = contacts.toSet();
    final me = ref.read(authProvider).publicKey;
    final blocked = ref.read(blockProvider);

    if (q.isEmpty) {
      // Conversations keep their order; the rest is alphabetical, people
      // whose profile has not loaded yet go last.
      final recent = contacts.take(ref.read(dmProvider).sorted.length).toList();
      final rest = contacts.skip(recent.length).toList()
        ..sort((a, b) {
          final la = profiles[a]?.label.toLowerCase();
          final lb = profiles[b]?.label.toLowerCase();
          if (la == null && lb == null) return 0;
          if (la == null) return 1;
          if (lb == null) return -1;
          return la.compareTo(lb);
        });
      return [...recent, ...rest];
    }

    final scored = <(String, int, bool)>[];
    final universe = {...contactSet, ...profiles.keys};
    for (final pk in universe) {
      if (pk == me || blocked.contains(pk)) continue;
      final score = _score(profiles[pk], pk, q);
      if (score >= 0) scored.add((pk, score, contactSet.contains(pk)));
    }
    scored.sort((a, b) {
      // Better match first; at equal quality, people you know first.
      if (a.$2 != b.$2) return b.$2.compareTo(a.$2);
      if (a.$3 != b.$3) return a.$3 ? -1 : 1;
      final la = profiles[a.$1]?.label.toLowerCase() ?? '';
      final lb = profiles[b.$1]?.label.toLowerCase() ?? '';
      return la.compareTo(lb);
    });
    return [for (final s in scored) s.$1];
  }

  void setQuery(String raw) {
    final query = raw.trim();
    _debounce?.cancel();
    _remote?.close();
    _remoteFound.clear();
    final generation = ++_generation;

    // An identifier needs no search.
    final direct = _direct(query);
    if (direct != null) {
      ref.read(profilesProvider.notifier).request(direct);
      state = PeopleSearchState(query: query, results: [direct]);
      return;
    }

    state = PeopleSearchState(
      query: query,
      results: _localResults(query),
      searching: query.length >= 2,
    );
    if (query.length < 2) return;

    _debounce = Timer(const Duration(milliseconds: 350), () {
      _searchRemote(query, generation);
    });
  }

  String? _direct(String query) {
    try {
      if (query.startsWith('npub1')) return Nip19.decodeNpub(query);
      if (RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(query)) {
        return query.toLowerCase();
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  Future<void> _searchRemote(String query, int generation) async {
    final extra = <String>[];
    final searchers = ref.read(profileSearchRelaysProvider);
    extra.addAll(searchers);

    final repo = ref.read(profileRepositoryProvider);

    // `name@domain` → the account that domain vouches for.
    final nip05 = Nip05.looksLikeIdentifier(query)
        ? Nip05.resolve(query)
        : Future<String?>.value();

    PoolSubscription? sub;
    if (extra.isNotEmpty) {
      sub = ref
          .read(relayPoolProvider)
          .subscribe(
            [
              NostrFilter(
                kinds: const [NostrKinds.profileMetadata],
                search: query,
                limit: 25,
              ),
            ],
            extraRelays: extra,
            onlyExtra: true,
            eoseTimeout: const Duration(seconds: 7),
          );
      _remote = sub;
      sub.events.listen((event) {
        if (generation != _generation) return;
        repo.applyLocal(event); // fills the profile cache too
        if (!_remoteFound.contains(event.pubkey)) {
          _remoteFound.add(event.pubkey);
        }
        _publish(generation, searching: true);
      });
    }

    final resolved = await nip05;
    if (generation != _generation) return;
    if (resolved != null) {
      repo.request(resolved);
      _remoteFound.insert(0, resolved);
    }
    if (sub != null) {
      await sub.eose;
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    if (generation != _generation) return;
    sub?.close();
    _publish(generation, searching: false);
  }

  void _publish(int generation, {required bool searching}) {
    if (generation != _generation) return;
    final me = ref.read(authProvider).publicKey;
    final blocked = ref.read(blockProvider);
    final local = _localResults(state.query);
    final localSet = local.toSet();
    // Local matches keep their ranking; accounts only a search relay knows
    // follow, in the relay's own relevance order.
    state = state.copyWith(
      results: [
        ...local,
        for (final pk in _remoteFound)
          if (!localSet.contains(pk) && pk != me && !blocked.contains(pk)) pk,
      ],
      searching: searching,
    );
  }
}

final peopleSearchProvider =
    NotifierProvider.autoDispose<PeopleSearchController, PeopleSearchState>(
      PeopleSearchController.new,
    );
