import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/nip59.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/features/messages/dm_controller.dart';
import 'package:mialuna/features/private/private_delivery.dart';
import 'package:mialuna/features/social/follow_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_relay.dart';
import '../../support/story_harness.dart';

/// Work begun for one account must not leak into the next, wherever it ends:
/// an account switch used to be able to carry a signer refusal, or a "list
/// loaded" signal, over to whoever signed in after.
void main() {
  late FakeRelay relay;
  late StoryHarness h;
  late NsecSigner alice;
  late NsecSigner bob;
  late NsecSigner carol;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    relay = await FakeRelay(authKinds: {1059}).start();
    h = StoryHarness(relay);
    alice = newSigner();
    bob = newSigner();
    carol = newSigner();
    for (final s in [alice, bob, carol]) {
      await h.registerInbox(s);
    }
  });

  tearDown(() => relay.stop());

  test('a signer refusal for the old account is not the new one\'s', () async {
    final scripted = ScriptedSigner(alice)
      ..decryptGate = Completer<void>()
      ..refuseDecrypt = true;
    final auth = SwitchableAuth(scripted);
    final a = await h.online(scripted, auth: auth);
    final b = await h.online(bob);
    await b.read(privateDeliveryProvider).send(
      Rumor.create(
        pubkey: bob.publicKey,
        kind: NostrKinds.reaction,
        tags: [
          ['e', 'c' * 64],
          ['p', alice.publicKey],
          ['k', '20'],
        ],
        content: '+',
      ),
      [alice.publicKey],
      copyToSelf: false,
    );
    await eventually(() => scripted.decryptCalls == 1);

    // Alice's phone is waiting for the signer; Carol signs in; the signer says
    // no to Alice.
    auth.switchTo(carol);
    await eventually(() => a.read(dmProvider).inboxConfigured == true);
    scripted.decryptGate!.complete();
    await Future<void>.delayed(const Duration(milliseconds: 300));

    expect(
      a.read(dmProvider).error,
      isNull,
      reason: 'Alice\'s refusal showed up in Carol\'s inbox',
    );
    expect(a.read(dmProvider).inboxConfigured, true);
  });

  test('the next account\'s follow list is not "loaded" by the last', () async {
    relay.reqDelay = const Duration(milliseconds: 700);
    final auth = SwitchableAuth(alice);
    final c = h.app(alice, auth: auth);
    c.read(followListProvider);
    await eventually(() => relay.reqCount >= 1);

    auth.switchTo(bob);
    final ctl = c.read(followListProvider.notifier);
    var ready = false;
    var usable = false;
    unawaited(ctl.ready.then((_) => ready = true));
    unawaited(ctl.usable.then((_) => usable = true));
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(ready, false, reason: 'released by the previous account\'s load');
    expect(usable, false);

    await eventually(() => ready && usable);
  });
}
