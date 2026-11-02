import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth/auth_controller.dart';
import '../features/messages/chat_screen.dart';
import '../features/messages/inbox_screen.dart';
import '../features/notifications/notifications_screen.dart';
import 'router.dart';

/// Opens the screen a tapped system notification asked for: `notifications`,
/// `messages`, or `chat:<pubkey>`. Anything else, or nobody signed in, does
/// nothing.
void openNotificationRoute(WidgetRef ref, String route) {
  final navigator = rootNavigatorKey.currentState;
  final auth = ref.read(authProvider);
  if (navigator == null || auth.isGuest || auth.restoring) return;
  final Widget? screen;
  if (route == 'notifications') {
    screen = const NotificationsScreen();
  } else if (route == 'messages') {
    screen = const InboxScreen();
  } else if (route.startsWith('chat:') &&
      RegExp(r'^[0-9a-f]{64}$').hasMatch(route.substring(5))) {
    screen = ChatScreen(peer: route.substring(5));
  } else {
    screen = null;
  }
  if (screen == null) return;
  navigator.push(MaterialPageRoute(builder: (_) => screen!));
}
