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

/// Zap flow (NIP-57): fetch recipient lightning address, choose amount,
/// build the signed zap request and open the wallet with the BOLT-11
/// invoice. Optional: shows a message when the author cannot receive zaps.
Future<void> showZapSheet(
  BuildContext context,
  WidgetRef ref,
  MediaPost post,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final metadata = await ref.read(profileRepositoryProvider).fetch(post.author);
  final address = metadata?.lud16 ?? metadata?.lud06;
  if (!context.mounted) return;
  if (address == null) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Questo autore non accetta zap')),
    );
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
      title: const Text('Invia uno zap ⚡'),
      content: TextField(
        controller: amountController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Importo in sat',
          hintText: 'min ${payInfo.minSats} – max ${payInfo.maxSats}',
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Zap'),
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
      messenger.showSnackBar(
        const SnackBar(content: Text('Accedi per inviare zap')),
      );
      return;
    }
    final invoice = await ZapService().requestInvoice(
      signer: signer,
      lightningAddressOrLnurl: address,
      recipientPubkey: post.author,
      amountSats: sats,
      eventId: post.id,
      relays: ref.read(settingsProvider).relays,
    );
    // Nostr Wallet Connect pays in-app; otherwise hand the invoice to an
    // external Lightning wallet.
    final nwc = ref.read(nwcProvider);
    if (nwc != null) {
      try {
        await NwcService().payInvoice(nwc, invoice.bolt11);
        messenger.showSnackBar(
          SnackBar(content: Text('Zap da $sats sats inviato ⚡')),
        );
        return;
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('Pagamento NWC fallito: $e')),
        );
        // Fall through to the external wallet handoff.
      }
    }
    final uri = Uri.parse('lightning:${invoice.bolt11}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Nessun wallet Lightning trovato')),
      );
    }
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('$e')));
  }
}
