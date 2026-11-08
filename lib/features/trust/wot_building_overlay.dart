import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/strings.dart';
import 'web_of_trust_controller.dart';

/// Centered card shown while the web of trust is reading follow lists and
/// preparing the Discover feed. Colors, type and shape come from the active
/// theme, so light and dark stay in step with the rest of the app.
class WotBuildingOverlay extends ConsumerWidget {
  const WotBuildingOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wot = ref.watch(webOfTrustProvider);
    if (!wot.building) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final dim = theme.brightness == Brightness.dark ? 0.54 : 0.32;
    return Stack(
      fit: StackFit.expand,
      children: [
        ModalBarrier(
          dismissible: false,
          color: theme.colorScheme.scrim.withValues(alpha: dim),
        ),
        Center(child: _WotBuildingCard(wot: wot)),
      ],
    );
  }
}

class _WotBuildingCard extends StatelessWidget {
  final WotState wot;
  const _WotBuildingCard({required this.wot});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final progress = wot.total == 0 ? null : wot.fetched / wot.total;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Card(
          color: scheme.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 8,
          child: _contents(theme, scheme, l10n, progress),
        ),
      ),
    );
  }

  Widget _contents(
    ThemeData theme,
    ColorScheme scheme,
    AppLocalizations l10n,
    double? progress,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hub_outlined, size: 36, color: scheme.primary),
          const SizedBox(height: 16),
          Text(
            l10n.wotBuildingTitle,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.wotBuildingBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(value: progress),
          if (wot.total > 0) _count(theme, scheme, l10n),
        ],
      ),
    );
  }

  Widget _count(ThemeData theme, ColorScheme scheme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        l10n.wotStatusDiscovering(wot.fetched, wot.total),
        style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
        textAlign: TextAlign.center,
      ),
    );
  }
}
