import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../l10n/strings.dart';

/// Whether new followers show up in Notifications, in the bell's count and on
/// the phone. On by default; off for whoever gets follow spam. Reactions,
/// comments and zaps are not affected.
class NewFollowersNotifications extends Notifier<bool> {
  static const _key = 'mialuna_notify_new_followers';
  static const defaultValue = true;

  /// The user chose before the saved value was read: theirs wins.
  bool _chosen = false;

  @override
  bool build() {
    _chosen = false;
    _load();
    return defaultValue;
  }

  Future<void> _load() async {
    try {
      final prefs = await ref.read(sharedPreferencesLoader)();
      if (!_chosen) state = prefs.getBool(_key) ?? defaultValue;
    } catch (_) {
      // Unreadable: keep showing them, as before the setting existed.
    }
  }

  Future<void> set(bool show) async {
    _chosen = true;
    state = show;
    final prefs = await ref.read(sharedPreferencesLoader)();
    await prefs.setBool(_key, show);
  }
}

final newFollowersNotificationsProvider =
    NotifierProvider<NewFollowersNotifications, bool>(
      NewFollowersNotifications.new,
    );

/// Settings: whether new followers are notified.
class NewFollowersSetting extends ConsumerWidget {
  const NewFollowersSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    secondary: const Icon(Icons.person_add_alt_outlined),
    title: Text(context.l10n.newFollowersSetting),
    subtitle: Text(context.l10n.newFollowersSettingExplain),
    value: ref.watch(newFollowersNotificationsProvider),
    onChanged: ref.read(newFollowersNotificationsProvider.notifier).set,
  );
}
