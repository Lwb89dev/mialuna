import 'dart:convert';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/nostr/relay.dart';
import '../../core/nostr/relay_pool.dart';

/// Relays used until the user's own NIP-65 list is found. (relay.nostr.band
/// was removed: it no longer answers.)
const defaultRelayConfigs = [
  RelayConfig('wss://relay.damus.io'),
  RelayConfig('wss://nos.lol'),
  RelayConfig('wss://relay.primal.net'),
  RelayConfig('wss://nostr.mom'),
];

/// Kept for code that only needs the URLs.
final defaultRelays = [for (final r in defaultRelayConfigs) r.url];

/// Relays that index profiles and relay lists (kinds 0, 3, 10002, 10050,
/// 10063). Only metadata is requested from them — never user content.
const indexerRelays = ['wss://purplepag.es', 'wss://indexer.coracle.social'];

/// Blossom servers offered out of the box; media is only ever uploaded to
/// servers in the user's own list, in this order.
const defaultBlossomServers = [
  'https://blossom.primal.net',
  'https://cdn.hzrd149.com',
  'https://blossom.band',
];

/// Settings that must be known before the first screen is built.
final initialSettingsProvider = Provider<AppSettings>(
  (ref) => AppSettings.defaults(),
);

/// User-configurable settings: relays (NIP-65 roles) and Blossom servers.
/// The relay list mirrors the user's kind 10002 event; manual edits are
/// published back so every client sees the same list.
/// Value of the language setting that follows the phone's language.
const systemLanguage = 'system';

/// Languages the app is translated into: the codes of lib/l10n/app_<code>.arb.
/// Adding a language = a new ARB file + its code here (docs/TRANSLATING.md).
const appLanguages = ['en', 'it'];

String _knownLanguage(String? code) =>
    appLanguages.contains(code) ? code! : systemLanguage;

class SettingsController extends Notifier<AppSettings> {
  static const _relaysKey = 'mialuna_relay_config';
  static const _legacyRelaysKey = 'mialuna_relays';
  static const _legacyCustomizedKey = 'mialuna_relays_customized';
  static const _blossomListKey = 'mialuna_blossom_servers';
  static const _legacyBlossomKey = 'mialuna_blossom';
  static const _ownerKey = 'mialuna_relay_list_owner';
  static const _createdAtKey = 'mialuna_relay_list_created_at';
  static const _blossomCreatedAtKey = 'mialuna_blossom_list_created_at';
  static const _dirtyKey = 'mialuna_relay_list_dirty';
  static const _dataSaverKey = 'mialuna_data_saver';
  static const _themeKey = 'mialuna_theme_mode';
  static const _languageKey = 'mialuna_language';

  @override
  AppSettings build() => ref.read(initialSettingsProvider);

  /// Reads the persisted settings (migrating the pre-0.13 format).
  static AppSettings load(SharedPreferences prefs) {
    List<RelayConfig> relays = const [];
    final raw = prefs.getString(_relaysKey);
    if (raw != null) {
      try {
        relays = [
          for (final j in jsonDecode(raw) as List)
            RelayConfig.fromJson(j as Map<String, dynamic>),
        ];
      } catch (_) {}
    }
    var createdAt = prefs.getInt(_createdAtKey) ?? 0;
    var dirty = prefs.getBool(_dirtyKey) ?? false;
    if (relays.isEmpty) {
      final legacy = prefs.getStringList(_legacyRelaysKey);
      if (legacy != null && legacy.isNotEmpty) {
        relays = [
          for (final u in legacy)
            if (normalizeRelayUrl(u) != null)
              RelayConfig(normalizeRelayUrl(u)!),
        ];
        // A list the user customized by hand outranks anything found online
        // until it has been published.
        if (prefs.getBool(_legacyCustomizedKey) ?? false) {
          createdAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          dirty = true;
        }
      }
    }
    if (relays.isEmpty) relays = List.of(defaultRelayConfigs);

    var blossom = prefs.getStringList(_blossomListKey) ?? const [];
    if (blossom.isEmpty) {
      final legacy = prefs.getString(_legacyBlossomKey);
      blossom = legacy != null
          ? [legacy, ...defaultBlossomServers.where((s) => s != legacy)]
          : List.of(defaultBlossomServers);
    }
    return AppSettings(
      relays: relays,
      blossomServers: blossom,
      relayListOwner: prefs.getString(_ownerKey),
      relayListCreatedAt: createdAt,
      blossomListCreatedAt: prefs.getInt(_blossomCreatedAtKey) ?? 0,
      relayListDirty: dirty,
      dataSaver: prefs.getBool(_dataSaverKey) ?? false,
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == prefs.getString(_themeKey),
        orElse: () => ThemeMode.system,
      ),
      language: _knownLanguage(prefs.getString(_languageKey)),
    );
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _relaysKey,
      jsonEncode([for (final r in state.relays) r.toJson()]),
    );
    await prefs.setStringList(_blossomListKey, state.blossomServers);
    await prefs.setInt(_createdAtKey, state.relayListCreatedAt);
    await prefs.setInt(_blossomCreatedAtKey, state.blossomListCreatedAt);
    await prefs.setBool(_dirtyKey, state.relayListDirty);
    final owner = state.relayListOwner;
    if (owner == null) {
      await prefs.remove(_ownerKey);
    } else {
      await prefs.setString(_ownerKey, owner);
    }
  }

  /// Light, dark or follow the system.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  /// 'system' or a language code from [appLanguages].
  Future<void> setLanguage(String code) async {
    final language = _knownLanguage(code);
    state = state.copyWith(language: language);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  Future<void> setDataSaver(bool value) async {
    state = state.copyWith(dataSaver: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dataSaverKey, value);
  }

  static List<RelayConfig> cleanRelays(Iterable<RelayConfig> relays) {
    final merged = <String, RelayConfig>{};
    for (final r in relays) {
      final url = normalizeRelayUrl(r.url);
      if (url == null || (!r.read && !r.write)) continue;
      final prev = merged[url];
      merged[url] = RelayConfig(
        url,
        read: (prev?.read ?? false) || r.read,
        write: (prev?.write ?? false) || r.write,
      );
    }
    return merged.values.toList();
  }

  /// Manual edit by the user. Returns the cleaned list, or null when the
  /// result would leave no relay at all.
  Future<List<RelayConfig>?> setRelays(
    List<RelayConfig> relays, {
    String? owner,
  }) async {
    final clean = cleanRelays(relays);
    if (clean.isEmpty || !clean.any((r) => r.read)) return null;
    state = state.copyWith(
      relays: clean,
      relayListOwner: owner ?? state.relayListOwner,
      relayListCreatedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      relayListDirty: true,
    );
    await _persist();
    return clean;
  }

  /// Adopts a relay list found on the network (kind 10002) for [pubkey].
  Future<void> applyNip65(
    String pubkey,
    List<RelayConfig> relays,
    int createdAt,
  ) async {
    final clean = cleanRelays(relays);
    if (clean.isEmpty) return;
    state = state.copyWith(
      relays: clean,
      relayListOwner: pubkey,
      relayListCreatedAt: createdAt,
      relayListDirty: false,
    );
    await _persist();
  }

  /// Marks the local list as the one published by [pubkey].
  Future<void> markRelayListPublished(String pubkey, int createdAt) async {
    state = state.copyWith(
      relayListOwner: pubkey,
      relayListCreatedAt: createdAt,
      relayListDirty: false,
    );
    await _persist();
  }

  /// Signing out: the relays stay (they are public), but the list no longer
  /// belongs to anyone, so the next account neither inherits nor publishes
  /// the previous one's edits.
  Future<void> detachAccount() async {
    state = AppSettings(
      relays: state.relays,
      blossomServers: state.blossomServers,
      relayListOwner: null,
      relayListCreatedAt: 0,
      blossomListCreatedAt: 0,
      relayListDirty: false,
      dataSaver: state.dataSaver,
      themeMode: state.themeMode,
      language: state.language,
    );
    await _persist();
  }

  /// Claims the current list for [pubkey] without changing it (first login
  /// of an account that has no published list yet).
  Future<void> claimRelayList(String pubkey) async {
    if (state.relayListOwner == pubkey) return;
    state = state.copyWith(relayListOwner: pubkey);
    await _persist();
  }

  Future<void> resetRelaysToDefault() async {
    state = state.copyWith(
      relays: List.of(defaultRelayConfigs),
      relayListCreatedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      relayListDirty: true,
    );
    await _persist();
  }

  Future<void> setBlossomServers(List<String> servers, {int? createdAt}) async {
    final clean = <String>[];
    for (final s in servers) {
      var u = s.trim();
      if (u.isEmpty) continue;
      if (!u.contains('://')) u = 'https://$u';
      final uri = Uri.tryParse(u);
      if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) continue;
      u = u.replaceAll(RegExp(r'/+$'), '');
      if (!clean.contains(u)) clean.add(u);
    }
    if (clean.isEmpty) return;
    state = state.copyWith(
      blossomServers: clean,
      blossomListCreatedAt:
          createdAt ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
    await _persist();
  }

  Future<void> addBlossomServer(String url) =>
      setBlossomServers([...state.blossomServers, url]);

  Future<void> removeBlossomServer(String url) =>
      setBlossomServers([...state.blossomServers]..remove(url));

  Future<void> makeBlossomPrimary(String url) =>
      setBlossomServers([url, ...state.blossomServers.where((s) => s != url)]);
}

class AppSettings {
  final List<RelayConfig> relays;

  /// Ordered Blossom servers; the first is tried first.
  final List<String> blossomServers;

  /// Account whose NIP-65 list `relays` mirrors (null = nobody yet).
  final String? relayListOwner;

  /// `created_at` of the kind 10002 event this list corresponds to; manual
  /// edits stamp the current time so they win over older network copies.
  final int relayListCreatedAt;
  final int blossomListCreatedAt;

  /// True while the local list has edits that were not published yet.
  final bool relayListDirty;

  /// Data-saver: no off-screen reel loading, reduced-resolution images.
  final bool dataSaver;

  /// Light, dark, or whatever the system uses.
  final ThemeMode themeMode;

  /// 'system' (follow the phone) or one of [appLanguages].
  final String language;

  const AppSettings({
    required this.relays,
    this.blossomServers = defaultBlossomServers,
    this.relayListOwner,
    this.relayListCreatedAt = 0,
    this.blossomListCreatedAt = 0,
    this.relayListDirty = false,
    this.dataSaver = false,
    this.themeMode = ThemeMode.system,
    this.language = systemLanguage,
  });

  factory AppSettings.defaults() => AppSettings(
    relays: List.of(defaultRelayConfigs),
    blossomServers: List.of(defaultBlossomServers),
  );

  String get blossomServer => blossomServers.first;

  AppSettings copyWith({
    List<RelayConfig>? relays,
    List<String>? blossomServers,
    String? relayListOwner,
    int? relayListCreatedAt,
    int? blossomListCreatedAt,
    bool? relayListDirty,
    bool? dataSaver,
    ThemeMode? themeMode,
    String? language,
  }) => AppSettings(
    relays: relays ?? this.relays,
    blossomServers: blossomServers ?? this.blossomServers,
    relayListOwner: relayListOwner ?? this.relayListOwner,
    relayListCreatedAt: relayListCreatedAt ?? this.relayListCreatedAt,
    blossomListCreatedAt: blossomListCreatedAt ?? this.blossomListCreatedAt,
    relayListDirty: relayListDirty ?? this.relayListDirty,
    dataSaver: dataSaver ?? this.dataSaver,
    themeMode: themeMode ?? this.themeMode,
    language: language ?? this.language,
  );
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);
