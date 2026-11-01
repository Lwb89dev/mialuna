import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bip340/bip340.dart' as bip340;

import '../../l10n/strings.dart';
import 'bech32.dart';
import 'event.dart';
import 'filter.dart';
import 'nip04.dart';
import 'nip44.dart';
import 'relay.dart';
import 'relay_pool.dart';
import 'signer.dart';

class BunkerException implements Exception {
  final String message;
  const BunkerException(this.message);
  @override
  String toString() => 'BunkerException: $message';
}

/// NIP-46 remote signer (bunker). Holds only a local ephemeral session key;
/// the user's private key stays on the remote signer.
///
/// Encryption: NIP-44 v2 is preferred; if the remote signer only speaks the
/// legacy NIP-04 scheme we detect it (timeout on connect or `?iv=` payloads)
/// and fall back transparently for the rest of the session.
class BunkerSigner extends Signer {
  final String _localPrivkey;
  final String _remotePubkey;
  final RelayPool _pool;

  @override
  late final String publicKey;

  final _pendingRequests = <String, Completer<Map<String, dynamic>>>{};
  StreamSubscription? _sub;
  PoolSubscription? _poolSub;
  bool _useNip44 = true;

  BunkerSigner._({
    required this._localPrivkey,
    required this._remotePubkey,
    required this._pool,
  });

  /// Connects to a bunker URL:
  /// `bunker://<remote-pubkey>?relay=wss://…&relay=…&secret=…`
  static Future<BunkerSigner> connect(
    String bunkerUrl, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final uri = Uri.tryParse(bunkerUrl.trim());
    if (uri == null || uri.scheme != 'bunker' || uri.host.length != 64) {
      throw BunkerException(AppStrings.current.bunkerInvalidUrl);
    }
    final relays = [
      for (final r in uri.queryParametersAll['relay'] ?? const <String>[])
        ?normalizeRelayUrl(r),
    ];
    if (relays.isEmpty) {
      throw BunkerException(AppStrings.current.bunkerNoRelay);
    }
    final secret = uri.queryParameters['secret'];

    final rng = Random.secure();
    final localPriv = bytesToHex(
      List<int>.generate(32, (_) => rng.nextInt(256)),
    );
    final localPub = bip340.getPublicKey(localPriv);
    final pool = RelayPool([for (final r in relays) RelayConfig(r)]);
    pool.connect();

    final signer = BunkerSigner._(
      localPrivkey: localPriv,
      remotePubkey: uri.host,
      pool: pool,
    );
    final poolSub = pool.subscribe([
      NostrFilter(
        kinds: const [24133],
        tagFilters: {
          '#p': [localPub],
        },
      ),
    ]);
    signer._poolSub = poolSub;
    signer._sub = poolSub.events.listen((event) {
      if (event.kind != 24133 || event.pubkey != uri.host) return;
      final p = event.firstTagValue('p');
      if (p != localPub) return;
      try {
        final plaintext = signer._decrypt(event.content);
        final response = jsonDecode(plaintext) as Map<String, dynamic>;
        signer._pendingRequests.remove(response['id'])?.complete(response);
      } catch (_) {}
    });

    try {
      // NIP-44 first; legacy NIP-04 bunkers never answer and we retry.
      final connectResp = await signer._rpcWithFallback('connect', [
        uri.host,
        ?secret,
      ], timeout);
      if (connectResp['result'] == 'auth_url') {
        throw BunkerException(AppStrings.current.bunkerWebAuth);
      }
      final pubkeyResp = await signer._rpc('get_public_key', [], timeout);
      final remoteUserPubkey = pubkeyResp['result'] as String?;
      if (remoteUserPubkey == null || remoteUserPubkey.length != 64) {
        throw BunkerException(AppStrings.current.bunkerInvalidKey);
      }
      signer.publicKey = remoteUserPubkey;
      return signer;
    } catch (e) {
      await signer.dispose();
      rethrow;
    }
  }

  String _encrypt(String plaintext) => _useNip44
      ? Nip44.encrypt(
          privateKeyHex: _localPrivkey,
          publicKeyHex: _remotePubkey,
          plaintext: plaintext,
        )
      : Nip04.encrypt(
          privateKeyHex: _localPrivkey,
          publicKeyHex: _remotePubkey,
          plaintext: plaintext,
        );

  String _decrypt(String payload) {
    // NIP-04 payloads carry an explicit '?iv=' marker; NIP-44 ones are a
    // versioned base64 envelope. Try the preferred scheme first anyway.
    if (_useNip44 && !payload.contains('?iv=')) {
      try {
        return Nip44.decrypt(
          privateKeyHex: _localPrivkey,
          publicKeyHex: _remotePubkey,
          payload: payload,
        );
      } catch (_) {
        // fall through to legacy
      }
    }
    final plaintext = Nip04.decrypt(
      privateKeyHex: _localPrivkey,
      publicKeyHex: _remotePubkey,
      payload: payload,
    );
    // The peer speaks legacy NIP-04: stick to it for the session.
    _useNip44 = false;
    return plaintext;
  }

  Future<Map<String, dynamic>> _rpc(
    String method,
    List<dynamic> params,
    Duration timeout,
  ) async {
    final rng = Random.secure();
    final reqId = bytesToHex(List<int>.generate(8, (_) => rng.nextInt(256)));
    final payload = jsonEncode({
      'id': reqId,
      'method': method,
      'params': params,
    });
    final encrypted = _encrypt(payload);
    final tempSigner = NsecSigner.fromNsec(_localPrivkey);
    final event = await tempSigner.signEvent(
      kind: 24133,
      tags: [
        ['p', _remotePubkey],
      ],
      content: encrypted,
    );
    final completer = Completer<Map<String, dynamic>>();
    _pendingRequests[reqId] = completer;
    await _pool.publish(event);
    try {
      final response = await completer.future.timeout(
        timeout,
        onTimeout: () =>
            throw BunkerException(AppStrings.current.bunkerTimeout),
      );
      if (response['error'] != null) {
        throw BunkerException('${response['error']}');
      }
      return response;
    } finally {
      _pendingRequests.remove(reqId);
    }
  }

  /// First call of the session: try NIP-44, and on timeout retry once with
  /// legacy NIP-04 for older bunkers.
  Future<Map<String, dynamic>> _rpcWithFallback(
    String method,
    List<dynamic> params,
    Duration timeout,
  ) async {
    try {
      return await _rpc(method, params, timeout);
    } on BunkerException catch (e) {
      if (!_useNip44 || e.message != AppStrings.current.bunkerTimeout) rethrow;
      _useNip44 = false;
      return _rpc(method, params, timeout);
    }
  }

  @override
  SignerType get type => SignerType.bunker;

  @override
  bool get canSign => true;

  @override
  bool get canEncrypt => true;

  @override
  Future<String> nip44Encrypt(String peerPubkey, String plaintext) async {
    final response = await _rpc('nip44_encrypt', [
      peerPubkey,
      plaintext,
    ], const Duration(seconds: 60));
    return response['result'] as String;
  }

  @override
  Future<String> nip44Decrypt(String peerPubkey, String ciphertext) async {
    final response = await _rpc('nip44_decrypt', [
      peerPubkey,
      ciphertext,
    ], const Duration(seconds: 60));
    return response['result'] as String;
  }

  @override
  Future<NostrEvent> signEvent({
    required int kind,
    required List<List<String>> tags,
    required String content,
    int? createdAt,
  }) async {
    final ts = createdAt ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final unsigned = {
      'pubkey': publicKey,
      'created_at': ts,
      'kind': kind,
      'tags': tags,
      'content': content,
    };
    final response = await _rpc('sign_event', [
      jsonEncode(unsigned),
    ], const Duration(seconds: 60));
    final signed =
        jsonDecode(response['result'] as String) as Map<String, dynamic>;
    return NostrEvent.fromJson(signed);
  }

  @override
  Future<void> dispose() async {
    await _sub?.cancel();
    _poolSub?.close();
    await _pool.dispose();
  }
}
