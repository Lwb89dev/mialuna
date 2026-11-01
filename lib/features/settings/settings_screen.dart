import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
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

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
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
