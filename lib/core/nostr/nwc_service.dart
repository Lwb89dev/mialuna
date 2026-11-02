import 'dart:async';
import 'dart:convert';

import 'package:bip340/bip340.dart' as bip340;

import '../../l10n/strings.dart';
import 'event.dart';
import 'filter.dart';
import 'nip04.dart';
import 'nip44.dart';
import 'relay.dart' show isAcceptableRelayUrl, normalizeRelayUrl;
import 'relay_pool.dart';
import 'signer.dart';

class NwcException implements Exception {
  final String message;
  const NwcException(this.message);
  @override
  String toString() => 'NwcException: $message';
}

/// Parsed Nostr Wallet Connect connection string:
/// `nostr+walletconnect://<wallet-pubkey>?relay=wss://…&secret=<hex>`
class NwcConnection {
  final String walletPubkey;
  final List<String> relays;

  /// Secret client key of the connection (never leaves the device).
  final String secret;
  final String? lud16;

  const NwcConnection({
    required this.walletPubkey,
    required this.relays,
    required this.secret,
    this.lud16,
  });

  static NwcConnection parse(String uri) {
    final parsed = Uri.tryParse(uri.trim());
    if (parsed == null ||
        (parsed.scheme != 'nostr+walletconnect' &&
            parsed.scheme != 'nostrwalletconnect') ||
        parsed.host.length != 64) {
      throw NwcException(AppStrings.current.nwcInvalidUri);
    }
    final relays = [
      for (final r in parsed.queryParametersAll['relay'] ?? const <String>[])
        if (normalizeRelayUrl(r) != null &&
            isAcceptableRelayUrl(normalizeRelayUrl(r)!))
          normalizeRelayUrl(r)!,
    ];
    if (relays.isEmpty) {
      throw NwcException(AppStrings.current.nwcNoRelay);
    }
    final secret = parsed.queryParameters['secret'];
    if (secret == null || !RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(secret)) {
      throw NwcException(AppStrings.current.nwcNoSecret);
    }
    return NwcConnection(
      walletPubkey: parsed.host.toLowerCase(),
      relays: relays,
      secret: secret.toLowerCase(),
      lud16: parsed.queryParameters['lud16'],
    );
  }

  String get clientPubkey => bip340.getPublicKey(secret);

  String toUri() {
    final params = [
      ...relays.map((r) => 'relay=${Uri.encodeQueryComponent(r)}'),
      'secret=$secret',
      if (lud16 != null) 'lud16=${Uri.encodeQueryComponent(lud16!)}',
    ];
    return 'nostr+walletconnect://$walletPubkey?${params.join('&')}';
  }
}

/// NIP-47 Nostr Wallet Connect client: pays BOLT-11 invoices through the
/// user's own wallet service. NIP-44 encryption is preferred with a NIP-04
/// fallback for older wallets.
class NwcService {
  static const requestKind = 23194;
  static const responseKind = 23195;

  /// Builds the signed `pay_invoice` request event (NIP-44 encrypted).
  static Future<NostrEvent> buildPayInvoiceRequest(
    NwcConnection conn,
    String bolt11, {
    bool useNip44 = true,
  }) {
    final payload = jsonEncode({
      'method': 'pay_invoice',
      'params': {'invoice': bolt11},
    });
    final content = useNip44
        ? Nip44.encrypt(
            privateKeyHex: conn.secret,
            publicKeyHex: conn.walletPubkey,
            plaintext: payload,
          )
        : Nip04.encrypt(
            privateKeyHex: conn.secret,
            publicKeyHex: conn.walletPubkey,
            plaintext: payload,
          );
    return NsecSigner.fromNsec(conn.secret).signEvent(
      kind: requestKind,
      tags: [
        ['p', conn.walletPubkey],
      ],
      content: content,
    );
  }

  /// Sends the invoice to the wallet and waits for the preimage.
  /// Tries NIP-44 first, retries with NIP-04 on timeout.
  Future<String> payInvoice(
    NwcConnection conn,
    String bolt11, {
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      return await _pay(conn, bolt11, useNip44: true, timeout: timeout);
    } on NwcException catch (e) {
      if (e.message != AppStrings.current.nwcTimeout) rethrow;
      return _pay(conn, bolt11, useNip44: false, timeout: timeout);
    }
  }

  Future<String> _pay(
    NwcConnection conn,
    String bolt11, {
    required bool useNip44,
    required Duration timeout,
  }) async {
    final pool = RelayPool([for (final r in conn.relays) RelayConfig(r)]);
    pool.connect();
    try {
      final request = await buildPayInvoiceRequest(
        conn,
        bolt11,
        useNip44: useNip44,
      );
      final poolSub = pool.subscribe([
        NostrFilter(
          kinds: const [responseKind],
          tagFilters: {
            '#p': [conn.clientPubkey],
            '#e': [request.id],
          },
        ),
      ]);
      final completer = Completer<String>();
      final sub = poolSub.events.listen((event) {
        if (event.pubkey != conn.walletPubkey) return;
        try {
          final plaintext = useNip44 && !event.content.contains('?iv=')
              ? Nip44.decrypt(
                  privateKeyHex: conn.secret,
                  publicKeyHex: conn.walletPubkey,
                  payload: event.content,
                )
              : Nip04.decrypt(
                  privateKeyHex: conn.secret,
                  publicKeyHex: conn.walletPubkey,
                  payload: event.content,
                );
          final response = jsonDecode(plaintext) as Map<String, dynamic>;
          final error = response['error'];
          if (error != null && !completer.isCompleted) {
            completer.completeError(
              NwcException('${error['message'] ?? error['code'] ?? error}'),
            );
            return;
          }
          final result = response['result'] as Map<String, dynamic>?;
          final preimage = result?['preimage'] as String?;
          if (preimage != null && !completer.isCompleted) {
            completer.complete(preimage);
          }
        } catch (_) {}
      });
      await pool.publish(request);
      try {
        return await completer.future.timeout(
          timeout,
          onTimeout: () => throw NwcException(AppStrings.current.nwcTimeout),
        );
      } finally {
        await sub.cancel();
        poolSub.close();
      }
    } finally {
      await pool.dispose();
    }
  }
}
