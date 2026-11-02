import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

/// Where the arcs of a ring of [count] equal parts start and how far they
/// sweep (radians, clockwise from the top). With one part the ring is whole;
/// with more, a small gap separates the parts, shrinking when there are many
/// so that every one stays visible.
List<({double start, double sweep})> storyRingArcs(int count) {
  if (count <= 0) return const [];
  const full = 2 * math.pi;
  const top = -math.pi / 2;
  if (count == 1) return [(start: top, sweep: full)];
  final part = full / count;
  final gap = math.min(0.16, part * 0.3);
  return [
    for (var i = 0; i < count; i++)
      (start: top + part * i + gap / 2, sweep: part - gap),
  ];
}

/// What one part of a ring says about its story.
enum StorySegment {
  /// Not watched yet: the brand gradient.
  unseen,

  /// Watched: a quiet grey.
  seen,

  /// Not watched yet, and meant for close friends only: green.
  closeFriends,
}

/// The colours of the ring of a story not watched yet: moonlight to twilight.
const storyRingGradient = [
  Color(0xFFFFB36B),
  Color(0xFFEF6F8E),
  Color(0xFF9B7BFF),
  Color(0xFFFFB36B),
];

/// A ring around a story avatar, divided into as many equal parts as the
/// person has stories from the last 24 hours — one part per story, so a
/// glance tells which are new and which are seen.
class StoryRing extends StatelessWidget {
  /// One entry per story, oldest first (clockwise from the top).
  final List<StorySegment> segments;
  final double size;
  final double strokeWidth;
  final Widget child;

  const StoryRing({
    super.key,
    required this.segments,
    required this.child,
    this.size = 66,
    this.strokeWidth = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          segments,
          strokeWidth,
          seen: Theme.of(context).colorScheme.outlineVariant,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final List<StorySegment> segments;
  final double strokeWidth;
  final Color seen;
  const _RingPainter(this.segments, this.strokeWidth, {required this.seen});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final arcs = storyRingArcs(segments.length);
    final gradient = SweepGradient(
      colors: storyRingGradient,
      transform: const GradientRotation(-math.pi / 2),
    ).createShader(rect);
    for (var i = 0; i < arcs.length; i++) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = segments.length == 1 ? StrokeCap.butt : StrokeCap.round
        ..isAntiAlias = true;
      switch (segments[i]) {
        case StorySegment.unseen:
          paint.shader = gradient;
        case StorySegment.seen:
          paint.color = seen;
        case StorySegment.closeFriends:
          paint.color = const Color(0xFF2EB872);
      }
      canvas.drawArc(rect, arcs[i].start, arcs[i].sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.strokeWidth != strokeWidth ||
      old.seen != seen ||
      !listEquals(old.segments, segments);
}
