import 'dart:typed_data';

/// Minimal bech32 codec (BIP-173) as required by NIP-19.
/// NIP-19 uses plain bech32 (not bech32m) with no length limit in practice,
/// but we keep the standard 90-char check relaxed for long TLV payloads.
class Bech32 {
  static const _charset = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';
  static const _generator = [
    0x3b6a57b2,
    0x26508e6d,
    0x1ea119fa,
    0x3d4233dd,
    0x2a1462b3,
  ];

  static String encode(String hrp, List<int> data) {
    final values = _convertBits(data, 8, 5, true);
    final checksum = _createChecksum(hrp, values);
    final combined = [...values, ...checksum];
    final sb = StringBuffer(hrp)..write('1');
    for (final v in combined) {
      sb.write(_charset[v]);
    }
    return sb.toString();
  }

  /// Returns (hrp, 8-bit data). Throws [FormatException] on invalid input.
  static (String, List<int>) decode(String encoded) {
    if (encoded.length < 8) throw const FormatException('bech32 too short');
    if (encoded.toLowerCase() != encoded && encoded.toUpperCase() != encoded) {
      throw const FormatException('bech32 mixed case');
    }
    final lower = encoded.toLowerCase();
    final pos = lower.lastIndexOf('1');
    if (pos < 1 || pos + 7 > lower.length) {
      throw const FormatException('bech32 separator position invalid');
    }
    final hrp = lower.substring(0, pos);
    final data = <int>[];
    for (var i = pos + 1; i < lower.length; i++) {
      final idx = _charset.indexOf(lower[i]);
      if (idx == -1) throw FormatException('bech32 invalid char: ${lower[i]}');
      data.add(idx);
    }
    if (!_verifyChecksum(hrp, data)) {
      throw const FormatException('bech32 checksum mismatch');
    }
    final payload = data.sublist(0, data.length - 6);
    return (hrp, _convertBits(payload, 5, 8, false));
  }

  static int _polymod(List<int> values) {
    var chk = 1;
    for (final v in values) {
      final top = chk >> 25;
      chk = ((chk & 0x1ffffff) << 5) ^ v;
      for (var i = 0; i < 5; i++) {
        if ((top >> i) & 1 == 1) chk ^= _generator[i];
      }
    }
    return chk;
  }

  static List<int> _hrpExpand(String hrp) => [
    for (final c in hrp.codeUnits) c >> 5,
    0,
    for (final c in hrp.codeUnits) c & 31,
  ];

  static bool _verifyChecksum(String hrp, List<int> data) =>
      _polymod([..._hrpExpand(hrp), ...data]) == 1;

  static List<int> _createChecksum(String hrp, List<int> data) {
    final values = [..._hrpExpand(hrp), ...data, 0, 0, 0, 0, 0, 0];
    final polymod = _polymod(values) ^ 1;
    return [for (var i = 0; i < 6; i++) (polymod >> (5 * (5 - i))) & 31];
  }

  static List<int> _convertBits(List<int> data, int from, int to, bool pad) {
    var acc = 0;
    var bits = 0;
    final result = <int>[];
    final maxv = (1 << to) - 1;
    for (final value in data) {
      if (value < 0 || value >> from != 0) {
        throw const FormatException('bech32 invalid data range');
      }
      acc = (acc << from) | value;
      bits += from;
      while (bits >= to) {
        bits -= to;
        result.add((acc >> bits) & maxv);
      }
    }
    if (pad) {
      if (bits > 0) result.add((acc << (to - bits)) & maxv);
    } else if (bits >= from || ((acc << (to - bits)) & maxv) != 0) {
      throw const FormatException('bech32 invalid padding');
    }
    return result;
  }
}

Uint8List hexToBytes(String hex) {
  if (hex.length % 2 != 0) throw const FormatException('odd hex length');
  final out = Uint8List(hex.length ~/ 2);
  for (var i = 0; i < out.length; i++) {
    final byte = int.tryParse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    if (byte == null) throw FormatException('invalid hex: $hex');
    out[i] = byte;
  }
  return out;
}

String bytesToHex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
