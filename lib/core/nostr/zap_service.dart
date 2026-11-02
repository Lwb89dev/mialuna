import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../l10n/strings.dart';
import '../net/safe_http.dart';
import '../nostr/bech32.dart';
import 'bolt11.dart';
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

  /// Extracts the zap request embedded in the receipt's `description` tag.
  /// Returns null when the receipt is malformed — or when it cannot be
  /// trusted to say who zapped: the request must be a kind 9734 whose
  /// signature checks out (so nobody can put somebody else's name on a zap)
  /// and that is addressed to the same person as the receipt. The amount is
  /// the one of the paid invoice (`bolt11`), which is what was actually
  /// asked for, rather than what the sender claims.
  static ZapReceipt? fromEvent(NostrEvent event) {
    if (event.kind != NostrKinds.zapReceipt) return null;
    final description = event.firstTagValue('description');
    if (description == null) return null;
    try {
      final request = NostrEvent.fromJson(
        jsonDecode(description) as Map<String, dynamic>,
      );
      if (request.kind != NostrKinds.zapRequest ||
          !verifyEventSignature(request) ||
          request.firstTagValue('p') != event.firstTagValue('p')) {
        return null;
      }
      var requested = 0;
      String? eventId;
      for (final tag in request.tags) {
        if (tag.length < 2) continue;
        if (tag[0] == 'amount') requested = int.tryParse(tag[1]) ?? 0;
        if (tag[0] == 'e') eventId = tag[1];
      }
      final bolt11 = event.firstTagValue('bolt11');
      final paid = bolt11 == null ? null : Bolt11.amountMsats(bolt11);
      final msats = paid?.toInt() ?? requested;
      return ZapReceipt(
        sender: request.pubkey,
        amountSats: msats ~/ 1000,
        comment: request.content,
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

  /// `name@domain.tld`, nothing else: no port, path, query or credentials
  /// can ride along in a Lightning address.
  static final _lud16 = RegExp(
    r'^([a-z0-9._+-]{1,64})@([a-z0-9-]+(?:\.[a-z0-9-]+)+)$',
  );

  /// Fetches the recipient's LNURL-pay parameters (callback, limits). Only
  /// public https hosts are contacted (see [SafeHttp]).
  Future<LnurlPayInfo> fetchPayInfo(String addressOrLnurl) async {
    final Uri wellKnown;
    if (addressOrLnurl.contains('@')) {
      final m = _lud16.firstMatch(addressOrLnurl.trim().toLowerCase());
      if (m == null) throw const ZapException('Invalid Lightning address');
      wellKnown = Uri.https(m.group(2)!, '/.well-known/lnurlp/${m.group(1)}');
    } else {
      // lud06: bech32-encoded LNURL
      final (hrp, data) = Bech32.decode(addressOrLnurl);
      if (hrp != 'lnurl') throw const ZapException('Invalid lud06');
      wellKnown = Uri.parse(utf8.decode(data));
    }
    final Object? decoded;
    try {
      decoded = await SafeHttp.getJson(wellKnown, client: _http);
    } on SafeHttpException catch (e) {
      throw ZapException('LNURL endpoint: ${e.message}');
    }
    if (decoded is! Map) throw const ZapException('LNURL answer unreadable');
    final json = decoded;
    if (json['allowsNostr'] != true) {
      throw ZapException(AppStrings.current.zapNotSupported);
    }
    final callback = json['callback'];
    if (callback is! String || Uri.tryParse(callback)?.scheme != 'https') {
      throw const ZapException('LNURL callback missing or not https');
    }
    int whole(Object? v, int fallback) => v is num ? v.toInt() : fallback;
    final minMsats = whole(json['minSendable'], 1000);
    final maxMsats = whole(json['maxSendable'], 100000000000);
    return LnurlPayInfo(
      callback: callback,
      minSats: (minMsats / 1000).ceil(),
      maxSats: maxMsats ~/ 1000,
      commentAllowed: whole(json['commentAllowed'], 0),
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
        AppStrings.current.zapAmountOutOfRange(info.minSats, info.maxSats),
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

    final callback = Uri.parse(info.callback);
    final uri = callback.replace(
      // A callback may carry a query of its own (`?k1=…`): keep it.
      queryParameters: {
        ...callback.queryParameters,
        'amount': '$amountMsats',
        'nostr': jsonEncode(zapRequest.toJson()),
        if (comment.isNotEmpty) 'comment': comment,
      },
    );
    final Object? decoded;
    try {
      decoded = await SafeHttp.getJson(uri, client: _http);
    } on SafeHttpException catch (e) {
      throw ZapException('LNURL callback: ${e.message}');
    }
    final json = decoded is Map ? decoded : const {};
    final pr = json['pr'];
    if (pr is! String) {
      final reason = json['reason'];
      throw ZapException(reason is String ? reason : 'No invoice returned');
    }
    // What would be paid must be what was asked for: a Nostr Wallet Connect
    // wallet pays at once, with no screen to check the amount on.
    if (Bolt11.amountMsats(pr) != BigInt.from(amountMsats)) {
      throw ZapException(AppStrings.current.zapInvoiceMismatch);
    }
    return ZapInvoice(pr, amountSats);
  }
}
