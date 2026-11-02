import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Whether private screens block screenshots (always, except in the builds
/// made to take the screenshots of this very app: `--dart-define=
/// MIALUNA_SECURE_SCREENS=false`).
const _enabled = bool.fromEnvironment(
  'MIALUNA_SECURE_SCREENS',
  defaultValue: true,
);

/// The window flag that stops screenshots, screen recording and the app
/// switcher's preview (Android's `FLAG_SECURE`). Several private screens may
/// be open at once: the flag stays until the last one closes.
abstract final class SecureWindow {
  static const _channel = MethodChannel('app.mialuna.social/window');
  static int _holders = 0;

  static Future<void> hold() async {
    if (_holders++ == 0) await _set(true);
  }

  static Future<void> release() async {
    if (_holders > 0 && --_holders == 0) await _set(false);
  }

  static Future<void> _set(bool secure) async {
    if (!_enabled) return;
    try {
      await _channel.invokeMethod<void>('setSecure', secure);
    } on PlatformException {
      // Not worth failing a screen over.
    } on MissingPluginException {
      // Not Android (or a test).
    }
  }
}

/// Keeps the window secure for as long as [child] is on screen.
class SecureScreen extends StatefulWidget {
  final Widget child;
  final bool enabled;
  const SecureScreen({super.key, required this.child, this.enabled = true});

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> {
  bool _held = false;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(SecureScreen old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.enabled == _held) return;
    _held = widget.enabled;
    _held ? SecureWindow.hold() : SecureWindow.release();
  }

  @override
  void dispose() {
    if (_held) SecureWindow.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
