import 'bech32.dart';

/// NIP-19 bech32-encoded identifiers: npub, nsec, note.
class Nip19 {
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
