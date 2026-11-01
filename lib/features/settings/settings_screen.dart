import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../social/moderation_controller.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _relayController = TextEditingController();
  final _hashtagController = TextEditingController();
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
    _hashtagController.dispose();
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
          Text('Moderazione', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Silenziati e hashtag nascosti sono sincronizzati via NIP-51. '
            'I bloccati restano solo su questo dispositivo.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          _MuteSection(
            title: 'Autori silenziati',
            emptyLabel: 'Nessun autore silenziato',
            entries: ref
                .watch(muteControllerProvider)
                .pubkeys
                .map((pk) => '${pk.substring(0, 12)}…')
                .toList(),
            onRemove: (i) => ref
                .read(muteControllerProvider.notifier)
                .unmute(ref.read(muteControllerProvider).pubkeys.elementAt(i)),
          ),
          _MuteSection(
            title: 'Autori bloccati',
            emptyLabel: 'Nessun autore bloccato',
            entries: ref
                .watch(blockProvider)
                .map((pk) => '${pk.substring(0, 12)}…')
                .toList(),
            onRemove: (i) => ref
                .read(blockProvider.notifier)
                .unblock(ref.read(blockProvider).elementAt(i)),
          ),
          _MuteSection(
            title: 'Hashtag nascosti',
            emptyLabel: 'Nessun hashtag nascosto',
            entries: ref
                .watch(mutedHashtagsProvider)
                .map((t) => '#$t')
                .toList(),
            onRemove: (i) => ref
                .read(muteControllerProvider.notifier)
                .unmuteHashtag(
                  ref.read(muteControllerProvider).hashtags.elementAt(i),
                ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hashtagController,
                  decoration: const InputDecoration(
                    hintText: '#hashtag da nascondere',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: const Icon(Icons.visibility_off_outlined),
                onPressed: () {
                  ref
                      .read(muteControllerProvider.notifier)
                      .muteHashtag(_hashtagController.text);
                  _hashtagController.clear();
                },
              ),
            ],
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
            'Mialuna 0.11.0 — Your moments, under the same moon.\n'
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

/// Compact removable list for the moderation settings.
class _MuteSection extends StatelessWidget {
  final String title;
  final String emptyLabel;
  final List<String> entries;
  final void Function(int index) onRemove;

  const _MuteSection({
    required this.title,
    required this.emptyLabel,
    required this.entries,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        if (entries.isEmpty)
          Text(
            emptyLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (var i = 0; i < entries.length; i++)
                InputChip(
                  label: Text(entries[i]),
                  onDeleted: () => onRemove(i),
                ),
            ],
          ),
      ],
    );
  }
}
