import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/auth/auth_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MialunaApp()));
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
