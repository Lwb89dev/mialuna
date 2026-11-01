import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'nwc_service.dart';

/// Holds the optional Nostr Wallet Connect connection, persisted in
/// encrypted storage. Null when no wallet is linked.
class NwcController extends Notifier<NwcConnection?> {
  static const _storageKey = 'mialuna_nwc_uri';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  NwcConnection? build() {
    restore();
    return null;
  }

  Future<void> restore() async {
    try {
      final uri = await _storage.read(key: _storageKey);
      if (uri != null) state = NwcConnection.parse(uri);
    } catch (_) {
      state = null;
    }
  }

  Future<void> connect(String uri) async {
    final connection = NwcConnection.parse(uri); // throws on invalid input
    await _storage.write(key: _storageKey, value: connection.toUri());
    state = connection;
  }

  Future<void> disconnect() async {
    await _storage.delete(key: _storageKey);
    state = null;
  }
}

final nwcProvider = NotifierProvider<NwcController, NwcConnection?>(
  NwcController.new,
);
