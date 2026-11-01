import 'dart:math';

import 'package:bip340/bip340.dart' as bip340;

import 'bech32.dart';
import 'event.dart';
import 'nip19.dart';

/// How the user's key material is held.
enum SignerType { nsec, amber, bunker, guest }

/// Platform-independent signing abstraction. Implementations never expose
/// private key material beyond their own scope.
abstract class Signer {
  SignerType get type;

  /// Hex public key of the current identity. Null in guest mode.
  String? get publicKey;

  bool get canSign;

  Future<NostrEvent> signEvent({
    required int kind,
    required List<List<String>> tags,
    required String content,
    int? createdAt,
  });

  Future<void> dispose() async {}
}

class SignerException implements Exception {
  final String message;
  const SignerException(this.message);
  @override
  String toString() => 'SignerException: $message';
}

/// Local private-key signer (advanced fallback). The key never leaves
/// secure storage and is never logged or transmitted.
class NsecSigner extends Signer {
  final String _privateKeyHex;
  @override
  final String publicKey;

  NsecSigner._(this._privateKeyHex, this.publicKey);

  /// Accepts an nsec… bech32 string or a raw 64-char hex key.
  factory NsecSigner.fromNsec(String input) {
    final trimmed = input.trim();
    final String hex;
    if (trimmed.startsWith('nsec')) {
      hex = Nip19.decodeNsec(trimmed);
    } else if (RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(trimmed)) {
      hex = trimmed.toLowerCase();
    } else {
      throw const FormatException('Invalid nsec or hex private key');
    }
    return NsecSigner._(hex, bip340.getPublicKey(hex));
  }

  static String generatePrivateKey() {
    final rng = Random.secure();
    final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
    return bytesToHex(bytes);
  }

  @override
  SignerType get type => SignerType.nsec;

  @override
  bool get canSign => true;

  @override
  Future<NostrEvent> signEvent({
    required int kind,
    required List<List<String>> tags,
    required String content,
    int? createdAt,
  }) async {
    final ts = createdAt ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final id = NostrEvent.computeId(
      pubkey: publicKey,
      createdAt: ts,
      kind: kind,
      tags: tags,
      content: content,
    );
    final aux = bytesToHex(
      List<int>.generate(32, (_) => Random.secure().nextInt(256)),
    );
    final sig = bip340.sign(_privateKeyHex, id, aux);
    return NostrEvent(
      id: id,
      pubkey: publicKey,
      createdAt: ts,
      kind: kind,
      tags: tags,
      content: content,
      sig: sig,
    );
  }
}

/// Read-only session: browsing without any key.
class GuestSigner extends Signer {
  @override
  SignerType get type => SignerType.guest;
  @override
  String? get publicKey => null;
  @override
  bool get canSign => false;
  @override
  Future<NostrEvent> signEvent({
    required int kind,
    required List<List<String>> tags,
    required String content,
    int? createdAt,
  }) => throw const SignerException('Guest mode is read-only');
}

/// Signature verification for events received from relays.
bool verifyEventSignature(NostrEvent event) {
  if (!event.verifyId()) return false;
  try {
    return bip340.verify(event.pubkey, event.id, event.sig);
  } catch (_) {
    return false;
  }
}
