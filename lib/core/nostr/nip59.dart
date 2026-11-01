import 'dart:convert';
import 'dart:math';

import 'event.dart';
import 'signer.dart';

/// An unsigned event (NIP-59 "rumor"): it has an id but no signature, so a
/// leaked copy proves nothing about who wrote it.
class Rumor {
  final String id;
  final String pubkey;
  final int createdAt;
  final int kind;
  final List<List<String>> tags;
  final String content;

  const Rumor({
    required this.id,
    required this.pubkey,
    required this.createdAt,
    required this.kind,
    required this.tags,
    required this.content,
  });

  factory Rumor.create({
    required String pubkey,
    required int kind,
    required List<List<String>> tags,
    required String content,
    int? createdAt,
  }) {
    final ts = createdAt ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return Rumor(
      id: NostrEvent.computeId(
        pubkey: pubkey,
        createdAt: ts,
        kind: kind,
        tags: tags,
        content: content,
      ),
      pubkey: pubkey,
      createdAt: ts,
      kind: kind,
      tags: tags,
      content: content,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'pubkey': pubkey,
    'created_at': createdAt,
    'kind': kind,
    'tags': tags,
    'content': content,
  };

  /// Parses a rumor and checks that its id matches its content.
  static Rumor? tryParse(Map<String, dynamic> json) {
    try {
      final tags = [
        for (final t in (json['tags'] as List))
          [for (final v in (t as List)) v.toString()],
      ];
      final rumor = Rumor(
        id: json['id'] as String,
        pubkey: json['pubkey'] as String,
        createdAt: (json['created_at'] as num).toInt(),
        kind: (json['kind'] as num).toInt(),
        tags: tags,
        content: json['content'] as String? ?? '',
      );
      final expected = NostrEvent.computeId(
        pubkey: rumor.pubkey,
        createdAt: rumor.createdAt,
        kind: rumor.kind,
        tags: rumor.tags,
        content: rumor.content,
      );
      return expected == rumor.id ? rumor : null;
    } catch (_) {
      return null;
    }
  }

  String? firstTag(String name) {
    for (final t in tags) {
      if (t.length > 1 && t[0] == name) return t[1];
    }
    return null;
  }
}

/// NIP-59 gift wrapping: rumor → seal (kind 13, signed by the author,
/// NIP-44 encrypted to the recipient) → gift wrap (kind 1059, signed by a
/// throw-away key, encrypted again). Relays only ever see the wrap: not who
/// wrote it, not when, not what.
abstract final class GiftWrap {
  static const _twoDays = 2 * 24 * 3600;

  /// A timestamp up to two days in the past, so relays cannot correlate the
  /// wrap with the real send time.
  static int randomPastTimestamp([Random? random, int? now]) {
    final r = random ?? Random.secure();
    final t = now ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return t - r.nextInt(_twoDays);
  }

  /// Wraps [rumor] for [recipient]. [signer] is the author: it encrypts the
  /// seal to the recipient and signs it (one Amber/bunker round-trip each).
  static Future<NostrEvent> wrap({
    required Signer signer,
    required Rumor rumor,
    required String recipient,
    Random? random,

    /// Extra tags on the outer wrap only, e.g. a NIP-40 `expiration` so
    /// relays can forget a Story when it expires.
    List<List<String>> wrapTags = const [],
  }) async {
    final sealed = await signer.nip44Encrypt(
      recipient,
      jsonEncode(rumor.toJson()),
    );
    final seal = await signer.signEvent(
      kind: NostrKinds.seal,
      tags: const [],
      content: sealed,
      createdAt: randomPastTimestamp(random),
    );
    final ephemeral = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
    final wrapped = await ephemeral.nip44Encrypt(
      recipient,
      jsonEncode(seal.toJson()),
    );
    return ephemeral.signEvent(
      kind: NostrKinds.giftWrap,
      tags: [
        ['p', recipient],
        ...wrapTags,
      ],
      content: wrapped,
      createdAt: randomPastTimestamp(random),
    );
  }

  /// Opens a gift wrap addressed to [signer]'s user. Returns null for
  /// anything that is not a valid wrap/seal/rumor chain — wrong recipient,
  /// bad signature, or a seal author different from the rumor author
  /// (which would allow impersonation).
  static Future<Rumor?> unwrap({
    required Signer signer,
    required NostrEvent wrap,
  }) async {
    final me = signer.publicKey;
    if (me == null || wrap.kind != NostrKinds.giftWrap) return null;
    if (wrap.firstTagValue('p') != me) return null;
    try {
      final sealJson = await signer.nip44Decrypt(wrap.pubkey, wrap.content);
      final seal = NostrEvent.fromJson(
        jsonDecode(sealJson) as Map<String, dynamic>,
      );
      if (seal.kind != NostrKinds.seal || !verifyEventSignature(seal)) {
        return null;
      }
      final rumorJson = await signer.nip44Decrypt(seal.pubkey, seal.content);
      final rumor = Rumor.tryParse(
        jsonDecode(rumorJson) as Map<String, dynamic>,
      );
      if (rumor == null || rumor.pubkey != seal.pubkey) return null;
      return rumor;
    } on SignerException {
      rethrow;
    } catch (_) {
      return null;
    }
  }
}
