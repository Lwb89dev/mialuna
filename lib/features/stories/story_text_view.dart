import 'package:flutter/material.dart';

import '../../core/nostr/models/story_text.dart';
import '../feed/widgets/hashtag_text.dart';

/// Where a picture of [aspect] (width over height) lands inside [box] when it
/// is shown whole (`BoxFit.contain`). Texts are placed relative to this
/// rectangle, never to the screen, so they sit on the same spot of the
/// picture on every device. Without a known aspect the whole [box] is used.
Rect storyMediaRect(Size box, double? aspect) {
  if (aspect == null || aspect <= 0 || box.isEmpty) return Offset.zero & box;
  final fitted = applyBoxFit(BoxFit.contain, Size(aspect, 1), box).destination;
  return Alignment.center.inscribe(fitted, Offset.zero & box);
}

/// Base letter size as a fraction of the picture's width ([StoryText.scale]
/// 1), and the widest a text may grow before it wraps.
const _baseSize = 0.062;
const _maxWidth = 0.86;

/// The letters of a story text at [size] logical pixels.
TextStyle storyTextStyle(StoryTextFont font, double size) => switch (font) {
  StoryTextFont.classic => TextStyle(
    fontSize: size,
    fontWeight: FontWeight.w600,
    height: 1.2,
  ),
  StoryTextFont.bold => TextStyle(
    fontSize: size,
    fontWeight: FontWeight.w900,
    height: 1.2,
  ),
  StoryTextFont.serif => TextStyle(
    fontSize: size,
    fontFamily: 'serif',
    fontFamilyFallback: const ['Georgia', 'Times New Roman'],
    fontWeight: FontWeight.w700,
    height: 1.2,
  ),
  StoryTextFont.mono => TextStyle(
    fontSize: size,
    fontFamily: 'monospace',
    fontFamilyFallback: const ['Courier New', 'Courier'],
    fontWeight: FontWeight.w600,
    height: 1.2,
  ),
  StoryTextFont.italic => TextStyle(
    fontSize: size,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w600,
    height: 1.2,
  ),
};

/// Opaque Flutter colour of a story text's `0xRRGGBB`.
Color storyColor(int rgb) => Color(0xFF000000 | (rgb & 0xFFFFFF));

/// Letter colour that stays readable on a pill painted in [pill].
Color _onPill(Color pill) =>
    ThemeData.estimateBrightnessForColor(pill) == Brightness.light
    ? Colors.black
    : Colors.white;

/// How a story text looks on a picture [mediaWidth] logical pixels wide: the
/// letters, their size, and the colour of the pill behind them (null = none).
/// The editor writes with the very same look, so what you type is what is
/// published.
({TextStyle style, Color? pill, double size}) storyTextLook(
  StoryText text,
  double mediaWidth,
) {
  final size = mediaWidth * _baseSize * text.scale;
  final color = storyColor(text.color);
  final (letters, pill) = switch (text.background) {
    StoryTextBackground.none => (color, null),
    StoryTextBackground.solid => (_onPill(color), color),
    StoryTextBackground.veil => (color, Colors.black.withValues(alpha: 0.55)),
  };
  final style = storyTextStyle(text.font, size).copyWith(
    color: letters,
    shadows: pill == null
        ? [Shadow(blurRadius: size * 0.25, color: Colors.black54)]
        : null,
  );
  return (style: style, pill: pill, size: size);
}

/// How a `#hashtag` stands out in a story text: a thick underline, so that
/// it reads as a link on any picture.
TextStyle storyTagStyle(TextStyle base) => base.copyWith(
  decoration: TextDecoration.underline,
  decorationColor: base.color,
  decorationThickness: 2.4,
);

/// The widest a story text may grow on a picture [mediaWidth] wide.
double storyTextMaxWidth(double mediaWidth) => mediaWidth * _maxWidth;

/// [child] on a rounded pill of colour [pill] (none → the bare child).
Widget storyTextPill({
  required Color? pill,
  required double size,
  required Widget child,
}) {
  if (pill == null) return child;
  return DecoratedBox(
    decoration: BoxDecoration(
      color: pill,
      borderRadius: BorderRadius.circular(size * 0.35),
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.5,
        vertical: size * 0.25,
      ),
      child: child,
    ),
  );
}

/// One story text, drawn for a picture [mediaWidth] logical pixels wide.
/// Hashtags are underlined, and tappable when [onHashtagTap] is given.
class StoryTextView extends StatelessWidget {
  final StoryText text;
  final double mediaWidth;
  final ValueChanged<String>? onHashtagTap;

  const StoryTextView({
    super.key,
    required this.text,
    required this.mediaWidth,
    this.onHashtagTap,
  });

  @override
  Widget build(BuildContext context) {
    final look = storyTextLook(text, mediaWidth);
    // The size follows the picture, not the user's font-size setting: the
    // same text must wrap the same way for everybody.
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: storyTextMaxWidth(mediaWidth)),
        child: storyTextPill(
          pill: look.pill,
          size: look.size,
          child: HashtagText(
            text.text,
            style: look.style,
            tagStyle: storyTagStyle(look.style),
            onHashtagTap: onHashtagTap,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// A [Positioned] that puts [child] — the view of [text] — centred on the
/// spot of the picture [media] that the text points at, turned by its
/// rotation. Must sit directly inside a [Stack].
Widget placeStoryText(StoryText text, Rect media, Widget child, {Key? key}) =>
    Positioned(
      key: key,
      left: media.left + text.x * media.width,
      top: media.top + text.y * media.height,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Transform.rotate(angle: text.rotation, child: child),
      ),
    );

/// The texts of a story, laid over its picture. Fill the area the picture is
/// shown in; [mediaAspect] is the picture's width over height.
class StoryOverlayLayer extends StatelessWidget {
  final List<StoryText> texts;
  final double? mediaAspect;
  final ValueChanged<String>? onHashtagTap;

  const StoryOverlayLayer({
    super.key,
    required this.texts,
    this.mediaAspect,
    this.onHashtagTap,
  });

  @override
  Widget build(BuildContext context) {
    if (texts.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final media = storyMediaRect(constraints.biggest, mediaAspect);
        return Stack(
          children: [
            for (final t in texts)
              placeStoryText(
                t,
                media,
                StoryTextView(
                  text: t,
                  mediaWidth: media.width,
                  onHashtagTap: onHashtagTap,
                ),
              ),
          ],
        );
      },
    );
  }
}
