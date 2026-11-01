import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/nostr/nwc_controller.dart';
import 'login_panel.dart';

const onboardingDoneKey = 'onboarding_done';

/// First-run onboarding: 1) welcome, 2) sign-in, 3) permissions and
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
                  ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(
                        'Accedi',
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      LoginPanel(onLoggedIn: () => _goTo(2)),
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
                      3,
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
                  if (_page < 2)
                    TextButton(onPressed: _finish, child: const Text('Salta')),
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
          'Permessi e wallet',
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Servono solo a farti pubblicare e ricevere notifiche. '
          'Puoi cambiarli in qualsiasi momento dalle impostazioni di sistema.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.photo_library_outlined),
          title: const Text('Foto e video'),
          subtitle: const Text('Per caricare i tuoi momenti'),
          trailing: _photosGranted
              ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
              : FilledButton.tonal(
                  onPressed: () async {
                    await Permission.photos.request();
                    await Permission.videos.request();
                    await _refreshPermissions();
                  },
                  child: const Text('Consenti'),
                ),
        ),
        ListTile(
          leading: const Icon(Icons.notifications_outlined),
          title: const Text('Notifiche'),
          subtitle: const Text('Reazioni, commenti e zap'),
          trailing: _notificationsGranted
              ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
              : FilledButton.tonal(
                  onPressed: () async {
                    await Permission.notification.request();
                    await _refreshPermissions();
                  },
                  child: const Text('Consenti'),
                ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Text('Wallet Lightning (opzionale)', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Text(
          'Collega un wallet Nostr Wallet Connect per inviare zap '
          'senza lasciare l\'app.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 12),
        if (nwc != null)
          ListTile(
            leading: Icon(Icons.bolt, color: theme.colorScheme.primary),
            title: const Text('Wallet collegato'),
            subtitle: Text(
              '${nwc.walletPubkey.substring(0, 12)}…',
              style: theme.textTheme.bodySmall,
            ),
            trailing: TextButton(
              onPressed: () => ref.read(nwcProvider.notifier).disconnect(),
              child: const Text('Scollega'),
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
            child: const Text('Collega wallet'),
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
        FilledButton(onPressed: _finish, child: const Text('Inizia')),
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
          'Your moments, under the same moon.',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Mialuna is a visual social network: photos, videos, Reels and '
          'Stories — never text-only posts.',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'It runs on Nostr, an open protocol: your identity is a key you '
          'own, not an account a company can take away. No ads, no '
          'trackers, no central servers.',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Share your light with people everywhere, from any app that '
          'speaks the same open language.',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
