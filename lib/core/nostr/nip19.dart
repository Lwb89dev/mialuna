import 'dart:convert';

import 'bech32.dart';

/// A pointer to an event decoded from `note1…` or `nevent1…`.
class EventRef {
  final String id;
  final List<String> relays;
  final String? author;
  final int? kind;
  const EventRef(this.id, {this.relays = const [], this.author, this.kind});
}

/// NIP-19 bech32-encoded identifiers: npub, nsec, note, nevent.
class Nip19 {
  /// `nostr:note1…` / `nostr:nevent1…` references inside a text.
  static final eventRefPattern = RegExp(
    r'nostr:(?:nevent1|note1)[023456789acdefghjklmnpqrstuvwxyz]+',
  );

  /// TLV `nevent`: id, optional relay hints, author and kind (NIP-19).
  static String encodeNevent(
    String eventIdHex, {
    List<String> relays = const [],
    String? author,
    int? kind,
  }) {
    final out = <int>[0, 32, ...hexToBytes(eventIdHex)];
    for (final r in relays.take(3)) {
      final bytes = utf8.encode(r);
      if (bytes.length > 255) continue;
      out.addAll([1, bytes.length, ...bytes]);
    }
    if (author != null && author.length == 64) {
      out.addAll([2, 32, ...hexToBytes(author)]);
    }
    if (kind != null) {
      out.addAll([
        3,
        4,
        (kind >> 24) & 0xff,
        (kind >> 16) & 0xff,
        (kind >> 8) & 0xff,
        kind & 0xff,
      ]);
    }
    return Bech32.encode('nevent', out);
  }

  /// Decodes `note1…` or `nevent1…` (with or without the `nostr:` prefix).
  /// Throws [FormatException] when it is neither.
  static EventRef decodeEventRef(String input) {
    var text = input.trim();
    if (text.startsWith('nostr:')) text = text.substring(6);
    final (hrp, data) = Bech32.decode(text);
    if (hrp == 'note') {
      if (data.length != 32) throw const FormatException('bad note length');
      return EventRef(bytesToHex(data));
    }
    if (hrp != 'nevent') {
      throw FormatException('expected note or nevent, got $hrp');
    }
    String? id, author;
    int? kind;
    final relays = <String>[];
    var i = 0;
    while (i + 2 <= data.length) {
      final type = data[i];
      final len = data[i + 1];
      if (i + 2 + len > data.length) break;
      final value = data.sublist(i + 2, i + 2 + len);
      switch (type) {
        case 0:
          if (len == 32) id = bytesToHex(value);
        case 1:
          relays.add(utf8.decode(value, allowMalformed: true));
        case 2:
          if (len == 32) author = bytesToHex(value);
        case 3:
          if (len == 4) {
            kind =
                (value[0] << 24) |
                (value[1] << 16) |
                (value[2] << 8) |
                value[3];
          }
      }
      i += 2 + len;
    }
    if (id == null) throw const FormatException('nevent without id');
    return EventRef(id, relays: relays, author: author, kind: kind);
  }

  static String encodeNpub(String pubkeyHex) =>
      Bech32.encode('npub', hexToBytes(pubkeyHex));

  static String encodeNsec(String privkeyHex) =>
      Bech32.encode('nsec', hexToBytes(privkeyHex));

  static String encodeNote(String eventIdHex) =>
      Bech32.encode('note', hexToBytes(eventIdHex));

  /// Decodes an npub. Throws [FormatException] if invalid or wrong prefix.
  static String decodeNpub(String npub) => _decodeWithPrefix(npub, 'npub');

  /// Decodes an nsec. Throws [FormatException] if invalid or wrong prefix.
  static String decodeNsec(String nsec) => _decodeWithPrefix(nsec, 'nsec');

  static String decodeNote(String note) => _decodeWithPrefix(note, 'note');

  static bool isValidNsec(String input) {
    try {
      decodeNsec(input.trim());
      return true;
    } on FormatException {
      return false;
    }
  }

  static bool isValidNpub(String input) {
    try {
      decodeNpub(input.trim());
      return true;
    } on FormatException {
      return false;
    }
  }

  static String _decodeWithPrefix(String encoded, String expected) {
    final trimmed = encoded.trim();
    final (hrp, data) = Bech32.decode(trimmed);
    if (hrp != expected) {
      throw FormatException('expected $expected prefix, got $hrp');
    }
    if (data.length != 32) {
      throw FormatException('$expected must decode to 32 bytes');
    }
    return bytesToHex(data);
  }
}
