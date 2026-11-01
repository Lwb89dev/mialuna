// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bip340/bip340.dart' as bip340;

import 'bech32.dart';
import 'event.dart';
import 'filter.dart';
import 'nip04.dart';
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
class BunkerSigner extends Signer {
  final String _localPrivkey;
  final String _remotePubkey;
  final RelayPool _pool;
  @override
  final String publicKey;

  final _pendingRequests = <String, Completer<Map<String, dynamic>>>{};
  StreamSubscription? _sub;
  String? _subId;

  BunkerSigner._({
    required String localPrivkey,
    required String remotePubkey,
    required this.publicKey,
    required RelayPool pool,
  }) : _localPrivkey = localPrivkey,
       _remotePubkey = remotePubkey,
       _pool = pool;

  /// Connects to a bunker URL:
  /// `bunker://<remote-pubkey>?relay=wss://…&relay=…&secret=…`
  static Future<BunkerSigner> connect(
    String bunkerUrl, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final uri = Uri.tryParse(bunkerUrl.trim());
    if (uri == null || uri.scheme != 'bunker' || uri.host.length != 64) {
      throw const BunkerException('URL bunker non valido');
    }
    final relays = uri.queryParametersAll['relay'] ?? const [];
    if (relays.isEmpty) {
      throw const BunkerException('Il bunker non indica alcun relay');
    }
    final secret = uri.queryParameters['secret'];

    final rng = Random.secure();
    final localPriv = bytesToHex(
      List<int>.generate(32, (_) => rng.nextInt(256)),
    );
    final localPub = bip340.getPublicKey(localPriv);
    final pool = RelayPool(relays);
    pool.connect();

    final tempSigner = NsecSigner.fromNsec(localPriv);
    final pending = <String, Completer<Map<String, dynamic>>>{};
    final (:id, :stream) = pool.subscribe([
      NostrFilter(
        kinds: const [24133],
        tagFilters: {
          '#p': [localPub],
        },
      ),
    ]);
    final sub = stream.listen((event) {
      if (event.kind != 24133 || event.pubkey != uri.host) return;
      final p = event.firstTagValue('p');
      if (p != localPub) return;
      try {
        final plaintext = Nip04.decrypt(
          privateKeyHex: localPriv,
          publicKeyHex: event.pubkey,
          payload: event.content,
        );
        final response = jsonDecode(plaintext) as Map<String, dynamic>;
        pending.remove(response['id'])?.complete(response);
      } catch (_) {}
    });

    Future<Map<String, dynamic>> rpc(
      String method,
      List<dynamic> params,
    ) async {
      final reqId = bytesToHex(List<int>.generate(8, (_) => rng.nextInt(256)));
      final payload = jsonEncode({
        'id': reqId,
        'method': method,
        'params': params,
      });
      final encrypted = Nip04.encrypt(
        privateKeyHex: localPriv,
        publicKeyHex: uri.host,
        plaintext: payload,
      );
      final event = await tempSigner.signEvent(
        kind: 24133,
        tags: [
          ['p', uri.host],
        ],
        content: encrypted,
      );
      final completer = Completer<Map<String, dynamic>>();
      pending[reqId] = completer;
      await pool.publish(event);
      final response = await completer.future.timeout(
        timeout,
        onTimeout: () => throw BunkerException('Timeout dal bunker'),
      );
      if (response['error'] != null) {
        throw BunkerException('${response['error']}');
      }
      return response;
    }

    try {
      final connectResp = await rpc('connect', [uri.host, ?secret]);
      if (connectResp['result'] == 'auth_url') {
        throw const BunkerException(
          'Il bunker richiede un\'autorizzazione web (auth_url non supportata)',
        );
      }
      final pubkeyResp = await rpc('get_public_key', []);
      final remoteUserPubkey = pubkeyResp['result'] as String?;
      if (remoteUserPubkey == null || remoteUserPubkey.length != 64) {
        throw const BunkerException(
          'Il bunker non ha restituito una chiave valida',
        );
      }
      final signer = BunkerSigner._(
        localPrivkey: localPriv,
        remotePubkey: uri.host,
        publicKey: remoteUserPubkey,
        pool: pool,
      );
      signer._sub = sub;
      signer._subId = id;
      signer._pendingRequests.addAll(pending);
      return signer;
    } catch (e) {
      await sub.cancel();
      pool.unsubscribe(id);
      await pool.dispose();
      rethrow;
    }
  }

  @override
  SignerType get type => SignerType.bunker;

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
    final unsigned = {
      'pubkey': publicKey,
      'created_at': ts,
      'kind': kind,
      'tags': tags,
      'content': content,
    };
    final reqId = bytesToHex(
      List<int>.generate(8, (_) => Random.secure().nextInt(256)),
    );
    final payload = jsonEncode({
      'id': reqId,
      'method': 'sign_event',
      'params': [jsonEncode(unsigned)],
    });
    final encrypted = Nip04.encrypt(
      privateKeyHex: _localPrivkey,
      publicKeyHex: _remotePubkey,
      plaintext: payload,
    );
    final tempSigner = NsecSigner.fromNsec(_localPrivkey);
    final request = await tempSigner.signEvent(
      kind: 24133,
      tags: [
        ['p', _remotePubkey],
      ],
      content: encrypted,
    );
    final completer = Completer<Map<String, dynamic>>();
    _pendingRequests[reqId] = completer;
    await _pool.publish(request);
    final response = await completer.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () => throw const BunkerException('Timeout firma dal bunker'),
    );
    if (response['error'] != null) {
      throw BunkerException('${response['error']}');
    }
    final signed =
        jsonDecode(response['result'] as String) as Map<String, dynamic>;
    return NostrEvent.fromJson(signed);
  }

  @override
  Future<void> dispose() async {
    await _sub?.cancel();
    if (_subId != null) _pool.unsubscribe(_subId!);
    await _pool.dispose();
  }
}
