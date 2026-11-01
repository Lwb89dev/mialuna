import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _relayController = TextEditingController();
  late final TextEditingController _blossomController;

  @override
  void initState() {
    super.initState();
    _blossomController = TextEditingController(
      text: ref.read(settingsProvider).blossomServer,
    );
  }

  @override
  void dispose() {
    _relayController.dispose();
    _blossomController.dispose();
    super.dispose();
  }

  Future<void> _publishRelayList(AppSettings settings) async {
    final signer = ref.read(authProvider).signer;
    if (!signer.canSign) return;
    try {
      final event = await signer.signEvent(
        kind: 10002, // NIP-65 relay list metadata
        tags: [
          for (final r in settings.relays) ['r', r],
        ],
        content: '',
      );
      final report = await ref.read(relayPoolProvider).publish(event);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              report.publishedSomewhere
                  ? 'Relay list pubblicata su ${report.acceptedCount} relay'
                  : 'Nessun relay ha accettato la lista',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isGuest = ref.watch(authProvider).isGuest;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Relay', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'I relay memorizzano e distribuiscono i tuoi contenuti. '
            'Le modifiche richiedono il riavvio dell\'app.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          for (final relay in settings.relays)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cloud_outlined),
              title: Text(relay, style: theme.textTheme.bodyMedium),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: settings.relays.length > 1
                    ? () =>
                          ref.read(settingsProvider.notifier).removeRelay(relay)
                    : null,
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _relayController,
                  decoration: const InputDecoration(
                    hintText: 'wss://relay.esempio.com',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: const Icon(Icons.add),
                onPressed: () {
                  ref
                      .read(settingsProvider.notifier)
                      .addRelay(_relayController.text);
                  _relayController.clear();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.publish_outlined),
            label: const Text('Pubblica relay list (NIP-65)'),
            onPressed: isGuest ? null : () => _publishRelayList(settings),
          ),
          const SizedBox(height: 24),
          Text('Server media (Blossom)', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _blossomController,
            decoration: const InputDecoration(
              hintText: 'https://blossom.esempio.com',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (v) =>
                ref.read(settingsProvider.notifier).setBlossomServer(v),
          ),
          const SizedBox(height: 24),
          Text('Archiviazione', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.cleaning_services_outlined),
            label: const Text('Svuota cache eventi e bozze'),
            onPressed: () async {
              await ref.read(localCacheProvider).saveEvents([]);
              await ref.read(localCacheProvider).deleteDraft('composer_draft');
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Cache svuotata')));
              }
            },
          ),
          const SizedBox(height: 24),
          Text('Informazioni', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Mialuna 0.4.0 — Your moments, under the same moon.\n'
            'Open source (MIT). github.com/Lwb89dev/mialuna',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
