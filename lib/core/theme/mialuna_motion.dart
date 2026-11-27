import 'package:flutter/material.dart';

/// Shared timing for small interactions. Accessibility preferences apply to
/// implicit animations too, including when they change while a screen is open.
abstract final class MialunaMotion {
  static const quick = Duration(milliseconds: 160);
  static const standard = Duration(milliseconds: 220);
  static const curve = Curves.easeOutCubic;

  static Duration duration(BuildContext context, [Duration value = standard]) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : value;
}

/// A light press response without changing the child's layout or hit target.
/// InkWell handles scrolling cancellation, keyboard activation and semantics.
class MialunaPressable extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;

  const MialunaPressable({super.key, required this.onTap, required this.child});

  @override
  State<MialunaPressable> createState() => _MialunaPressableState();
}

class _MialunaPressableState extends State<MialunaPressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return InkWell(
      onTap: widget.onTap,
      onHighlightChanged: (value) => setState(() => _pressed = value),
      borderRadius: BorderRadius.circular(16),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      child: AnimatedScale(
        scale: _pressed && widget.onTap != null && !reduce ? 0.96 : 1,
        duration: MialunaMotion.duration(context, MialunaMotion.quick),
        curve: MialunaMotion.curve,
        child: widget.child,
      ),
    );
  }
}

/// A short fade and settle when an action or navigation item changes state.
class AnimatedSelectionIcon extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final IconData selectedIcon;

  const AnimatedSelectionIcon({
    super.key,
    required this.selected,
    required this.icon,
    required this.selectedIcon,
  });

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: MialunaMotion.duration(context, MialunaMotion.quick),
    switchInCurve: MialunaMotion.curve,
    switchOutCurve: Curves.easeIn,
    transitionBuilder: (child, animation) => FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.88, end: 1).animate(animation),
        child: child,
      ),
    ),
    child: Icon(selected ? selectedIcon : icon, key: ValueKey(selected)),
  );
}
