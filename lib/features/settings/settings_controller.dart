import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/nostr/nip65.dart';

/// Default relays, sensible for beginners.
const defaultRelays = [
  'wss://relay.damus.io',
  'wss://nos.lol',
  'wss://relay.nostr.band',
  'wss://nostr.mom',
];

/// User-configurable settings: relays, Blossom server. Defaults are
/// sensible for beginners; custom values are never silently overwritten.
class SettingsController extends Notifier<AppSettings> {
  static const _relaysKey = 'mialuna_relays';
  static const _blossomKey = 'mialuna_blossom';
  static const _customizedKey = 'mialuna_relays_customized';
  static const _dataSaverKey = 'mialuna_data_saver';

  /// Pubkeys whose NIP-65 list was already applied this session.
  final Set<String> _nip65Synced = {};

  @override
  AppSettings build() {
    _load();
    return const AppSettings(relays: defaultRelays);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final relays = prefs.getStringList(_relaysKey);
    final blossom = prefs.getString(_blossomKey);
    state = AppSettings(
      relays: relays ?? defaultRelays,
      blossomServer: blossom ?? state.blossomServer,
      relaysCustomized: prefs.getBool(_customizedKey) ?? false,
      dataSaver: prefs.getBool(_dataSaverKey) ?? false,
    );
  }

  Future<void> setDataSaver(bool value) async {
    state = state.copyWith(dataSaver: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dataSaverKey, value);
  }

  Future<void> setRelays(List<String> relays) async {
    final clean = relays
        .map((r) => r.trim())
        .where((r) => r.startsWith('wss://') || r.startsWith('ws://'))
        .toSet()
        .toList();
    if (clean.isEmpty) return;
    state = state.copyWith(relays: clean, relaysCustomized: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_relaysKey, clean);
    await prefs.setBool(_customizedKey, true);
  }

  /// Adopts the user's NIP-65 relay list (kind 10002) fetched from the
  /// default bootstrap relays. Skipped entirely once the user has customized
  /// relays manually — their choice always wins.
  Future<void> syncFromNip65(String pubkey) async {
    if (state.relaysCustomized || !_nip65Synced.add(pubkey)) return;
    try {
      final event = await fetchLatestRelayList(defaultRelays, pubkey);
      if (event == null) return;
      final urls = [
        for (final e in parseRelayList(event))
          if (e.write) e.url,
      ];
      if (urls.isEmpty) return;
      state = state.copyWith(relays: urls);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_relaysKey, urls);
    } catch (_) {
      _nip65Synced.remove(pubkey); // allow retry on next login
    }
  }

  Future<void> addRelay(String url) => setRelays([...state.relays, url]);

  Future<void> removeRelay(String url) =>
      setRelays([...state.relays]..remove(url));

  Future<void> setBlossomServer(String url) async {
    final clean = url.trim();
    if (!clean.startsWith('https://')) return;
    state = state.copyWith(blossomServer: clean);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_blossomKey, clean);
  }
}

class AppSettings {
  final List<String> relays;
  final String blossomServer;

  /// True once the user edits relays manually: NIP-65 sync is then disabled.
  final bool relaysCustomized;

  /// Data-saver: no off-screen reel loading, reduced-resolution images.
  final bool dataSaver;

  const AppSettings({
    required this.relays,
    this.blossomServer = 'https://blossom.primal.net',
    this.relaysCustomized = false,
    this.dataSaver = false,
  });

  AppSettings copyWith({
    List<String>? relays,
    String? blossomServer,
    bool? relaysCustomized,
    bool? dataSaver,
  }) => AppSettings(
    relays: relays ?? this.relays,
    blossomServer: blossomServer ?? this.blossomServer,
    relaysCustomized: relaysCustomized ?? this.relaysCustomized,
    dataSaver: dataSaver ?? this.dataSaver,
  );
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);
