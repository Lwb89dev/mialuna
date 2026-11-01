import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'login_panel.dart';

/// Standalone login route (e.g. from the profile tab after onboarding).
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 32),
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.asset(
                'assets/icons/icon.png',
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Mialuna',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your moments, under the same moon.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 40),
            LoginPanel(onLoggedIn: () => context.go('/home')),
          ],
        ),
      ),
    );
  }
}
