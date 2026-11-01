import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/mialuna_theme.dart';
import 'providers.dart';
import 'router.dart';

Widget buildMialunaApp(WidgetRef ref) {
  final router = ref.watch(routerProvider);
  ref.watch(nip65SyncProvider);
  return MaterialApp.router(
    title: 'Mialuna',
    debugShowCheckedModeBanner: false,
    theme: MialunaTheme.light(),
    darkTheme: MialunaTheme.dark(),
    themeMode: ThemeMode.system,
    routerConfig: router,
  );
}
