import 'dart:convert';

import 'package:http/http.dart' as http;

import '../nostr/bech32.dart';
import '../nostr/event.dart';
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

/// LNURL-pay parameters advertised by the recipient's Lightning endpoint.
class LnurlPayInfo {
  final String callback;
  final int minSats;
  final int maxSats;

  /// Maximum comment length accepted by the endpoint; 0 means no comments.
  final int commentAllowed;

  const LnurlPayInfo({
    required this.callback,
    required this.minSats,
    required this.maxSats,
    this.commentAllowed = 0,
  });
}

/// Parsed NIP-57 zap receipt (kind 9735): who zapped, how much, what for.
class ZapReceipt {
  final String sender;
  final int amountSats;
  final String comment;
  final String? eventId;

  const ZapReceipt({
    required this.sender,
    required this.amountSats,
    this.comment = '',
    this.eventId,
  });

  /// Extracts the embedded zap request from the receipt's `description`
  /// tag. Returns null when the receipt is malformed.
  static ZapReceipt? fromEvent(NostrEvent event) {
    if (event.kind != NostrKinds.zapReceipt) return null;
    final description = event.firstTagValue('description');
    if (description == null) return null;
    try {
      final request = jsonDecode(description) as Map<String, dynamic>;
      final sender = request['pubkey'] as String?;
      if (sender == null) return null;
      final tags = (request['tags'] as List?) ?? const [];
      var amountMsats = 0;
      String? eventId;
      for (final tag in tags) {
        if (tag is! List || tag.length < 2) continue;
        if (tag[0] == 'amount') {
          amountMsats = int.tryParse('${tag[1]}') ?? 0;
        } else if (tag[0] == 'e') {
          eventId = '${tag[1]}';
        }
      }
      return ZapReceipt(
        sender: sender,
        amountSats: amountMsats ~/ 1000,
        comment: request['content'] as String? ?? '',
        eventId: eventId,
      );
    } catch (_) {
      return null;
    }
  }
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

  /// Fetches the recipient's LNURL-pay parameters (callback, limits).
  Future<LnurlPayInfo> fetchPayInfo(String addressOrLnurl) async {
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
    final minMsats = json['minSendable'] as int? ?? 1000;
    final maxMsats = json['maxSendable'] as int? ?? 100000000000;
    return LnurlPayInfo(
      callback: callback,
      minSats: (minMsats / 1000).ceil(),
      maxSats: maxMsats ~/ 1000,
      commentAllowed: json['commentAllowed'] as int? ?? 0,
    );
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
    final info = await fetchPayInfo(lightningAddressOrLnurl);
    if (amountSats < info.minSats || amountSats > info.maxSats) {
      throw ZapException(
        'Importo fuori dai limiti (${info.minSats}–${info.maxSats} sats)',
      );
    }
    if (info.commentAllowed == 0 && comment.isNotEmpty) comment = '';
    if (comment.length > info.commentAllowed && info.commentAllowed > 0) {
      comment = comment.substring(0, info.commentAllowed);
    }
    final amountMsats = amountSats * 1000;

    final zapRequest = await signer.signEvent(
      kind: NostrKinds.zapRequest,
      tags: [
        ['p', recipientPubkey],
        if (eventId != null) ['e', eventId],
        ['amount', '$amountMsats'],
        if (relays.isNotEmpty) ['relays', ...relays],
      ],
      content: comment,
    );

    final uri = Uri.parse(info.callback).replace(
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
}
