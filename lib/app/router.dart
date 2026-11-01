import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/create/create_screen.dart';
import '../features/explore/explore_screen.dart';
import '../features/feed/feed_screen.dart';
import '../features/feed/widgets/inline_video.dart';
import '../features/onboarding/login_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/reels/reels_screen.dart';
import '../l10n/strings.dart';
import 'providers.dart';

/// Whether the first-run onboarding has been completed. Overridden in
/// `main()` with the persisted value before the app starts.
final onboardingDoneProvider = Provider<bool>((ref) => false);

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingDone = ref.watch(onboardingDoneProvider);
  return GoRouter(
    initialLocation: onboardingDone ? '/home' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MialunaShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, _) => const FeedScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (_, _) => const ExploreScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/create', builder: (_, _) => const CreateScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/reels', builder: (_, _) => const ReelsScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class MialunaShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell shell;
  const MialunaShell({super.key, required this.shell});

  @override
  ConsumerState<MialunaShell> createState() => _MialunaShellState();
}

class _MialunaShellState extends ConsumerState<MialunaShell> {
  @override
  void initState() {
    super.initState();
    _syncTab();
  }

  @override
  void didUpdateWidget(MialunaShell old) {
    super.didUpdateWidget(old);
    _syncTab();
  }

  /// Keeps [currentTabProvider] right however the tab changed (tap, or
  /// `context.go` after publishing) and stops feed videos on a tab change.
  void _syncTab() {
    final index = widget.shell.currentIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(currentTabProvider) != index) {
        ref.read(currentTabProvider.notifier).state = index;
        ref.read(activeVideoProvider.notifier).state = null;
      }
    });
  }

  void _onTap(int i) {
    final shell = widget.shell;
    final reselect = i == shell.currentIndex;
    if (reselect) {
      // Same tab again: screens scroll to top and refresh.
      final tick = (ref.read(tabReselectProvider)?.tick ?? 0) + 1;
      ref.read(tabReselectProvider.notifier).state = TabReselect(i, tick);
    }
    shell.goBranch(i, initialLocation: reselect);
  }

  @override
  Widget build(BuildContext context) {
    final shell = widget.shell;
    return Scaffold(
      body: shell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: shell.currentIndex,
        onTap: _onTap,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: context.l10n.tabHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore_outlined),
            activeIcon: const Icon(Icons.explore),
            label: context.l10n.tabDiscover,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_circle_outline),
            activeIcon: const Icon(Icons.add_circle),
            label: context.l10n.tabCreate,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.play_circle_outline),
            activeIcon: const Icon(Icons.play_circle),
            label: context.l10n.tabReels,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: context.l10n.tabProfile,
          ),
        ],
      ),
    );
  }
}
