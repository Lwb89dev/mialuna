import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/nwc_controller.dart';
import '../../core/nostr/nwc_service.dart';
import '../../core/nostr/zap_service.dart';
import '../../features/settings/settings_controller.dart';
import '../../l10n/strings.dart';

/// Zap flow (NIP-57): fetch recipient lightning address, choose amount,
/// build the signed zap request and open the wallet with the BOLT-11
/// invoice. Optional: shows a message when the author cannot receive zaps.
Future<void> showZapSheet(
  BuildContext context,
  WidgetRef ref,
  MediaPost post,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final metadata = await ref.read(profileRepositoryProvider).fetch(post.author);
  final address = metadata?.lud16 ?? metadata?.lud06;
  if (!context.mounted) return;
  if (address == null) {
    messenger.showSnackBar(SnackBar(content: Text(context.l10n.authorNoZaps)));
    return;
  }

  final LnurlPayInfo payInfo;
  try {
    payInfo = await ZapService().fetchPayInfo(address);
  } catch (e) {
    if (!context.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text('$e')));
    return;
  }
  if (!context.mounted) return;

  final initial = (21 >= payInfo.minSats && 21 <= payInfo.maxSats)
      ? '21'
      : '${payInfo.minSats}';
  final amountController = TextEditingController(text: initial);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.sendZap),
      content: TextField(
        controller: amountController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: context.l10n.amountInSats,
          hintText: context.l10n.minMaxSats(payInfo.minSats, payInfo.maxSats),
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.l10n.zap),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  final sats = int.tryParse(amountController.text) ?? 0;
  if (sats <= 0) return;

  try {
    final signer = ref.read(authProvider).signer;
    if (!signer.canSign) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.signInToZap)));
      return;
    }
    final invoice = await ZapService().requestInvoice(
      signer: signer,
      lightningAddressOrLnurl: address,
      recipientPubkey: post.author,
      amountSats: sats,
      eventId: post.id,
      relays: [
        for (final r in ref.read(settingsProvider).relays)
          if (r.write) r.url,
      ],
    );
    // Nostr Wallet Connect pays in-app; otherwise hand the invoice to an
    // external Lightning wallet.
    final nwc = ref.read(nwcProvider);
    if (nwc != null) {
      try {
        await NwcService().payInvoice(nwc, invoice.bolt11);
        messenger.showSnackBar(SnackBar(content: Text(l10n.zapSent(sats))));
        return;
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.nwcPaymentFailed(e))),
        );
        // Fall through to the external wallet handoff.
      }
    }
    final uri = Uri.parse('lightning:${invoice.bolt11}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      messenger.showSnackBar(SnackBar(content: Text(l10n.noLightningWallet)));
    }
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('$e')));
  }
}
