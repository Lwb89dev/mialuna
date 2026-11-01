import 'dart:convert';

import 'package:http/http.dart' as http;

import '../nostr/bech32.dart';
import '../nostr/signer.dart';

class ZapException implements Exception {
  final String message;
  const ZapException(this.message);
  @override
  String toString() => 'ZapException: $message';
}

class ZapInvoice {
  final String bolt11;
  final int amountSats;
  const ZapInvoice(this.bolt11, this.amountSats);
}

/// NIP-57 zaps: resolves lud16/lud06 Lightning addresses, builds a signed
/// kind 9734 zap request and fetches a BOLT-11 invoice from the LNURL
/// endpoint. Payment happens in the user's own Lightning wallet.
class ZapService {
  final http.Client _http;
  ZapService({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  /// Extracts a lightning address from kind 0 content JSON.
  static String? lightningAddress(Map<String, dynamic> profileJson) {
    final lud16 = profileJson['lud16'] as String?;
    if (lud16 != null && lud16.contains('@')) return lud16;
    return profileJson['lud06'] as String?; // bech32 LNURL
  }

  Future<ZapInvoice> requestInvoice({
    required Signer signer,
    required String lightningAddressOrLnurl,
    required String recipientPubkey,
    required int amountSats,
    String? eventId,
    List<String> relays = const [],
    String comment = '',
  }) async {
    final callback = await _resolveCallback(lightningAddressOrLnurl);
    final amountMsats = amountSats * 1000;

    final zapRequest = await signer.signEvent(
      kind: 9734,
      tags: [
        ['p', recipientPubkey],
        if (eventId != null) ['e', eventId],
        ['amount', '$amountMsats'],
        if (relays.isNotEmpty) ['relays', ...relays],
      ],
      content: comment,
    );

    final uri = Uri.parse(callback).replace(
      queryParameters: {
        'amount': '$amountMsats',
        'nostr': jsonEncode(zapRequest.toJson()),
        if (comment.isNotEmpty) 'comment': comment,
      },
    );
    final resp = await _http.get(uri);
    if (resp.statusCode != 200) {
      throw ZapException('LNURL callback failed (${resp.statusCode})');
    }
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final pr = json['pr'] as String?;
    if (pr == null) {
      throw ZapException(json['reason'] as String? ?? 'No invoice returned');
    }
    return ZapInvoice(pr, amountSats);
  }

  Future<String> _resolveCallback(String addressOrLnurl) async {
    final Uri wellKnown;
    if (addressOrLnurl.contains('@')) {
      final parts = addressOrLnurl.split('@');
      wellKnown = Uri.parse(
        'https://${parts[1]}/.well-known/lnurlp/${parts[0]}',
      );
    } else {
      // lud06: bech32-encoded LNURL
      final (hrp, data) = Bech32.decode(addressOrLnurl);
      if (hrp != 'lnurl') throw const ZapException('Invalid lud06');
      wellKnown = Uri.parse(utf8.decode(data));
    }
    final resp = await _http.get(wellKnown);
    if (resp.statusCode != 200) {
      throw ZapException('LNURL endpoint unreachable (${resp.statusCode})');
    }
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    if (json['allowsNostr'] != true) {
      throw const ZapException('Questo indirizzo non supporta gli zap Nostr');
    }
    final callback = json['callback'] as String?;
    if (callback == null) throw const ZapException('LNURL callback missing');
    return callback;
  }
}
