import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/nostr/profile_repository.dart';
import '../../core/notify/system_notifier.dart';
import '../../l10n/strings.dart';

/// Whether Mialuna may show notifications on the phone at all (the user's
/// own switch in Settings; Android's permission is separate).
class SystemNotificationsSetting extends Notifier<bool> {
  static const _key = 'mialuna_system_notifications';

  /// The user chose before the saved value was read: theirs wins.
  bool _chosen = false;

  @override
  bool build() {
    _chosen = false;
    _load();
    return true;
  }

  Future<void> _load() async {
    final prefs = await ref.read(sharedPreferencesLoader)();
    if (!_chosen) state = prefs.getBool(_key) ?? true;
  }

  Future<void> set(bool enabled) async {
    _chosen = true;
    state = enabled;
    final prefs = await ref.read(sharedPreferencesLoader)();
    await prefs.setBool(_key, enabled);
  }
}

final systemNotificationsSettingProvider =
    NotifierProvider<SystemNotificationsSetting, bool>(
      SystemNotificationsSetting.new,
    );

/// Decides when something that arrived deserves a notification on the phone,
/// and shows it. The rules, in one place:
///
/// * the user did not turn them off, and the app is not in front of them;
/// * never more than [perMinute] a minute per channel: past that, one
///   notification that counts what came, instead of a flood.
class SystemNotifications {
  static const perMinute = 5;
  static const _window = Duration(minutes: 1);

  final Ref _ref;
  final Map<NotifyChannel, List<DateTime>> _recent = {};
  final Map<NotifyChannel, int> _overflow = {};

  SystemNotifications(this._ref);

  /// True when [n] (or the summary standing for it) was shown.
  Future<bool> post(SystemNotification n) async {
    if (!_ref.read(systemNotificationsSettingProvider)) return false;
    if (_ref.read(appForegroundProvider)) return false;
    final now = DateTime.now();
    final recent = _recent.putIfAbsent(n.channel, () => []);
    recent.removeWhere((t) => now.difference(t) > _window);
    if (recent.isEmpty) _overflow[n.channel] = 0;
    final notifier = _ref.read(systemNotifierProvider);
    if (recent.length < perMinute) {
      recent.add(now);
      return notifier.show(n);
    }
    final extra = _overflow[n.channel] = (_overflow[n.channel] ?? 0) + 1;
    return notifier.show(
      SystemNotification(
        channel: n.channel,
        // One summary per channel, replaced as it grows.
        id: n.channel == NotifyChannel.messages ? 0x7ffffff0 : 0x7ffffff1,
        title: 'Mialuna',
        body: AppStrings.current.notificationsNew(perMinute + extra),
        publicTitle: 'Mialuna',
        publicBody: AppStrings.current.systemNotificationNew,
        route: n.channel == NotifyChannel.messages
            ? 'messages'
            : 'notifications',
      ),
    );
  }
}

final systemNotificationsProvider = Provider<SystemNotifications>(
  SystemNotifications.new,
);

/// The name to show for [pubkey]: their profile's, waiting briefly for it,
/// or their npub.
Future<String> displayNameOf(Ref ref, String pubkey) async {
  final repo = ref.read(profileRepositoryProvider);
  try {
    final meta = await repo
        .fetch(pubkey)
        .timeout(
          const Duration(seconds: 3),
          onTimeout: () => repo.cached(pubkey),
        );
    return meta?.label ?? ProfileMetadata.shortNpub(pubkey);
  } catch (_) {
    return ProfileMetadata.shortNpub(pubkey);
  }
}

/// A stable positive id for a notification about [key] (an event id or a
/// pubkey): the same thing replaces itself, different things do not collide
/// in practice.
int notificationIdFor(String key) => key.hashCode & 0x7fffffff;
