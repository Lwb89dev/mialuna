import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/trust/trust_network.dart';
import '../../l10n/strings.dart';
import '../feed/widgets/post_card.dart' show formatPostTime;
import 'web_of_trust_controller.dart';

/// Settings: the switch of the web of trust, what it has worked out, and a
/// button to work it out again.
class TrustSection extends ConsumerWidget {
  const TrustSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final wot = ref.watch(webOfTrustProvider);
    final controller = ref.read(webOfTrustProvider.notifier);
    final working = wot.phase == WotPhase.discovering;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.wotTitle, style: theme.textTheme.titleMedium),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(context.l10n.wotEnable),
          subtitle: Text(context.l10n.wotExplain(wotThreshold)),
          value: wot.enabled,
          onChanged: controller.setEnabled,
        ),
        if (wot.enabled) ...[
          if (working) LinearProgressIndicator(value: _progress(wot)),
          const SizedBox(height: 4),
          Text(
            _status(context, wot),
            style: theme.textTheme.bodySmall?.copyWith(
              color: wot.phase == WotPhase.failed
                  ? theme.colorScheme.error
                  : theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.wotRefresh),
            onPressed: working ? null : controller.refresh,
          ),
        ],
      ],
    );
  }

  double? _progress(WotState wot) =>
      wot.total == 0 ? null : wot.fetched / wot.total;

  String _status(BuildContext context, WotState wot) {
    final l10n = context.l10n;
    return switch (wot.phase) {
      WotPhase.discovering => l10n.wotStatusDiscovering(wot.fetched, wot.total),
      WotPhase.failed => l10n.wotStatusFailed(wot.error ?? ''),
      WotPhase.complete => l10n.wotStatusComplete(
        wot.directCount,
        wot.qualified.length,
        formatPostTime(wot.computedAt),
      ),
      WotPhase.idle =>
        wot.computedAt > 0
            ? l10n.wotStatusComplete(
                wot.directCount,
                wot.qualified.length,
                formatPostTime(wot.computedAt),
              )
            : l10n.wotStatusIdle,
    };
  }
}
