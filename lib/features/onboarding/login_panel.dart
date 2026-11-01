import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/nostr/amber_signer.dart';
import '../../core/nostr/nip19.dart';

/// Shared login form: Amber (recommended on Android), bunker (NIP-46),
/// nsec (advanced fallback) or guest browsing. Used by the onboarding
/// pager and by the standalone /login route.
class LoginPanel extends ConsumerStatefulWidget {
  /// Called after a successful login (Amber, bunker, nsec or guest).
  final VoidCallback onLoggedIn;

  const LoginPanel({super.key, required this.onLoggedIn});

  @override
  ConsumerState<LoginPanel> createState() => _LoginPanelState();
}

class _LoginPanelState extends ConsumerState<LoginPanel> {
  final _nsecController = TextEditingController();
  final _bunkerController = TextEditingController();
  bool _busy = false;
  String? _error;
  bool _amberAvailable = false;

  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

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
      widget.onLoggedIn();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onAmberPressed() async {
    if (!_amberAvailable) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Amber non trovato'),
          content: const Text(
            'Amber è un signer Nostr che custodisce la tua chiave privata '
            'fuori da Mialuna. Installalo e riprova.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                launchUrl(
                  Uri.parse(
                    'https://f-droid.org/packages/com.greenart7c3.nostrsigner/',
                  ),
                  mode: LaunchMode.externalApplication,
                );
              },
              child: const Text('Scarica da F-Droid'),
            ),
          ],
        ),
      );
      return;
    }
    await _run(() => ref.read(authProvider.notifier).loginWithAmber());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isAndroid) ...[
          FilledButton.icon(
            icon: const Icon(Icons.key),
            label: const Text('Continua con Amber'),
            onPressed: _busy ? null : _onAmberPressed,
          ),
          const SizedBox(height: 8),
          Text(
            _amberAvailable
                ? 'Consigliato: la chiave privata resta al sicuro in Amber.'
                : 'Amber non rilevato: installalo per l\'accesso consigliato.',
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
                  widget.onLoggedIn();
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
                    () => ref.read(authProvider.notifier).loginWithBunker(url),
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
                      !RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(input.trim())) {
                    setState(() => _error = 'Chiave nsec non valida.');
                    return;
                  }
                  _run(
                    () => ref.read(authProvider.notifier).loginWithNsec(input),
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
    );
  }
}
