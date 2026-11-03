import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/notify/system_notifier.dart';
import '../../l10n/strings.dart';
import '../notifications/system_notifications.dart';

/// Settings: whether Mialuna shows notifications on the phone. Turning it on
/// asks Android for the permission if it was not given yet.
class SystemNotificationsTile extends ConsumerWidget {
  const SystemNotificationsTile({super.key});

  Future<void> _toggle(BuildContext context, WidgetRef ref, bool on) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    await ref.read(systemNotificationsSettingProvider.notifier).set(on);
    if (!on) return;
    var status = await Permission.notification.status;
    if (!status.isGranted) status = await Permission.notification.request();
    if (status.isGranted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.systemNotificationsBlocked),
        action: SnackBarAction(
          label: l10n.systemNotificationsOpenSettings,
          onPressed: openAppSettings,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(systemNotificationsSettingProvider);
    // Back from the phone's settings: ask again.
    ref.listen(appForegroundProvider, (_, front) {
      if (front) ref.invalidate(batteryRestrictedProvider);
    });
    final restricted =
        on && (ref.watch(batteryRestrictedProvider).value ?? false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.notifications_active_outlined),
          title: Text(context.l10n.systemNotifications),
          subtitle: Text(context.l10n.systemNotificationsExplain),
          value: on,
          onChanged: (value) => _toggle(context, ref, value),
        ),
        if (restricted) const _BatteryHint(),
      ],
    );
  }
}

/// Whether Android may put Mialuna to sleep (and so stop its notifications).
final batteryRestrictedProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.read(systemNotifierProvider).batteryRestricted(),
);

class _BatteryHint extends ConsumerWidget {
  const _BatteryHint();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.battery_alert_outlined, color: theme.colorScheme.tertiary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.systemNotificationsBattery,
                  style: theme.textTheme.bodySmall,
                ),
                TextButton(
                  onPressed: ref
                      .read(systemNotifierProvider)
                      .openBatterySettings,
                  child: Text(context.l10n.systemNotificationsBatteryAction),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
