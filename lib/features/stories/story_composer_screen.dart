import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/theme/mialuna_theme.dart';
import '../../l10n/strings.dart';
import '../create/create_controller.dart';
import '../create/editor/image_editor_screen.dart';
import '../private/close_friends.dart';
import '../private/close_friends_screen.dart';
import 'story_canvas_editor.dart';

/// Where "your story" is made, like Instagram's: choose a picture or a video,
/// write on it right there, choose who sees it, share. Opened by the plus
/// circle at the head of the stories rail.
///
/// It drives the same composer as the Create tab, so a story is published
/// exactly the same way (metadata stripped, uploaded, signed — or encrypted
/// for the close friends).
class StoryComposerScreen extends ConsumerStatefulWidget {
  /// Starts from nothing and opens the gallery at once. Tests turn it off to
  /// hand in a picture of their own.
  final bool fresh;

  const StoryComposerScreen({super.key, this.fresh = true});

  static Future<void> show(BuildContext context) =>
      Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const StoryComposerScreen(),
        ),
      );

  @override
  ConsumerState<StoryComposerScreen> createState() =>
      _StoryComposerScreenState();
}

class _StoryComposerScreenState extends ConsumerState<StoryComposerScreen> {
  /// One editor per picture: a new picture starts a clean canvas.
  var _canvas = GlobalKey<StoryCanvasEditorState>();

  /// What the texts are laid over, for the picture currently in the composer.
  ({Uint8List? bytes, double? aspect})? _backdrop;
  PickedMedia? _backdropFor;

  /// The story is gone (shared or thrown away) and the screen is on its way
  /// out: it must not flash its "choose a picture" state while it leaves.
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _begin());
  }

  Future<void> _begin() async {
    if (!mounted) return;
    final composer = ref.read(composerProvider.notifier);
    if (!widget.fresh) {
      composer.setMode(ComposerMode.story);
      return;
    }
    composer.startStory();
    await _pick(composer.pickImages);
  }

  /// A picker that cannot open leaves the screen on its three buttons.
  Future<void> _pick(Future<void> Function() picker) async {
    try {
      await picker();
    } catch (_) {
      // Nothing was chosen.
    }
  }

  Future<void> _loadBackdrop(PickedMedia media) async {
    _backdropFor = media;
    _backdrop = null;
    _canvas = GlobalKey<StoryCanvasEditorState>();
    final backdrop = await ref.read(composerProvider.notifier).storyBackdrop();
    if (!mounted || !identical(_backdropFor, media)) return;
    setState(() => _backdrop = backdrop);
  }

  Future<void> _editPhoto(PickedMedia media) async {
    final result = await ImageEditorScreen.show(
      context,
      bytes: media.originalBytes,
      initial: media.edit,
    );
    if (result == null) return;
    ref.read(composerProvider.notifier).applyEdit(0, result.edit, result.image);
  }

  Future<void> _editCaption() async {
    final composer = ref.read(composerProvider.notifier);
    final text = await showDialog<String>(
      context: context,
      builder: (_) =>
          _CaptionDialog(initial: ref.read(composerProvider).caption),
    );
    if (text != null) composer.setCaption(text);
  }

  /// Leaving with a picture chosen asks first, like Instagram.
  Future<void> _confirmLeave() async {
    if (ref.read(composerProvider).isPublishing) return;
    final l10n = context.l10n;
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.storyDiscardTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.storyDiscard),
          ),
        ],
      ),
    );
    if (leave != true || !mounted) return;
    setState(() => _leaving = true);
    ref.read(composerProvider.notifier).startStory();
    Navigator.pop(context);
  }

  Future<void> _share() async {
    final ok = await ref.read(composerProvider.notifier).publish();
    if (!ok || !mounted) return;
    final notice = ref.read(composerProvider).notice;
    final messenger = ScaffoldMessenger.of(context);
    final shared = context.l10n.storyShared;
    setState(() => _leaving = true);
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(content: Text(notice ?? shared)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(composerProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      // The keyboard must not squeeze the picture; the writer deals with it.
      resizeToAvoidBottomInset: false,
      body: _leaving
          ? const SizedBox.expand()
          : state.media.isEmpty
          ? _empty()
          : _editor(state),
    );
  }

  // ── nothing chosen yet ──────────────────────────────────────────────

  Widget _empty() {
    final l10n = context.l10n;
    final composer = ref.read(composerProvider.notifier);
    return SafeArea(
      child: Stack(
        children: [
          const Positioned(
            left: 4,
            top: 4,
            child: CloseButton(color: Colors.white),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 64, 32, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_stories_outlined,
                    color: Colors.white70,
                    size: 56,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.storyPickPrompt,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _source(
                        Icons.photo_library_outlined,
                        l10n.fromGallery,
                        composer.pickImages,
                      ),
                      _source(
                        Icons.videocam_outlined,
                        l10n.addVideo,
                        composer.pickVideo,
                      ),
                      _source(
                        Icons.photo_camera_outlined,
                        l10n.camera,
                        composer.capturePhoto,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _source(IconData icon, String label, Future<void> Function() pick) =>
      OutlinedButton.icon(
        onPressed: () => _pick(pick),
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white54),
        ),
      );

  // ── the picture and its tools ───────────────────────────────────────

  Widget _editor(ComposerState state) {
    final media = state.media.first;
    if (!identical(_backdropFor, media)) _loadBackdrop(media);
    final backdrop = _backdrop;
    if (!identical(_backdropFor, media) || backdrop == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return StoryCanvasEditor(
      key: _canvas,
      imageBytes: backdrop.bytes,
      mediaAspect: backdrop.aspect,
      initial: state.overlays,
      onChanged: ref.read(composerProvider.notifier).setOverlays,
      // Leaving throws the story away: ask first.
      canLeave: false,
      onLeaveBlocked: _confirmLeave,
      top: _topBar(state, media),
      bottom: _bottomBar(state),
    );
  }

  Widget _topBar(ComposerState state, PickedMedia media) {
    final l10n = context.l10n;
    final busy = state.isPublishing;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            tooltip: l10n.close,
            color: Colors.white,
            icon: const Icon(Icons.close),
            onPressed: busy ? null : _confirmLeave,
          ),
          const Spacer(),
          if (!media.isVideo)
            IconButton(
              tooltip: l10n.storyEditPhoto,
              color: Colors.white,
              icon: const Icon(Icons.crop_rotate),
              onPressed: busy ? null : () => _editPhoto(media),
            ),
          IconButton(
            tooltip: l10n.storyCaption,
            color: Colors.white,
            isSelected: state.caption.isNotEmpty,
            selectedIcon: const Icon(Icons.notes),
            icon: const Icon(Icons.notes_outlined),
            onPressed: busy ? null : _editCaption,
          ),
          IconButton(
            tooltip: l10n.storyAddText,
            color: Colors.white,
            icon: const Icon(Icons.text_fields),
            onPressed: busy ? null : () => _canvas.currentState?.addText(),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(ComposerState state) {
    final friends = ref.watch(closeFriendsProvider);
    final auth = ref.watch(authProvider);
    final closeOnly = state.audience == Audience.closeFriends;
    final canShare =
        state.canPublish &&
        !auth.isGuest &&
        (!closeOnly || friends.members.isNotEmpty);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.caption.isNotEmpty) _note(state.caption),
          if (closeOnly) _closeFriendsNote(auth.signer.canEncrypt, friends),
          if (state.error != null) _note(state.error!, color: Colors.redAccent),
          if (state.isPublishing) _progress(state),
          // Chips on their own line: a long "share" used to squeeze them
          // down to the icon and overflow.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _audienceChip(
                Audience.public,
                Icons.public,
                context.l10n.audiencePublic,
                state,
              ),
              _audienceChip(
                Audience.closeFriends,
                Icons.star_outline,
                context.l10n.closeFriends,
                state,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _shareButton(state, canShare),
          ),
        ],
      ),
    );
  }

  /// In the brand rose: the navy of the theme is lost on a dark bar.
  /// The label scales down when a long translation is wider than the bar.
  Widget _shareButton(ComposerState state, bool canShare) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FilledButton(
          onPressed: canShare ? _share : null,
          style: FilledButton.styleFrom(
            maximumSize: Size(constraints.maxWidth, double.infinity),
            backgroundColor: MialunaColors.twilightRose,
            foregroundColor: MialunaColors.midnightNavy,
            disabledBackgroundColor: Colors.white24,
            disabledForegroundColor: Colors.white54,
          ),
          child: state.isPublishing ? _shareSpinner() : _shareLabel(),
        );
      },
    );
  }

  Widget _shareSpinner() {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }

  Widget _shareLabel() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(context.l10n.storyShare, maxLines: 1),
    );
  }

  Widget _note(String text, {Color color = Colors.white70}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: color, fontSize: 13),
    ),
  );

  Widget _closeFriendsNote(bool canEncrypt, CloseFriendsState friends) {
    final l10n = context.l10n;
    final text = !canEncrypt
        ? l10n.signerCannotPublishCloseFriends
        : friends.members.isEmpty
        ? l10n.closeFriendsEmptyPrompt
        : l10n.onlyYourCloseFriendsSee(friends.members.length);
    return Row(
      children: [
        Expanded(child: _note(text)),
        TextButton(
          onPressed: () => CloseFriendsScreen.open(context),
          child: Text(
            friends.members.isEmpty ? l10n.addFriends : l10n.manageList,
          ),
        ),
      ],
    );
  }

  Widget _progress(ComposerState state) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: state.uploadProgress),
        if (state.stage != null) _note(state.stage!),
      ],
    ),
  );

  Widget _audienceChip(
    Audience audience,
    IconData icon,
    String label,
    ComposerState state,
  ) {
    final selected = state.audience == audience;
    return StoryPill(
      icon: icon,
      label: Text(label),
      selected: selected,
      onTap: state.isPublishing
          ? null
          : () => ref.read(composerProvider.notifier).setAudience(audience),
    );
  }
}

/// Asks for the words that go with the story. Owns its text controller, so
/// it is disposed only once the dialog is really gone.
class _CaptionDialog extends StatefulWidget {
  final String initial;
  const _CaptionDialog({required this.initial});

  @override
  State<_CaptionDialog> createState() => _CaptionDialogState();
}

class _CaptionDialogState extends State<_CaptionDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.storyCaption),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 4,
        maxLength: 2200,
        enableIMEPersonalizedLearning: false,
        decoration: InputDecoration(
          hintText: l10n.writeCaption,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
