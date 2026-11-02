/// Just enough of BOLT-11 to read the amount an invoice asks for.
///
/// A Lightning address's server hands back the invoice to pay. A wallet shows
/// its amount before paying, but a Nostr Wallet Connect link pays at once:
/// without this check, a server could ask for a hundred times the zap the
/// user chose.
abstract final class Bolt11 {
  static final _pattern = RegExp(
    r'^ln(?:bc|tbs|tb|bcrt)(?:(\d+)([munp])?)?1[qpzry9x8gf2tvdw0s3jn54khce6mua7l]+$',
  );

  /// The amount of [invoice] in millisatoshis; null when it has none, or is
  /// not an invoice at all.
  static BigInt? amountMsats(String invoice) {
    final m = _pattern.firstMatch(invoice.trim().toLowerCase());
    final digits = m?.group(1);
    if (m == null || digits == null) return null;
    final value = BigInt.parse(digits);
    switch (m.group(2)) {
      case null: // whole bitcoin
        return value * BigInt.from(100000000000);
      case 'm':
        return value * BigInt.from(100000000);
      case 'u':
        return value * BigInt.from(100000);
      case 'n':
        return value * BigInt.from(100);
      default: // 'p': a tenth of a millisatoshi, so it must come in tens
        return value % BigInt.from(10) == BigInt.zero
            ? value ~/ BigInt.from(10)
            : null;
    }
  }
}
