import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../l10n/strings.dart';

/// Which Android notification channel (the switches the user finds in the
/// phone's settings) a notification belongs to.
enum NotifyChannel { social, messages }

/// One notification for the phone's notification shade.
class SystemNotification {
  final NotifyChannel channel;

  /// Same id = the notification is replaced instead of stacked (one per
  /// conversation).
  final int id;
  final String title;
  final String body;

  /// What the lock screen shows instead of [title] and [body]. Private
  /// messages never put their sender or text there.
  final String? publicTitle;
  final String? publicBody;

  /// The screen to open when it is tapped: `notifications`, `messages` or
  /// `chat:<pubkey>`.
  final String route;

  const SystemNotification({
    required this.channel,
    required this.id,
    required this.title,
    required this.body,
    required this.route,
    this.publicTitle,
    this.publicBody,
  });
}

/// The phone's notification shade. Mialuna talks to no push service: this
/// only shows what the app itself received while it was running.
abstract class SystemNotifier {
  /// Shows [n]; false when the user (or the phone) does not allow it.
  Future<bool> show(SystemNotification n);

  Future<void> cancelAll();

  /// The screen a tapped notification asked for when it started the app.
  Future<String?> initialRoute();

  /// A notification was tapped while the app was running.
  void onRoute(void Function(String route) listener);

  /// Android may put the app to sleep soon after the screen goes off, and its
  /// connections with it: no notification arrives then. True while it is
  /// allowed to (false where there is no such thing).
  Future<bool> batteryRestricted();

  /// Opens the phone's battery settings, where that can be changed.
  Future<void> openBatterySettings();
}

/// Android, through the native bridge in `NotifyBridge.kt`. Anywhere else (and
/// in tests without a bridge) it quietly does nothing.
class AndroidSystemNotifier implements SystemNotifier {
  static const _channel = MethodChannel('app.mialuna.social/notify');

  @override
  Future<bool> show(SystemNotification n) async {
    final l10n = AppStrings.current;
    try {
      return await _channel.invokeMethod<bool>('show', {
            'channel': n.channel.name,
            'channelName': n.channel == NotifyChannel.messages
                ? l10n.notificationChannelMessages
                : l10n.notificationChannelSocial,
            'id': n.id,
            'title': n.title,
            'body': n.body,
            'publicTitle': n.publicTitle,
            'publicBody': n.publicBody,
            'route': n.route,
          }) ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<void> cancelAll() async {
    try {
      await _channel.invokeMethod<void>('cancelAll');
    } on PlatformException {
      // Nothing to cancel.
    } on MissingPluginException {
      // Not Android.
    }
  }

  @override
  Future<String?> initialRoute() async {
    try {
      return await _channel.invokeMethod<String>('initialRoute');
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Future<bool> batteryRestricted() async {
    try {
      return await _channel.invokeMethod<bool>('batteryRestricted') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<void> openBatterySettings() async {
    try {
      await _channel.invokeMethod<bool>('openBatterySettings');
    } on PlatformException {
      // Nowhere to send the user.
    } on MissingPluginException {
      // Not Android.
    }
  }

  @override
  void onRoute(void Function(String route) listener) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'route' && call.arguments is String) {
        listener(call.arguments as String);
      }
    });
  }
}

final systemNotifierProvider = Provider<SystemNotifier>(
  (ref) => AndroidSystemNotifier(),
);

/// Whether the app is in front of the user. Notifications are for when it is
/// not: in front, the red badges say it already.
final appForegroundProvider = StateProvider<bool>((ref) => true);
