import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../nostr/amber_signer.dart';
import '../nostr/bunker_signer.dart';
import '../nostr/nip19.dart';
import '../nostr/signer.dart';

const _nsecStorageKey = 'mialuna_nsec';
const _amberPubkeyKey = 'mialuna_amber_pubkey';
const _bunkerUrlKey = 'mialuna_bunker_url';

class AuthState {
  final Signer signer;

  /// The saved session is still being read from secure storage (or a remote
  /// signer is being reached): [signer] is a guest placeholder for now.
  /// Screens that would start work as a guest wait for this to end.
  final bool restoring;
  const AuthState(this.signer, {this.restoring = false});

  bool get isGuest => signer.type == SignerType.guest;
  String? get publicKey => signer.publicKey;
  String? get npub => publicKey == null ? null : Nip19.encodeNpub(publicKey!);
}

class AuthController extends Notifier<AuthState> {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  AuthState build() => AuthState(GuestSigner(), restoring: true);

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
        // No Amber screen at startup: it is only opened when signing.
        state = AuthState(AmberSigner.restore(amberPub));
        return;
      }
      final bunkerUrl = await _secureStorage.read(key: _bunkerUrlKey);
      if (bunkerUrl != null) {
        state = AuthState(await BunkerSigner.connect(bunkerUrl));
      }
    } catch (_) {
      state = AuthState(GuestSigner());
    } finally {
      // Nothing saved: this really is a guest.
      if (state.restoring) state = AuthState(state.signer);
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

  /// NIP-46 remote signer login (bunker:// URL).
  Future<void> loginWithBunker(String bunkerUrl) async {
    final signer = await BunkerSigner.connect(bunkerUrl);
    await _secureStorage.write(key: _bunkerUrlKey, value: bunkerUrl.trim());
    state = AuthState(signer);
  }

  void loginAsGuest() {
    state = AuthState(GuestSigner());
  }

  /// Secure logout: removes every trace of key material.
  Future<void> logout() async {
    await _secureStorage.delete(key: _nsecStorageKey);
    await _secureStorage.delete(key: _amberPubkeyKey);
    await _secureStorage.delete(key: _bunkerUrlKey);
    await state.signer.dispose();
    state = AuthState(GuestSigner());
  }
}

final authProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
