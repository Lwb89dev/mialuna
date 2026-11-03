import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/signer.dart';

/// A real key that remembers what it was asked to sign, and can be told to
/// refuse some kinds (a person pressing "deny" in Amber).
class RecordingSigner extends Signer {
  final NsecSigner inner;
  final List<NostrEvent> signed = [];

  /// Kinds this signer will not sign.
  final Set<int> refuseKinds = {};

  RecordingSigner(this.inner);

  factory RecordingSigner.generate() =>
      RecordingSigner(NsecSigner.fromNsec(NsecSigner.generatePrivateKey()));

  @override
  SignerType get type => SignerType.nsec;
  @override
  String? get publicKey => inner.publicKey;
  @override
  bool get canSign => true;
  @override
  bool get canEncrypt => true;

  /// What was signed of [kind], oldest first.
  List<NostrEvent> signedOf(int kind) => [
    for (final e in signed)
      if (e.kind == kind) e,
  ];

  /// The Blossom authorizations for [action] (`upload`, `delete`).
  List<NostrEvent> authorizations(String action) => [
    for (final e in signedOf(NostrKinds.blossomAuth))
      if (e.firstTagValue('t') == action) e,
  ];

  @override
  Future<String> nip44Encrypt(String peerPubkey, String plaintext) =>
      inner.nip44Encrypt(peerPubkey, plaintext);

  @override
  Future<String> nip44Decrypt(String peerPubkey, String ciphertext) =>
      inner.nip44Decrypt(peerPubkey, ciphertext);

  @override
  Future<NostrEvent> signEvent({
    required int kind,
    required List<List<String>> tags,
    required String content,
    int? createdAt,
  }) async {
    if (refuseKinds.contains(kind)) throw const SignerException('denied');
    final event = await inner.signEvent(
      kind: kind,
      tags: tags,
      content: content,
      createdAt: createdAt,
    );
    signed.add(event);
    return event;
  }
}
