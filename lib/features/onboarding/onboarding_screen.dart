import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/nostr/nwc_controller.dart';
import '../../l10n/strings.dart';
import '../private/close_friends_screen.dart' show CloseFriendsExplainer;
import 'login_panel.dart';

const onboardingDoneKey = 'onboarding_done';

/// First-run onboarding: 1) welcome, 2) public vs. private (what close
/// friends protects and what it cannot), 3) sign-in, 4) permissions and
/// optional Nostr Wallet Connect link.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _nwcController = TextEditingController();
  int _page = 0;
  String? _nwcError;
  bool _photosGranted = false;
  bool _notificationsGranted = false;

  @override
  void initState() {
    super.initState();
    _refreshPermissions();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nwcController.dispose();
    super.dispose();
  }

  Future<void> _refreshPermissions() async {
    final photos = await Permission.photos.isGranted;
    final notifications = await Permission.notification.isGranted;
    if (mounted) {
      setState(() {
        _photosGranted = photos;
        _notificationsGranted = notifications;
      });
    }
  }

  void _goTo(int page) => _pageController.animateToPage(
    page,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingDoneKey, true);
    if (mounted) context.go('/home');
  }

  Future<void> _saveNwc() async {
    final uri = _nwcController.text.trim();
    if (uri.isEmpty) return;
    try {
      await ref.read(nwcProvider.notifier).connect(uri);
      setState(() => _nwcError = null);
    } catch (e) {
      setState(() => _nwcError = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _WelcomePage(theme: theme),
                  const _PublicPrivatePage(),
                  ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(
                        context.l10n.signIn,
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      LoginPanel(onLoggedIn: () => _goTo(3)),
                    ],
                  ),
                  _buildPermissionsPage(theme),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      4,
                      (i) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _page
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                  ),
                  if (_page < 3)
                    TextButton(
                      onPressed: _finish,
                      child: Text(context.l10n.skip),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsPage(ThemeData theme) {
    final nwc = ref.watch(nwcProvider);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          context.l10n.permissionsAndWallet,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.permissionsExplain,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.photo_library_outlined),
          title: Text(context.l10n.photosAndVideos),
          subtitle: Text(context.l10n.toUploadYourMoments),
          trailing: _photosGranted
              ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
              : FilledButton.tonal(
                  onPressed: () async {
                    await Permission.photos.request();
                    await Permission.videos.request();
                    await _refreshPermissions();
                  },
                  child: Text(context.l10n.allow),
                ),
        ),
        ListTile(
          leading: const Icon(Icons.notifications_outlined),
          title: Text(context.l10n.notifications),
          subtitle: Text(context.l10n.reactionsCommentsZaps),
          trailing: _notificationsGranted
              ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
              : FilledButton.tonal(
                  onPressed: () async {
                    await Permission.notification.request();
                    await _refreshPermissions();
                  },
                  child: Text(context.l10n.allow),
                ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Text(
          context.l10n.lightningWalletOptional,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.nwcExplain,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 12),
        if (nwc != null)
          ListTile(
            leading: Icon(Icons.bolt, color: theme.colorScheme.primary),
            title: Text(context.l10n.walletConnected),
            subtitle: Text(
              '${nwc.walletPubkey.substring(0, 12)}…',
              style: theme.textTheme.bodySmall,
            ),
            trailing: TextButton(
              onPressed: () => ref.read(nwcProvider.notifier).disconnect(),
              child: Text(context.l10n.disconnect),
            ),
          )
        else ...[
          TextField(
            controller: _nwcController,
            decoration: const InputDecoration(
              labelText: 'nostr+walletconnect://…',
              border: OutlineInputBorder(),
            ),
            autocorrect: false,
            enableSuggestions: false,
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: _saveNwc,
            child: Text(context.l10n.connectWallet),
          ),
          if (_nwcError != null) ...[
            const SizedBox(height: 8),
            Text(
              _nwcError!,
              style: TextStyle(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ],
        ],
        const SizedBox(height: 32),
        FilledButton(onPressed: _finish, child: Text(context.l10n.getStarted)),
      ],
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final ThemeData theme;
  const _WelcomePage({required this.theme});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 48),
        ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Image.asset('assets/icons/icon.png', width: 140, height: 140),
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
          context.l10n.tagline,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          context.l10n.welcome1,
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.welcome2,
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.welcome3,
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// What is public, what is private, and where the limits are — before the
/// user publishes anything.
class _PublicPrivatePage extends StatelessWidget {
  const _PublicPrivatePage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          context.l10n.publicAndPrivate,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.publicAndPrivateIntro,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Text(context.l10n.closeFriends, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        const CloseFriendsExplainer(),
      ],
    );
  }
}
