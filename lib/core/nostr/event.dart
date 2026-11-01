import 'dart:convert';

import 'package:crypto/crypto.dart';

/// A Nostr event (NIP-01). Immutable; signing produces a new instance.
class NostrEvent {
  final String id;
  final String pubkey;
  final int createdAt;
  final int kind;
  final List<List<String>> tags;
  final String content;
  final String sig;

  const NostrEvent({
    required this.id,
    required this.pubkey,
    required this.createdAt,
    required this.kind,
    required this.tags,
    required this.content,
    required this.sig,
  });

  /// Unsigned event, before id/signature exist.
  const NostrEvent.unsigned({
    required this.pubkey,
    required this.createdAt,
    required this.kind,
    required this.tags,
    required this.content,
  }) : id = '',
       sig = '';

  bool get isSigned => id.isNotEmpty && sig.isNotEmpty;

  /// NIP-01 serialization used for id hashing and signing.
  String serializeForSigning() =>
      jsonEncode([0, pubkey, createdAt, kind, tags, content]);

  static String computeId({
    required String pubkey,
    required int createdAt,
    required int kind,
    required List<List<String>> tags,
    required String content,
  }) {
    final serialized = jsonEncode([0, pubkey, createdAt, kind, tags, content]);
    return sha256.convert(utf8.encode(serialized)).toString();
  }

  NostrEvent copyWith({String? id, String? sig}) => NostrEvent(
    id: id ?? this.id,
    pubkey: pubkey,
    createdAt: createdAt,
    kind: kind,
    tags: tags,
    content: content,
    sig: sig ?? this.sig,
  );

  factory NostrEvent.fromJson(Map<String, dynamic> json) => NostrEvent(
    id: json['id'] as String,
    pubkey: json['pubkey'] as String,
    createdAt: (json['created_at'] as num).toInt(),
    kind: (json['kind'] as num).toInt(),
    tags: [
      for (final t in (json['tags'] as List))
        [for (final v in (t as List)) v.toString()],
    ],
    content: json['content'] as String? ?? '',
    sig: json['sig'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'pubkey': pubkey,
    'created_at': createdAt,
    'kind': kind,
    'tags': tags,
    'content': content,
    'sig': sig,
  };

  String? firstTagValue(String name) {
    for (final tag in tags) {
      if (tag.isNotEmpty && tag[0] == name && tag.length > 1) return tag[1];
    }
    return null;
  }

  List<List<String>> tagsNamed(String name) =>
      tags.where((t) => t.isNotEmpty && t[0] == name).toList();

  bool verifyId() =>
      computeId(
        pubkey: pubkey,
        createdAt: createdAt,
        kind: kind,
        tags: tags,
        content: content,
      ) ==
      id;

  /// NIP-40 expiration timestamp, null when not set.
  int? get expiration {
    final v = firstTagValue('expiration');
    return v == null ? null : int.tryParse(v);
  }

  bool isExpired([int? nowSeconds]) {
    final exp = expiration;
    if (exp == null) return false;
    final now = nowSeconds ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return exp <= now;
  }

  @override
  bool operator ==(Object other) => other is NostrEvent && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Nostr kinds used by Mialuna.
abstract final class NostrKinds {
  static const profileMetadata = 0;
  static const textNote = 1; // never rendered by Mialuna as a post
  static const followList = 3;
  static const deletion = 5;
  static const reaction = 7;
  static const picture = 20; // NIP-68
  static const video = 21; // NIP-71 normal
  static const shortVideo = 22; // NIP-71 shorts / reels / stories
  static const comment = 1111; // NIP-22
  static const zapRequest = 9734; // NIP-57
  static const zapReceipt = 9735; // NIP-57
  static const blossomAuth = 24242;
  static const addressableVideo = 34235;
  static const addressableShortVideo = 34236;

  /// Kinds Mialuna renders as media posts. Kind 1 is deliberately absent.
  static const mediaKinds = [
    picture,
    video,
    shortVideo,
    addressableVideo,
    addressableShortVideo,
  ];
}
