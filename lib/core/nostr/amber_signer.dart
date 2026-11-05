import 'dart:async';

import 'package:flutter/services.dart';

import '../../l10n/strings.dart';
import '../nostr/event.dart';
import '../nostr/nip19.dart';
import '../nostr/signer.dart';

/// NIP-55 signer backed by Amber (Android). All signing happens inside
/// Amber; the private key never enters this process.
///
/// Requests are served by the native side in two ways: first silently
/// through Amber's content provider (works once the user ticked "remember my
/// choice" in Amber — no UI, which is what makes reading many private
/// messages bearable), then through the regular intent flow with Amber's
/// approval screen.
class AmberSigner extends Signer {
  static const _channel = MethodChannel('app.mialuna.social/amber');

  /// The native bridge handles one request at a time; everything is queued.
  static Future<void> _lock = Future<void>.value();

  static Future<T> _serial<T>(Future<T> Function() op) {
    final completer = Completer<T>();
    _lock = _lock.then((_) async {
      try {
        completer.complete(await op());
      } catch (e, s) {
        completer.completeError(e, s);
      }
    });
    return completer.future;
  }

  @override
  final String publicKey;

  AmberSigner._(this.publicKey);

  /// Rebuilds a signer from the stored public key, without opening Amber.
  /// Amber is only contacted when something actually has to be signed.
  factory AmberSigner.restore(String publicKey) =>
      AmberSigner._(normalizePubkey(publicKey));

  /// Amber returns the public key as hex or as an `npub…` string depending on
  /// the version; the app only ever works with lowercase hex.
  static String normalizePubkey(String raw) {
    final v = raw.trim();
    if (v.startsWith('npub1')) return Nip19.decodeNpub(v);
    if (RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(v)) return v.toLowerCase();
    throw SignerException(AppStrings.current.amberInvalidKey);
  }

  /// Returns true when Amber (or another NIP-55 signer) is installed.
  static Future<bool> isAvailable() async {
    try {
      return await _channel.invokeMethod<bool>('isSignerAvailable') ?? false;
    } on MissingPluginException {
      return false; // non-Android platforms
    }
  }

  /// Asks Amber for the current user's public key (permission prompt).
  static Future<AmberSigner> connect() => _serial(() async {
    try {
      final pubkey = await _channel.invokeMethod<String>('getPublicKey');
      if (pubkey == null || pubkey.isEmpty) {
        throw SignerException(AppStrings.current.amberNoKey);
      }
      return AmberSigner._(normalizePubkey(pubkey));
    } on PlatformException catch (e) {
      throw SignerException(
        e.message ?? AppStrings.current.amberRequestRejected,
      );
    } on MissingPluginException {
      throw SignerException(AppStrings.current.amberAndroidOnly);
    }
  });

  @override
  SignerType get type => SignerType.amber;

  @override
  bool get canSign => true;

  @override
  bool get canEncrypt => true;

  Map<String, Object?> get _userArgs => {
    'current_user': publicKey,
    'current_user_npub': Nip19.encodeNpub(publicKey),
  };

  @override
  Future<NostrEvent> signEvent({
    required int kind,
    required List<List<String>> tags,
    required String content,
    int? createdAt,
  }) {
    final ts = createdAt ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final id = NostrEvent.computeId(
      pubkey: publicKey,
      createdAt: ts,
      kind: kind,
      tags: tags,
      content: content,
    );
    return _serial(() async {
      try {
        final sig = await _channel
            .invokeMethod<String>('signEvent', {
              'id': id,
              'pubkey': publicKey,
              'created_at': ts,
              'kind': kind,
              'tags': tags,
              'content': content,
              ..._userArgs,
            })
            .timeout(const Duration(seconds: 90));
        if (sig == null || sig.isEmpty) {
          throw SignerException(AppStrings.current.amberEmptySignature);
        }
        final event = NostrEvent(
          id: id,
          pubkey: publicKey,
          createdAt: ts,
          kind: kind,
          tags: tags,
          content: content,
          sig: sig,
        );
        if (!verifyEventSignature(event)) {
          throw SignerException(AppStrings.current.signerInvalidResponse);
        }
        return event;
      } on PlatformException catch (e) {
        throw SignerException(
          e.message ?? AppStrings.current.amberSignRejected,
        );
      } on TimeoutException {
        throw SignerException(AppStrings.current.amberTimeout);
      }
    });
  }

  Future<String> _crypto(String method, String peer, String text) =>
      _serial(() async {
        try {
          final out = await _channel
              .invokeMethod<String>(method, {
                'pubkey': peer,
                'text': text,
                ..._userArgs,
              })
              .timeout(const Duration(seconds: 90));
          if (out == null) {
            throw SignerException(AppStrings.current.amberEmptyResponse);
          }
          return out;
        } on PlatformException catch (e) {
          throw SignerException(
            e.message ?? AppStrings.current.amberRequestRejected,
          );
        } on TimeoutException {
          throw SignerException(AppStrings.current.amberTimeout);
        }
      });

  @override
  Future<String> nip44Encrypt(String peerPubkey, String plaintext) =>
      _crypto('nip44Encrypt', peerPubkey, plaintext);

  @override
  Future<String> nip44Decrypt(String peerPubkey, String ciphertext) =>
      _crypto('nip44Decrypt', peerPubkey, ciphertext);
}
