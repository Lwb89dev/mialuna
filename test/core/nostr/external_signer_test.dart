import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/amber_signer.dart';
import 'package:mialuna/core/nostr/signer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'signed-event validation requires the requested content and signature',
    () async {
      final signer = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
      final event = await signer.signEvent(
        kind: 20,
        tags: const [
          ['t', 'moon'],
        ],
        content: 'authentic',
      );

      expect(
        isExpectedSignedEvent(
          event,
          pubkey: signer.publicKey,
          createdAt: event.createdAt,
          kind: 20,
          tags: const [
            ['t', 'moon'],
          ],
          content: 'authentic',
        ),
        true,
      );
      expect(
        isExpectedSignedEvent(
          event,
          pubkey: signer.publicKey,
          createdAt: event.createdAt,
          kind: 20,
          tags: const [
            ['t', 'moon'],
          ],
          content: 'changed',
        ),
        false,
      );
    },
  );

  group('Amber responses', () {
    const channel = MethodChannel('app.mialuna.social/amber');
    late NsecSigner inner;

    setUp(() {
      inner = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('a valid signature is accepted', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'getPublicKey') return inner.publicKey;
            if (call.method == 'signEvent') {
              final args = call.arguments as Map<Object?, Object?>;
              final event = await inner.signEvent(
                kind: args['kind'] as int,
                tags: [
                  for (final tag in args['tags'] as List)
                    [for (final value in tag as List) value as String],
                ],
                content: args['content'] as String,
                createdAt: args['created_at'] as int,
              );
              return event.sig;
            }
            return null;
          });
      final amber = await AmberSigner.connect();

      final event = await amber.signEvent(
        kind: 20,
        tags: const [],
        content: 'authentic',
      );
      expect(verifyEventSignature(event), true);
    });

    test('an invalid signature is rejected before publishing', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'getPublicKey') return inner.publicKey;
            if (call.method == 'signEvent') return '00' * 64;
            return null;
          });
      final amber = await AmberSigner.connect();

      await expectLater(
        amber.signEvent(kind: 20, tags: const [], content: 'authentic'),
        throwsA(isA<SignerException>()),
      );
    });
  });
}
