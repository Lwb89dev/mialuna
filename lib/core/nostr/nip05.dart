import 'dart:convert';

import 'package:http/http.dart' as http;

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
  /// hosts are contacted.
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
    final http0 = client ?? http.Client();
    try {
      final response = await http0
          .get(Uri.https(domain, '/.well-known/nostr.json', {'name': name}))
          .timeout(timeout);
      if (response.statusCode != 200) return null;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final names = json['names'] as Map<String, dynamic>?;
      final pubkey = names?[name];
      if (pubkey is String && RegExp(r'^[0-9a-f]{64}$').hasMatch(pubkey)) {
        return pubkey;
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      if (client == null) http0.close();
    }
  }

  /// True only when the domain really maps the name to [pubkey].
  static Future<bool> verify(
    String identifier,
    String pubkey, {
    http.Client? client,
  }) async => (await resolve(identifier, client: client)) == pubkey;
}
