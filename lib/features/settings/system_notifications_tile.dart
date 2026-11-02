import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

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
  Widget build(BuildContext context, WidgetRef ref) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    secondary: const Icon(Icons.notifications_active_outlined),
    title: Text(context.l10n.systemNotifications),
    subtitle: Text(context.l10n.systemNotificationsExplain),
    value: ref.watch(systemNotificationsSettingProvider),
    onChanged: (on) => _toggle(context, ref, on),
  );
}
