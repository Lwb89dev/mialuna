import 'package:http/http.dart' as http;

import '../net/safe_http.dart';
import 'relay.dart' show isPublicHost;

/// NIP-05: `name@domain` identifiers resolved through
/// `https://domain/.well-known/nostr.json?name=name`.
abstract final class Nip05 {
  static final _pattern = RegExp(
    r'^(?:([\w.+-]+)@)?([a-z0-9-]+(?:\.[a-z0-9-]+)+)$',
  );

  /// True when [input] looks like `name@domain.tld` (or just `domain.tld`).
  static bool looksLikeIdentifier(String input) =>
      _pattern.hasMatch(input.trim().toLowerCase()) &&
      input.trim().contains('.');

  /// The hex pubkey [identifier] maps to, or null. Never throws; only public
  /// hosts are contacted (by name and by address), no redirect is followed and
  /// the answer is capped (see [SafeHttp]).
  static Future<String?> resolve(
    String identifier, {
    http.Client? client,
    Duration timeout = const Duration(seconds: 6),
  }) async {
    final match = _pattern.firstMatch(identifier.trim().toLowerCase());
    if (match == null) return null;
    final name = match.group(1) ?? '_';
    final domain = match.group(2)!;
    if (!isPublicHost(domain)) return null;
    try {
      final json = await SafeHttp.getJson(
        Uri.https(domain, '/.well-known/nostr.json', {'name': name}),
        client: client,
        timeout: timeout,
      );
      final names = json is Map ? json['names'] : null;
      final pubkey = names is Map ? names[name] : null;
      if (pubkey is String && RegExp(r'^[0-9a-f]{64}$').hasMatch(pubkey)) {
        return pubkey;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// True only when the domain really maps the name to [pubkey].
  static Future<bool> verify(
    String identifier,
    String pubkey, {
    http.Client? client,
  }) async => (await resolve(identifier, client: client)) == pubkey;
}
