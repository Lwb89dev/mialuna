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
import '../core/theme/mialuna_motion.dart';
import '../l10n/strings.dart';
import 'providers.dart';

/// Whether the first-run onboarding has been completed. Overridden in
/// `main()` with the persisted value before the app starts.
final onboardingDoneProvider = Provider<bool>((ref) => false);

/// The app's root navigator: a tapped system notification opens its screen on
/// top of everything with it.
final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingDone = ref.watch(onboardingDoneProvider);
  return GoRouter(
    navigatorKey: rootNavigatorKey,
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
    // Back from any other tab goes to Home first; only from Home does it
    // leave the app. Screens pushed on top of a tab pop before this applies.
    return PopScope(
      canPop: shell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) shell.goBranch(0);
      },
      child: Scaffold(
        body: shell,
        bottomNavigationBar: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant
                    .withValues(alpha: 0.45),
                width: 0.5,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: shell.currentIndex,
            onTap: _onTap,
            items: [
              BottomNavigationBarItem(
                icon: AnimatedSelectionIcon(
                  selected: shell.currentIndex == 0,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                ),
                label: context.l10n.tabHome,
              ),
              BottomNavigationBarItem(
                icon: AnimatedSelectionIcon(
                  selected: shell.currentIndex == 1,
                  icon: Icons.explore_outlined,
                  selectedIcon: Icons.explore,
                ),
                label: context.l10n.tabDiscover,
              ),
              BottomNavigationBarItem(
                icon: AnimatedSelectionIcon(
                  selected: shell.currentIndex == 2,
                  icon: Icons.add_circle_outline,
                  selectedIcon: Icons.add_circle,
                ),
                label: context.l10n.tabCreate,
              ),
              BottomNavigationBarItem(
                icon: AnimatedSelectionIcon(
                  selected: shell.currentIndex == 3,
                  icon: Icons.play_circle_outline,
                  selectedIcon: Icons.play_circle,
                ),
                label: context.l10n.tabReels,
              ),
              BottomNavigationBarItem(
                icon: AnimatedSelectionIcon(
                  selected: shell.currentIndex == 4,
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                ),
                label: context.l10n.tabProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
