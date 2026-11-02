import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/text/hashtags.dart';

/// The inline spans of [text] with every `#hashtag` styled by [tagStyle] and,
/// when [onTap] is given, tappable. Each tappable tag gets a recognizer that
/// is added to [recognizers]: whoever builds the spans owns them and must
/// dispose them (see [HashtagText]).
List<InlineSpan> hashtagSpans(
  String text, {
  required TextStyle tagStyle,
  ValueChanged<String>? onTap,
  required List<TapGestureRecognizer> recognizers,
}) {
  final spans = <InlineSpan>[];
  var last = 0;
  for (final m in Hashtags.matches(text)) {
    if (m.start > last) {
      spans.add(TextSpan(text: text.substring(last, m.start)));
    }
    final tag = m.group(1)!;
    TapGestureRecognizer? recognizer;
    if (onTap != null) {
      recognizer = TapGestureRecognizer()..onTap = () => onTap(tag);
      recognizers.add(recognizer);
    }
    spans.add(
      TextSpan(text: m.group(0), style: tagStyle, recognizer: recognizer),
    );
    last = m.end;
  }
  if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
  return spans;
}

/// Text whose `#hashtags` can be tapped. [onHashtagTap] receives the tag
/// without the `#`; without it the tags are only highlighted.
class HashtagText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextStyle? tagStyle;
  final ValueChanged<String>? onHashtagTap;
  final int? maxLines;
  final TextOverflow overflow;
  final TextAlign? textAlign;

  const HashtagText(
    this.text, {
    super.key,
    this.style,
    this.tagStyle,
    this.onHashtagTap,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.textAlign,
  });

  @override
  State<HashtagText> createState() => _HashtagTextState();
}

class _HashtagTextState extends State<HashtagText> {
  final List<TapGestureRecognizer> _recognizers = [];

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final base = DefaultTextStyle.of(context).style.merge(widget.style);
    final tagStyle =
        widget.tagStyle ??
        base.copyWith(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.w600,
        );
    return Text.rich(
      TextSpan(
        style: widget.style,
        children: hashtagSpans(
          widget.text,
          tagStyle: tagStyle,
          onTap: widget.onHashtagTap,
          recognizers: _recognizers,
        ),
      ),
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      textAlign: widget.textAlign,
    );
  }
}
