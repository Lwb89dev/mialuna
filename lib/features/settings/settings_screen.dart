import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/providers.dart';
import '../../app/relay_sync.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/branding/app_info.dart';
import '../../core/nostr/relay.dart';
import '../../core/nostr/relay_pool.dart';
import '../../l10n/strings.dart';
import '../feed/widgets/post_card.dart' show closeFriendsGreen;
import '../onboarding/onboarding_screen.dart' show onboardingDoneKey;
import '../private/close_friends.dart';
import '../private/close_friends_screen.dart';
import '../profile/profile_widgets.dart';
import '../notifications/notification_settings.dart';
import '../social/moderation_controller.dart';
import '../stories/story_views_setting.dart';
import 'system_notifications_tile.dart';
import '../trust/trust_section.dart';
import 'settings_controller.dart';
import 'support_section.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _relayController = TextEditingController();
  final _hashtagController = TextEditingController();
  final _blossomController = TextEditingController();

  @override
  void dispose() {
    _relayController.dispose();
    _hashtagController.dispose();
    _blossomController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Applies a manual relay edit and, when signed in, publishes it as the
  /// user's NIP-65 list so other apps pick it up too.
  Future<void> _changeRelays(List<RelayConfig> relays) async {
    final l10n = context.l10n;
    final pub = ref.read(authProvider).publicKey;
    final clean = await ref
        .read(settingsProvider.notifier)
        .setRelays(relays, owner: pub);
    if (clean == null) {
      _toast(l10n.needOneReadRelay);
      return;
    }
    if (pub == null) return;
    final report = await ref
        .read(relaySyncProvider.notifier)
        .publishRelayList();
    if (report == null) {
      _toast(l10n.listSavedLocally);
    } else if (!report.publishedSomewhere) {
      _toast(l10n.noRelayAcceptedList);
    } else {
      _toast(l10n.relayListPublishedTo(report.acceptedCount));
    }
  }

  Future<void> _changeBlossom(Future<void> Function() change) async {
    final l10n = context.l10n;
    await change();
    if (ref.read(authProvider).publicKey == null) return;
    final report = await ref
        .read(relaySyncProvider.notifier)
        .publishBlossomList();
    if (report != null && report.publishedSomewhere) {
      _toast(l10n.mediaServersUpdated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final sync = ref.watch(relaySyncProvider);
    final auth = ref.watch(authProvider);
    final isGuest = auth.isGuest;
    final theme = Theme.of(context);
    final pool = ref.watch(relayPoolProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(context.l10n.appearance, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: const Icon(Icons.light_mode_outlined),
                  label: Text(context.l10n.themeLight),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: const Icon(Icons.dark_mode_outlined),
                  label: Text(context.l10n.themeDark),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: const Icon(Icons.brightness_auto_outlined),
                  label: Text(context.l10n.themeSystem),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) =>
                  ref.read(settingsProvider.notifier).setThemeMode(s.first),
            ),
          ),
          const SizedBox(height: 16),
          Text(context.l10n.languageTitle, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: systemLanguage,
                  label: Text(context.l10n.languageSystem),
                ),
                ButtonSegment(
                  value: 'en',
                  label: Text(context.l10n.languageEnglish),
                ),
                ButtonSegment(
                  value: 'it',
                  label: Text(context.l10n.languageItalian),
                ),
              ],
              selected: {settings.language},
              onSelectionChanged: (s) =>
                  ref.read(settingsProvider.notifier).setLanguage(s.first),
            ),
          ),
          const SizedBox(height: 24),
          Text(context.l10n.relays, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            isGuest
                ? context.l10n.relaysExplainSignedOut
                : context.l10n.relaysExplainSynced,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          if (!isGuest) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    sync.syncing ? Icons.sync : Icons.check_circle_outline,
                    size: 16,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    sync.syncing
                        ? context.l10n.syncing
                        : (sync.message ?? context.l10n.waitingFirstSync),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: sync.syncing
                    ? null
                    : () => ref
                          .read(relaySyncProvider.notifier)
                          .sync(force: true),
                child: Text(context.l10n.syncNow),
              ),
            ),
          ],
          const SizedBox(height: 4),
          StreamBuilder<Map<String, RelayConnectionState>>(
            stream: pool.statusStream,
            initialData: pool.statuses,
            builder: (context, snapshot) {
              final status = snapshot.data ?? const {};
              return Column(
                children: [
                  for (final relay in settings.relays)
                    _RelayTile(
                      relay: relay,
                      state: status[relay.url],
                      onChanged: (updated) => _changeRelays([
                        for (final r in settings.relays)
                          r.url == relay.url ? updated : r,
                      ]),
                      onRemove: settings.relays.length > 1
                          ? () => _changeRelays([
                              for (final r in settings.relays)
                                if (r.url != relay.url) r,
                            ])
                          : null,
                    ),
                ],
              );
            },
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _relayController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    hintText: 'wss://relay.esempio.com',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addRelay(settings),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: const Icon(Icons.add),
                tooltip: context.l10n.addRelay,
                onPressed: () => _addRelay(settings),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => _changeRelays(List.of(defaultRelayConfigs)),
              child: Text(context.l10n.restoreDefaultRelays),
            ),
          ),
          const SizedBox(height: 16),
          Text(context.l10n.closeFriends, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.star_outline, color: closeFriendsGreen),
            title: Text(
              ref.watch(closeFriendsProvider).members.isEmpty
                  ? context.l10n.createYourList
                  : context.l10n.peopleCount(
                      ref.watch(closeFriendsProvider).members.length,
                    ),
            ),
            subtitle: Text(context.l10n.closeFriendsSettingsNote),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => CloseFriendsScreen.open(context),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.mediaServersBlossom,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.mediaServersExplain,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 4),
          for (var i = 0; i < settings.blossomServers.length; i++)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                i == 0 ? Icons.star : Icons.cloud_upload_outlined,
                color: i == 0 ? theme.colorScheme.secondary : null,
              ),
              title: Text(
                settings.blossomServers[i].replaceFirst('https://', ''),
                style: theme.textTheme.bodyMedium,
              ),
              subtitle: i == 0 ? Text(context.l10n.primary) : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (i > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_upward, size: 20),
                      tooltip: context.l10n.makePrimary,
                      onPressed: () => _changeBlossom(
                        () => ref
                            .read(settingsProvider.notifier)
                            .makeBlossomPrimary(settings.blossomServers[i]),
                      ),
                    ),
                  if (settings.blossomServers.length > 1)
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      tooltip: context.l10n.remove,
                      onPressed: () => _changeBlossom(
                        () => ref
                            .read(settingsProvider.notifier)
                            .removeBlossomServer(settings.blossomServers[i]),
                      ),
                    ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _blossomController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    hintText: 'https://blossom.esempio.com',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addBlossom(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: const Icon(Icons.add),
                tooltip: context.l10n.addServer,
                onPressed: _addBlossom,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(context.l10n.moderation, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            context.l10n.moderationExplain,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          _PeopleSection(
            title: context.l10n.mutedAuthors,
            emptyLabel: context.l10n.noMutedAuthors,
            pubkeys: ref.watch(muteControllerProvider).pubkeys.toList(),
            onRemove: (pk) =>
                ref.read(muteControllerProvider.notifier).unmute(pk),
          ),
          _PeopleSection(
            title: context.l10n.blockedAuthors,
            emptyLabel: context.l10n.noBlockedAuthors,
            pubkeys: ref.watch(blockProvider).toList(),
            onRemove: (pk) => ref.read(blockProvider.notifier).unblock(pk),
          ),
          _TagSection(
            title: context.l10n.hiddenHashtags,
            emptyLabel: context.l10n.noHiddenHashtags,
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
                  decoration: InputDecoration(
                    hintText: context.l10n.hashtagToHide,
                    isDense: true,
                    border: const OutlineInputBorder(),
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
          const SystemNotificationsTile(),
          const SizedBox(height: 8),
          const NewFollowersSetting(),
          const SizedBox(height: 16),
          const TrustSection(),
          const SizedBox(height: 16),
          const StoryViewsSetting(),
          const SizedBox(height: 24),
          Text(context.l10n.storage, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.cleaning_services_outlined),
            label: Text(context.l10n.clearCache),
            onPressed: () async {
              final l10n = context.l10n;
              await ref.read(localCacheProvider).clearEvents();
              await ref.read(localCacheProvider).deleteDraft('composer_draft');
              _toast(l10n.cacheCleared);
            },
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline),
            title: Text(context.l10n.reviewIntro),
            subtitle: Text(context.l10n.reviewIntroSubtitle),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool(onboardingDoneKey, false);
              if (context.mounted) context.go('/onboarding');
            },
          ),
          const SizedBox(height: 16),
          SupportSection(
            onCopied: () => _toast(
              context.l10n.noLightningWalletCopied(Support.lightningAddress),
            ),
          ),
          const SizedBox(height: 24),
          Text(context.l10n.about, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            context.l10n.aboutText(appVersion),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  void _addRelay(AppSettings settings) {
    final url = normalizeRelayUrl(_relayController.text);
    if (url == null || !isAcceptableRelayUrl(url)) {
      _toast(context.l10n.invalidRelayAddress);
      return;
    }
    _relayController.clear();
    _changeRelays([...settings.relays, RelayConfig(url)]);
  }

  void _addBlossom() {
    final text = _blossomController.text.trim();
    if (text.isEmpty) return;
    _blossomController.clear();
    _changeBlossom(
      () => ref.read(settingsProvider.notifier).addBlossomServer(text),
    );
  }
}

class _RelayTile extends StatelessWidget {
  final RelayConfig relay;
  final RelayConnectionState? state;
  final ValueChanged<RelayConfig> onChanged;
  final VoidCallback? onRemove;

  const _RelayTile({
    required this.relay,
    required this.state,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (state) {
      RelayConnectionState.connected => Colors.green,
      RelayConnectionState.connecting => Colors.orange,
      RelayConnectionState.failed => Colors.red,
      _ => theme.colorScheme.outline,
    };
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.circle, size: 12, color: color),
      title: Text(
        relay.url.replaceFirst(RegExp(r'^wss?://'), ''),
        style: theme.textTheme.bodyMedium,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Wrap(
        spacing: 6,
        children: [
          FilterChip(
            label: Text(context.l10n.relayRead),
            visualDensity: VisualDensity.compact,
            selected: relay.read,
            onSelected: (v) => onChanged(relay.copyWith(read: v)),
          ),
          FilterChip(
            label: Text(context.l10n.relayWrite),
            visualDensity: VisualDensity.compact,
            selected: relay.write,
            onSelected: (v) => onChanged(relay.copyWith(write: v)),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle_outline),
        tooltip: context.l10n.remove,
        onPressed: onRemove,
      ),
    );
  }
}

class _PeopleSection extends StatelessWidget {
  final String title;
  final String emptyLabel;
  final List<String> pubkeys;
  final void Function(String pubkey) onRemove;

  const _PeopleSection({
    required this.title,
    required this.emptyLabel,
    required this.pubkeys,
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
        if (pubkeys.isEmpty)
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
              for (final pk in pubkeys)
                InputChip(
                  avatar: ProfileAvatar(
                    pubkey: pk,
                    radius: 11,
                    tappable: false,
                  ),
                  label: AuthorName(pubkey: pk, tappable: false),
                  onDeleted: () => onRemove(pk),
                ),
            ],
          ),
      ],
    );
  }
}

class _TagSection extends StatelessWidget {
  final String title;
  final String emptyLabel;
  final List<String> entries;
  final void Function(int index) onRemove;

  const _TagSection({
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
