import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/nostr/models/story_text.dart';
import '../../l10n/strings.dart';
import 'story_canvas_editor.dart';

/// Full-screen editor that lays texts over a story's picture, like
/// Instagram — written right on the photo (see [StoryCanvasEditor]). Returns
/// the texts when done, null when the user backs out.
class StoryTextEditorScreen extends StatefulWidget {
  /// The picture (or a frame of the video); null shows a plain backdrop.
  final Uint8List? imageBytes;

  /// Width over height of the picture; unknown → a phone-screen shape.
  final double? mediaAspect;
  final List<StoryText> initial;

  const StoryTextEditorScreen({
    super.key,
    this.imageBytes,
    this.mediaAspect,
    this.initial = const [],
  });

  static Future<List<StoryText>?> show(
    BuildContext context, {
    Uint8List? imageBytes,
    double? mediaAspect,
    List<StoryText> initial = const [],
  }) => Navigator.of(context, rootNavigator: true).push<List<StoryText>>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => StoryTextEditorScreen(
        imageBytes: imageBytes,
        mediaAspect: mediaAspect,
        initial: initial,
      ),
    ),
  );

  @override
  State<StoryTextEditorScreen> createState() => _StoryTextEditorScreenState();
}

class _StoryTextEditorScreenState extends State<StoryTextEditorScreen> {
  final _canvas = GlobalKey<StoryCanvasEditorState>();
  late List<StoryText> _texts = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // The keyboard must not squeeze the picture; the writer deals with it.
      resizeToAvoidBottomInset: false,
      body: StoryCanvasEditor(
        key: _canvas,
        imageBytes: widget.imageBytes,
        mediaAspect: widget.mediaAspect,
        initial: widget.initial,
        onChanged: (texts) => setState(() => _texts = texts),
        top: _topBar(context.l10n),
        bottom: _hint(context.l10n),
      ),
    );
  }

  Widget _topBar(AppLocalizations l10n) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    child: Row(
      children: [
        const CloseButton(color: Colors.white),
        Expanded(child: _topActions(l10n)),
      ],
    ),
  );

  /// Add-text and Done shrink together when a long "done" does not fit
  /// beside the close button at a large text size.
  Widget _topActions(AppLocalizations l10n) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerEnd,
        child: _addAndDone(l10n),
      ),
    );
  }

  Widget _addAndDone(AppLocalizations l10n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: l10n.storyAddText,
          color: Colors.white,
          icon: const Icon(Icons.text_fields),
          onPressed: () => _canvas.currentState?.addText(),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _texts),
          child: Text(
            l10n.done,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _hint(AppLocalizations l10n) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
    child: Text(
      l10n.storyTextsHelp,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white70, fontSize: 12),
    ),
  );
}
