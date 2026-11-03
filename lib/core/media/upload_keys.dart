import '../storage/local_cache.dart';

/// The one-time keys that signed the uploads of close-friends media.
///
/// Those files are uploaded under a key that exists for one post only, so a
/// media server cannot tie the encrypted blob to the author's account. For the
/// same reason the account's own key is not "the owner" of the file, and only
/// the key that uploaded it can ask the server to delete it: this keeps it on
/// the device, next to the post, so deleting the post can take the file down.
///
/// A key opens nothing but that deletion (the file is ciphertext and its
/// decryption key travels inside the gift-wrapped post), and cannot be made
/// again, so it is not cleared when the account signs out. Kept per account,
/// oldest first out.
class UploadKeys {
  static const _maxKeys = 600;

  final LocalCache _cache;
  final String? _owner;
  Future<void> _tail = Future.value();

  UploadKeys(this._cache, this._owner);

  /// The file a given account's keys are kept in.
  static String fileFor(String pubkey) => 'upload_keys_$pubkey.json';

  /// Read-modify-write steps must not interleave.
  Future<T> _serial<T>(Future<T> Function() step) {
    final run = _tail.then((_) => step());
    _tail = run.then<void>((_) {}, onError: (_) {});
    return run;
  }

  Future<Map<String, String>> _read(String owner) async {
    final json = await _cache.readJson(fileFor(owner));
    final keys = <String, String>{};
    if (json is! Map) return keys;
    for (final entry in json.entries) {
      final hash = entry.key;
      final key = entry.value;
      if (hash is String && key is String) keys[hash] = key;
    }
    return keys;
  }

  Future<void> _write(String owner, Map<String, String> keys) async {
    while (keys.length > _maxKeys) {
      keys.remove(keys.keys.first);
    }
    await _cache.writeJson(fileFor(owner), keys);
  }

  /// Remembers that [privateKeyHex] uploaded the files [hashes].
  Future<void> remember(Iterable<String> hashes, String privateKeyHex) {
    final owner = _owner;
    if (owner == null) return Future.value();
    return _serial(() async {
      final keys = await _read(owner);
      for (final hash in hashes) {
        keys.remove(hash); // newest last
        keys[hash] = privateKeyHex;
      }
      await _write(owner, keys);
    });
  }

  /// The key behind each of [hashes] that this device still knows.
  Future<Map<String, String>> keysFor(Iterable<String> hashes) {
    final owner = _owner;
    if (owner == null) return Future.value(const {});
    return _serial(() async {
      final keys = await _read(owner);
      return {
        for (final hash in hashes)
          if (keys[hash] != null) hash: keys[hash]!,
      };
    });
  }

  /// Drops the keys of [hashes], once their files are gone.
  Future<void> forget(Iterable<String> hashes) {
    final owner = _owner;
    if (owner == null) return Future.value();
    return _serial(() async {
      final keys = await _read(owner);
      final before = keys.length;
      hashes.forEach(keys.remove);
      if (keys.length != before) await _write(owner, keys);
    });
  }
}
