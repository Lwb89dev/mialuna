import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/nostr/signer.dart';

/// Profile tab. Shows the current identity (or a login prompt in guest
/// mode). Photo grid, edit profile and follow lists land with the profile
/// repository in the next iteration.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);

    if (auth.isGuest) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profilo')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 72,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'Stai navigando come ospite',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Accedi per pubblicare, seguire e interagire.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/login'),
                child: const Text('Accedi'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Esci',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 44,
            child: Text(
              (auth.publicKey ?? '?').substring(0, 2).toUpperCase(),
              style: theme.textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: SelectableText(
              auth.npub ?? '',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Chip(
              avatar: const Icon(Icons.key, size: 16),
              label: Text(switch (auth.signer.type) {
                SignerType.amber => 'Amber (NIP-55)',
                SignerType.nsec => 'Chiave locale',
                SignerType.bunker => 'Bunker (NIP-46)',
                SignerType.guest => 'Ospite',
              }),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'La griglia fotografica del profilo, NIP-05 e la modifica del '
            'profilo arrivano con il repository profili.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
