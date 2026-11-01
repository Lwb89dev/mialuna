import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/strings.dart';

/// Where a donation goes: a Lightning address, the same one the author's
/// other apps (eikon) use. Nothing is sent from Mialuna: the wallet the user
/// picks does it.
abstract final class Support {
  static const lightningAddress = 'lwb89@blink.sv';

  /// Opens the Lightning wallet the user has installed; without one, copies
  /// the address so it can be pasted anywhere. Returns true when it had to
  /// copy.
  static Future<bool> open() async {
    try {
      final opened = await launchUrl(
        Uri.parse('lightning:$lightningAddress'),
        mode: LaunchMode.externalApplication,
      );
      if (opened) return false;
    } catch (_) {
      // No app handles the scheme.
    }
    await Clipboard.setData(const ClipboardData(text: lightningAddress));
    return true;
  }
}

/// The last thing in Settings: Mialuna is free, and this is how to say thanks.
class SupportSection extends StatelessWidget {
  /// Called when no wallet was found and the address went to the clipboard.
  final VoidCallback onCopied;
  const SupportSection({super.key, required this.onCopied});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.support, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          context.l10n.supportText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            icon: const Icon(Icons.favorite_outline, size: 18),
            label: Text(context.l10n.donateWithLightning),
            onPressed: () async {
              if (await Support.open()) onCopied();
            },
          ),
        ),
        const SizedBox(height: 4),
        Text(
          Support.lightningAddress,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
