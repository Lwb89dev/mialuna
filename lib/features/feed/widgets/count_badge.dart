import 'package:flutter/material.dart';

/// The number on an icon of the Home bar (unread notifications, unread
/// messages). Hidden at zero, "99+" past ninety-nine so it never outgrows the
/// icon.
class CountBadge extends StatelessWidget {
  final int count;
  final Widget child;

  const CountBadge({super.key, required this.count, required this.child});

  static String labelFor(int count) => count > 99 ? '99+' : '$count';

  @override
  Widget build(BuildContext context) => Badge(
    isLabelVisible: count > 0,
    label: Text(labelFor(count)),
    child: child,
  );
}
