import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../nostr/amber_signer.dart';
import '../nostr/nip19.dart';
import '../nostr/signer.dart';

const _nsecStorageKey = 'mialuna_nsec';
const _amberPubkeyKey = 'mialuna_amber_pubkey';

class AuthState {
  final Signer signer;
  const AuthState(this.signer);

  bool get isGuest => signer.type == SignerType.guest;
  String? get publicKey => signer.publicKey;
  String? get npub => publicKey == null ? null : Nip19.encodeNpub(publicKey!);
}

class AuthController extends Notifier<AuthState> {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  AuthState build() => AuthState(GuestSigner());

  /// Restores a previous session (nsec or Amber) from secure storage.
  Future<void> restore() async {
    try {
      final nsec = await _secureStorage.read(key: _nsecStorageKey);
      if (nsec != null && Nip19.isValidNsec(nsec)) {
        state = AuthState(NsecSigner.fromNsec(nsec));
        return;
      }
      final amberPub = await _secureStorage.read(key: _amberPubkeyKey);
      if (amberPub != null && await AmberSigner.isAvailable()) {
        state = AuthState(await AmberSigner.connect());
      }
    } catch (_) {
      state = AuthState(GuestSigner());
    }
  }

  /// Direct private-key login. The caller is responsible for showing the
  /// risk warning before invoking this.
  Future<void> loginWithNsec(String nsec) async {
    final signer = NsecSigner.fromNsec(nsec); // throws on invalid input
    await _secureStorage.write(
      key: _nsecStorageKey,
      value: Nip19.encodeNsec(
        // normalize to bech32 for storage
        Nip19.isValidNsec(nsec.trim())
            ? Nip19.decodeNsec(nsec.trim())
            : nsec.trim(),
      ),
    );
    state = AuthState(signer);
  }

  Future<void> loginWithAmber() async {
    final signer = await AmberSigner.connect();
    await _secureStorage.write(key: _amberPubkeyKey, value: signer.publicKey);
    state = AuthState(signer);
  }

  void loginAsGuest() {
    state = AuthState(GuestSigner());
  }

  /// Secure logout: removes every trace of key material.
  Future<void> logout() async {
    await _secureStorage.delete(key: _nsecStorageKey);
    await _secureStorage.delete(key: _amberPubkeyKey);
    await state.signer.dispose();
    state = AuthState(GuestSigner());
  }
}

final authProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
