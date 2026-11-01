import 'dart:async';

import 'package:flutter/services.dart';

import '../nostr/event.dart';
import '../nostr/signer.dart';

/// NIP-55 signer backed by Amber (Android). All signing happens inside
/// Amber; the private key never enters this process.
class AmberSigner extends Signer {
  static const _channel = MethodChannel('app.mialuna.social/amber');

  @override
  final String publicKey;

  AmberSigner._(this.publicKey);

  /// Returns true when Amber (or another NIP-55 signer) is installed.
  static Future<bool> isAvailable() async {
    try {
      return await _channel.invokeMethod<bool>('isSignerAvailable') ?? false;
    } on MissingPluginException {
      return false; // non-Android platforms
    }
  }

  /// Asks Amber for the current user's public key (permission prompt).
  static Future<AmberSigner> connect() async {
    try {
      final pubkey = await _channel.invokeMethod<String>('getPublicKey');
      if (pubkey == null || pubkey.isEmpty) {
        throw const SignerException('Amber returned no public key');
      }
      return AmberSigner._(pubkey);
    } on PlatformException catch (e) {
      throw SignerException(e.message ?? 'Amber request rejected');
    } on MissingPluginException {
      throw const SignerException('Amber is only available on Android');
    }
  }

  @override
  SignerType get type => SignerType.amber;

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
    try {
      final sig = await _channel
          .invokeMethod<String>('signEvent', {
            'id': id,
            'pubkey': publicKey,
            'created_at': ts,
            'kind': kind,
            'tags': tags,
            'content': content,
          })
          .timeout(const Duration(seconds: 60));
      if (sig == null || sig.isEmpty) {
        throw const SignerException('Amber returned an empty signature');
      }
      return NostrEvent(
        id: id,
        pubkey: publicKey,
        createdAt: ts,
        kind: kind,
        tags: tags,
        content: content,
        sig: sig,
      );
    } on PlatformException catch (e) {
      throw SignerException(e.message ?? 'Amber signing failed');
    } on TimeoutException {
      throw const SignerException('Amber signing timed out');
    }
  }
}
