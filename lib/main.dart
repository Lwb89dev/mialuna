import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/relay_sync.dart';
import 'app/router.dart';
import 'core/auth/auth_controller.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/settings/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool(onboardingDoneKey) ?? false;
  runApp(
    ProviderScope(
      overrides: [
        onboardingDoneProvider.overrideWithValue(onboardingDone),
        // Known before the first frame: the relay pool never has to be
        // rebuilt after the preferences finish loading.
        initialSettingsProvider.overrideWithValue(
          SettingsController.load(prefs),
        ),
      ],
      child: const MialunaApp(),
    ),
  );
}

class MialunaApp extends ConsumerStatefulWidget {
  const MialunaApp({super.key});

  @override
  ConsumerState<MialunaApp> createState() => _MialunaAppState();
}

class _MialunaAppState extends ConsumerState<MialunaApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() => ref.read(authProvider.notifier).restore());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back in the foreground: pick up relay/server list changes made from
    // another Nostr app (throttled inside the sync controller).
    if (state == AppLifecycleState.resumed) {
      ref.read(relaySyncProvider.notifier).sync();
    }
  }

  @override
  Widget build(BuildContext context) => buildMialunaApp(ref);
}
