import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth/auth_controller.dart';
import '../core/nostr/event.dart';
import '../core/nostr/filter.dart';
import '../core/nostr/nip65.dart';
import '../core/nostr/relay_pool.dart';
import '../features/settings/settings_controller.dart';
import '../l10n/strings.dart';
import 'providers.dart';

class RelaySyncState {
  final bool syncing;
  final DateTime? lastSync;

  /// Human-readable outcome of the last sync, shown in the settings.
  final String? message;
  const RelaySyncState({this.syncing = false, this.lastSync, this.message});
}

/// Keeps the app's relay list and Blossom server list in step with the
/// user's own Nostr events (NIP-65 kind 10002, BUD-03 kind 10063), with no
/// manual setup:
///
/// * on sign-in and whenever the app comes back to the foreground the newest
///   lists are fetched from the user's relays and from the indexer relays;
/// * a list found online replaces the local one only when it is newer;
/// * manual edits are published back, so other Nostr apps see them too.
class RelaySyncController extends Notifier<RelaySyncState> {
  static const minInterval = Duration(minutes: 10);
  bool _running = false;

  @override
  RelaySyncState build() {
    // Re-sync whenever the signed-in account changes.
    ref.listen(authProvider.select((a) => a.publicKey), (_, pub) {
      if (pub != null) sync(force: true);
    });
    // Already signed in when first read: sync once `build` has returned.
    if (ref.read(authProvider).publicKey != null) {
      Future.microtask(() => sync(force: true));
    }
    return const RelaySyncState();
  }

  Future<void> sync({bool force = false}) async {
    final pub = ref.read(authProvider).publicKey;
    if (pub == null || _running) return;
    final last = state.lastSync;
    if (!force &&
        last != null &&
        DateTime.now().difference(last) < minInterval) {
      return;
    }
    _running = true;
    state = RelaySyncState(
      syncing: true,
      lastSync: last,
      message: state.message,
    );
    try {
      final pool = ref.read(relayPoolProvider);
      final sub = pool.subscribe(
        [
          NostrFilter(
            kinds: const [NostrKinds.relayList, NostrKinds.blossomServerList],
            authors: [pub],
            limit: 8,
          ),
        ],
        extraRelays: ref.read(indexerRelaysProvider),
        eoseTimeout: const Duration(seconds: 7),
      );
      final events = <NostrEvent>[];
      final listener = sub.events.listen(events.add);
      await sub.eose;
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await listener.cancel();
      sub.close();

      final notes = <String>[];
      notes.addAll(
        await _applyRelayList(pub, newestOfKind(events, NostrKinds.relayList)),
      );
      notes.addAll(
        await _applyBlossomList(
          newestOfKind(events, NostrKinds.blossomServerList),
        ),
      );
      state = RelaySyncState(
        lastSync: DateTime.now(),
        message: notes.isEmpty
            ? AppStrings.current.syncUpToDate
            : notes.join(' · '),
      );
    } catch (e) {
      state = RelaySyncState(
        lastSync: last,
        message: AppStrings.current.syncFailed,
      );
    } finally {
      _running = false;
    }
  }

  Future<List<String>> _applyRelayList(String pub, NostrEvent? event) async {
    final settingsCtl = ref.read(settingsProvider.notifier);
    final settings = ref.read(settingsProvider);
    final ownList = settings.relayListOwner == pub;
    if (event == null) {
      // Nothing published yet: keep the current list, and publish it only if
      // the user edited it by hand.
      await settingsCtl.claimRelayList(pub);
      if (ref.read(settingsProvider).relayListDirty) await publishRelayList();
      return const [];
    }
    final newerOnline =
        !ownList || event.createdAt > settings.relayListCreatedAt;
    if (newerOnline) {
      final configs = relayListToConfigs(parseRelayList(event));
      if (configs.isEmpty) return const [];
      final changed = !_sameRelays(configs, settings.relays);
      await settingsCtl.applyNip65(pub, configs, event.createdAt);
      return changed ? [AppStrings.current.relaysUpdatedFromProfile] : const [];
    }
    if (settings.relayListDirty) {
      final report = await publishRelayList();
      if (report != null && report.publishedSomewhere) {
        return [AppStrings.current.relayListPublished];
      }
    }
    return const [];
  }

  Future<List<String>> _applyBlossomList(NostrEvent? event) async {
    if (event == null) return const [];
    final settings = ref.read(settingsProvider);
    if (event.createdAt <= settings.blossomListCreatedAt) return const [];
    final servers = parseBlossomServerList(event);
    if (servers.isEmpty) return const [];
    final changed = servers.join() != settings.blossomServers.join();
    await ref
        .read(settingsProvider.notifier)
        .setBlossomServers(servers, createdAt: event.createdAt);
    return changed
        ? [AppStrings.current.mediaServersUpdatedFromProfile]
        : const [];
  }

  bool _sameRelays(List<RelayConfig> a, List<RelayConfig> b) =>
      a.length == b.length && a.toSet().containsAll(b);

  /// Publishes the local relay list as the user's kind 10002 event, also to
  /// the indexer relays so other apps can find it.
  Future<PublishReport?> publishRelayList() async {
    final auth = ref.read(authProvider);
    final signer = auth.signer;
    final pub = auth.publicKey;
    if (!signer.canSign || pub == null) return null;
    try {
      final settings = ref.read(settingsProvider);
      final event = await signer.signEvent(
        kind: NostrKinds.relayList,
        tags: buildRelayListTags(settings.relays),
        content: '',
      );
      final report = await ref
          .read(relayPoolProvider)
          .publish(event, extraRelays: ref.read(indexerRelaysProvider));
      if (report.publishedSomewhere) {
        await ref
            .read(settingsProvider.notifier)
            .markRelayListPublished(pub, event.createdAt);
      }
      return report;
    } catch (_) {
      return null;
    }
  }

  /// Publishes the Blossom server list (BUD-03, kind 10063).
  Future<PublishReport?> publishBlossomList() async {
    final signer = ref.read(authProvider).signer;
    if (!signer.canSign) return null;
    try {
      final event = await signer.signEvent(
        kind: NostrKinds.blossomServerList,
        tags: buildBlossomServerTags(ref.read(settingsProvider).blossomServers),
        content: '',
      );
      return await ref.read(relayPoolProvider).publish(event);
    } catch (_) {
      return null;
    }
  }
}

final relaySyncProvider = NotifierProvider<RelaySyncController, RelaySyncState>(
  RelaySyncController.new,
);
