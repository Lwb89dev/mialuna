import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../nostr/relay.dart' show isPublicHost;

class SafeHttpException implements Exception {
  final String message;
  final int? status;
  const SafeHttpException(this.message, {this.status});
  @override
  String toString() => 'SafeHttpException: $message';
}

/// How a name is turned into addresses (tests replace it: no DNS in CI).
typedef HostResolver = Future<List<InternetAddress>> Function(String host);

/// GETs of JSON from a host somebody else chose: the domain of a NIP-05 name,
/// a Lightning address, an LNURL callback. All of those can be made to point
/// at the user's own network (`http://192.168.1.1/…`, a name that resolves to
/// 127.0.0.1, a redirect to a router's admin page), so before anything is
/// sent:
///
/// * only `https`, no credentials in the URL;
/// * the host is public — by its spelling *and* by what it resolves to;
/// * redirects are not followed (NIP-05 forbids them, and a redirect is the
///   easiest way past the checks above);
/// * the answer is cut off after [maxJsonBytes].
///
/// A name that resolves differently when the connection is actually made
/// (DNS rebinding) is not caught by a check done beforehand; that residual
/// window is small, and what is sent is a plain GET.
abstract final class SafeHttp {
  static HostResolver resolver = InternetAddress.lookup;
  static const maxJsonBytes = 128 * 1024;

  /// Whether [a] is an address on the public internet.
  static bool isPublicAddress(InternetAddress a) {
    if (a.isLoopback || a.isLinkLocal || a.isMulticast) return false;
    final b = a.rawAddress;
    if (a.type == InternetAddressType.IPv4) {
      final x = b[0], y = b[1];
      if (x == 0 || x == 10 || x == 127) return false;
      if (x == 100 && y >= 64 && y <= 127) return false; // carrier-grade NAT
      if (x == 169 && y == 254) return false;
      if (x == 172 && y >= 16 && y <= 31) return false;
      if (x == 192 && y == 168) return false;
      if (x == 192 && y == 0 && b[2] == 0) return false; // 192.0.0.0/24
      if (x == 198 && (y == 18 || y == 19)) return false; // benchmarking
      if (x >= 224) return false; // multicast, reserved, broadcast
      return true;
    }
    if (b.length != 16) return false;
    // ::ffff:a.b.c.d — judged by the IPv4 address inside.
    final mapped =
        b.sublist(0, 10).every((v) => v == 0) && b[10] == 0xff && b[11] == 0xff;
    if (mapped) {
      return isPublicAddress(
        InternetAddress.fromRawAddress(
          Uint8List.fromList(b.sublist(12)),
          type: InternetAddressType.IPv4,
        ),
      );
    }
    if (b.every((v) => v == 0)) return false; // ::
    if ((b[0] & 0xfe) == 0xfc) return false; // unique local fc00::/7
    if (b[0] == 0x20 && b[1] == 0x01 && b[2] == 0x0d && b[3] == 0xb8) {
      return false; // documentation 2001:db8::/32
    }
    return (b[0] & 0xe0) == 0x20; // global unicast 2000::/3 only
  }

  /// A public host name or address, checked by spelling and by resolution.
  static Future<bool> isPublicHostname(String host) async {
    if (!isPublicHost(host)) return false;
    final literal = InternetAddress.tryParse(host);
    if (literal != null) return isPublicAddress(literal);
    try {
      final found = await resolver(host).timeout(const Duration(seconds: 5));
      return found.isNotEmpty && found.every(isPublicAddress);
    } catch (_) {
      return false;
    }
  }

  /// [uri]'s answer as JSON. Throws [SafeHttpException] for everything that
  /// is not a plain 200 with a small JSON body from a public https host.
  static Future<Object?> getJson(
    Uri uri, {
    http.Client? client,
    Duration timeout = const Duration(seconds: 8),
    int maxBytes = maxJsonBytes,
  }) async {
    if (uri.scheme != 'https' || uri.host.isEmpty || uri.userInfo.isNotEmpty) {
      throw const SafeHttpException('only plain https addresses are used');
    }
    if (!await isPublicHostname(uri.host)) {
      throw const SafeHttpException('not a public host');
    }
    final http0 = client ?? http.Client();
    try {
      final request = http.Request('GET', uri)
        ..followRedirects = false
        ..headers['Accept'] = 'application/json';
      final response = await http0.send(request).timeout(timeout);
      if (response.statusCode != 200) {
        unawaited(response.stream.drain<void>().catchError((_) {}));
        throw SafeHttpException(
          'HTTP ${response.statusCode}',
          status: response.statusCode,
        );
      }
      final text = await readBounded(response.stream, maxBytes, timeout);
      return jsonDecode(text);
    } on FormatException {
      throw const SafeHttpException('not JSON');
    } finally {
      if (client == null) http0.close();
    }
  }

  /// The text of [stream], or an exception once it grows past [maxBytes].
  static Future<String> readBounded(
    Stream<List<int>> stream,
    int maxBytes,
    Duration timeout,
  ) async {
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in stream.timeout(timeout)) {
      bytes.add(chunk);
      if (bytes.length > maxBytes) {
        throw const SafeHttpException('the answer is too big');
      }
    }
    return utf8.decode(bytes.takeBytes(), allowMalformed: true);
  }
}
