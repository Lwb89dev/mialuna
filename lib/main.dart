import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/router.dart';
import 'core/auth/auth_controller.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool(onboardingDoneKey) ?? false;
  runApp(
    ProviderScope(
      overrides: [onboardingDoneProvider.overrideWithValue(onboardingDone)],
      child: const MialunaApp(),
    ),
  );
}

class MialunaApp extends ConsumerStatefulWidget {
  const MialunaApp({super.key});

  @override
  ConsumerState<MialunaApp> createState() => _MialunaAppState();
}

class _MialunaAppState extends ConsumerState<MialunaApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authProvider.notifier).restore());
  }

  @override
  Widget build(BuildContext context) => buildMialunaApp(ref);
}
