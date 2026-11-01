import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/nostr/amber_signer.dart';
import '../../core/nostr/nip19.dart';

/// Onboarding: Amber (recommended on Android), bunker/nsec (advanced),
/// or guest browsing.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _nsecController = TextEditingController();
  final _bunkerController = TextEditingController();
  bool _busy = false;
  String? _error;
  bool _amberAvailable = false;

  @override
  void initState() {
    super.initState();
    AmberSigner.isAvailable().then((v) {
      if (mounted) setState(() => _amberAvailable = v);
    });
  }

  @override
  void dispose() {
    _nsecController.dispose();
    _bunkerController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

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
            if (_amberAvailable) ...[
              FilledButton.icon(
                icon: const Icon(Icons.key),
                label: const Text('Continua con Amber'),
                onPressed: _busy
                    ? null
                    : () => _run(
                        () => ref.read(authProvider.notifier).loginWithAmber(),
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                'Consigliato: la tua chiave privata resta al sicuro in Amber.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
            ],
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () {
                      ref.read(authProvider.notifier).loginAsGuest();
                      context.go('/home');
                    },
              child: const Text('Esplora senza account'),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text('Bunker remoto (NIP-46)', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _bunkerController,
              decoration: const InputDecoration(
                labelText: 'bunker://…',
                border: OutlineInputBorder(),
              ),
              autocorrect: false,
              enableSuggestions: false,
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: _busy
                  ? null
                  : () {
                      final url = _bunkerController.text.trim();
                      if (!url.startsWith('bunker://')) {
                        setState(() => _error = 'URL bunker non valido.');
                        return;
                      }
                      _run(
                        () => ref
                            .read(authProvider.notifier)
                            .loginWithBunker(url),
                      );
                    },
              child: const Text('Connetti bunker'),
            ),
            const SizedBox(height: 24),
            Text('Accesso avanzato (nsec)', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Attenzione: incollare la chiave privata è rischioso. '
                'Non condividerla mai con nessuno. Su Android preferisci Amber.',
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nsecController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'nsec1…',
                border: OutlineInputBorder(),
              ),
              autocorrect: false,
              enableSuggestions: false,
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: _busy
                  ? null
                  : () {
                      final input = _nsecController.text;
                      if (!Nip19.isValidNsec(input) &&
                          !RegExp(r'^[0-9a-fA-F]{64}$')
                              .hasMatch(input.trim())) {
                        setState(() => _error = 'Chiave nsec non valida.');
                        return;
                      }
                      _run(
                        () => ref
                            .read(authProvider.notifier)
                            .loginWithNsec(input),
                      );
                    },
              child: const Text('Accedi con nsec'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ],
            if (_busy) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
