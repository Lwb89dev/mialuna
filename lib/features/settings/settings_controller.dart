import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    );
  }

  Future<void> setRelays(List<String> relays) async {
    final clean = relays
        .map((r) => r.trim())
        .where((r) => r.startsWith('wss://') || r.startsWith('ws://'))
        .toSet()
        .toList();
    if (clean.isEmpty) return;
    state = state.copyWith(relays: clean);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_relaysKey, clean);
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

  const AppSettings({
    required this.relays,
    this.blossomServer = 'https://blossom.primal.net',
  });

  AppSettings copyWith({List<String>? relays, String? blossomServer}) =>
      AppSettings(
        relays: relays ?? this.relays,
        blossomServer: blossomServer ?? this.blossomServer,
      );
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);
