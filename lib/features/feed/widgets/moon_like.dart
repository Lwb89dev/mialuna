import 'dart:math' as math;

import 'package:flutter/material.dart';

const _moonAsset = 'assets/moon/full_moon.png';

/// Greys the moon out: the "not liked" state.
const _greyscale = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
]);

/// The like icon: a realistic full moon. Dim and grey while not liked, warm
/// and glowing once liked; it pulses (twice, like Instagram's heart) at the
/// moment it becomes liked, and not when a post is merely shown already liked.
class MoonLikeIcon extends StatefulWidget {
  final bool liked;
  final double size;

  /// Colour of the glow around a liked moon.
  final Color glow;
  const MoonLikeIcon({
    super.key,
    required this.liked,
    this.size = 24,
    this.glow = const Color(0xFFFFC85A),
  });

  @override
  State<MoonLikeIcon> createState() => _MoonLikeIconState();
}

class _MoonLikeIconState extends State<MoonLikeIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  /// Squash, then a big beat, a small one, and rest.
  static final _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 0.8,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 14,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 0.8,
        end: 1.32,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 30,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.32,
        end: 0.94,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 24,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 0.94,
        end: 1.1,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 16,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.1,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 16,
    ),
  ]);

  @override
  void didUpdateWidget(MoonLikeIcon old) {
    super.didUpdateWidget(old);
    if (widget.liked && !old.liked) _pulse.forward(from: 0);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final t = _pulse.value;
        // The glow swells with the first beat and settles to a soft halo.
        final bloom = widget.liked ? 0.45 + 0.55 * math.sin(math.pi * t) : 0.0;
        return Transform.scale(
          scale: _scale.transform(t),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: widget.liked
                  ? [
                      BoxShadow(
                        color: widget.glow.withValues(alpha: 0.55 * bloom),
                        blurRadius: size * 0.55 * (0.6 + bloom),
                        spreadRadius: size * 0.04 * bloom,
                      ),
                    ]
                  : null,
            ),
            child: Opacity(
              opacity: widget.liked ? 1 : 0.55,
              child: ColorFiltered(
                colorFilter: widget.liked
                    ? const ColorFilter.mode(
                        Colors.transparent,
                        BlendMode.srcOver,
                      )
                    : _greyscale,
                child: Image.asset(
                  _moonAsset,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                  gaplessPlayback: true,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The big moon that pops up in the middle of a picture on a double tap:
/// it appears with an overshoot, hovers for a moment, then drifts up a little
/// and fades. Every change of [trigger] plays it again.
class MoonBurst extends StatefulWidget {
  final int trigger;
  final double size;
  const MoonBurst({super.key, required this.trigger, this.size = 112});

  @override
  State<MoonBurst> createState() => _MoonBurstState();
}

class _MoonBurstState extends State<MoonBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  static final _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 0.3,
        end: 1.25,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 22,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.25,
        end: 0.95,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 14,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 0.95,
        end: 1.05,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 14,
    ),
    TweenSequenceItem(tween: ConstantTween(1.05), weight: 20),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.05,
        end: 1.5,
      ).chain(CurveTween(curve: Curves.easeIn)),
      weight: 30,
    ),
  ]);

  static final _opacity = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 56),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 34),
  ]);

  @override
  void didUpdateWidget(MoonBurst old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            if (_c.isDismissed) return const SizedBox.shrink();
            final t = _c.value;
            return Opacity(
              opacity: _opacity.transform(t),
              child: Transform.translate(
                offset: Offset(
                  0,
                  -widget.size * 0.35 * Curves.easeIn.transform(t),
                ),
                child: Transform.scale(
                  scale: _scale.transform(t),
                  child: child,
                ),
              ),
            );
          },
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFC85A).withValues(alpha: 0.6),
                  blurRadius: widget.size * 0.4,
                  spreadRadius: widget.size * 0.04,
                ),
              ],
            ),
            child: Image.asset(
              _moonAsset,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
    );
  }
}
