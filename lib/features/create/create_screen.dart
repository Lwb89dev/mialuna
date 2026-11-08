import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../l10n/strings.dart';
import '../stories/story_text_editor.dart';
import '../private/close_friends.dart';
import '../private/close_friends_screen.dart';
import '../settings/settings_controller.dart';
import 'create_controller.dart';
import 'editor/image_editor_screen.dart';

class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key});

  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen> {
  late final TextEditingController _captionController;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _editPhoto(int index) async {
    final media = ref.read(composerProvider).media[index];
    final edited = await ImageEditorScreen.show(
      context,
      bytes: media.bytes,
      mimeType: media.mimeType,
    );
    if (edited != null) {
      ref.read(composerProvider.notifier).replaceMediaBytes(index, edited);
    }
  }

  Future<void> _editAlt(int index) async {
    final media = ref.read(composerProvider).media[index];
    final controller = TextEditingController(text: media.alt);
    final saved = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.altText),
        content: TextField(
          controller: controller,
          maxLines: 3,
          autofocus: true,
          decoration: InputDecoration(
            hintText: context.l10n.altTextHint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
    if (saved != null) {
      ref.read(composerProvider.notifier).setAlt(index, saved);
    }
  }

  Future<void> _editStoryTexts() async {
    final composer = ref.read(composerProvider.notifier);
    final backdrop = await composer.storyBackdrop();
    if (!mounted) return;
    final texts = await StoryTextEditorScreen.show(
      context,
      imageBytes: backdrop.bytes,
      mediaAspect: backdrop.aspect,
      initial: ref.read(composerProvider).overlays,
    );
    if (texts != null) composer.setOverlays(texts);
  }

  Widget _barTitle(String text) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: Text(text, maxLines: 1),
    );
  }

  Widget _publishAction(
    ComposerState state,
    bool guest,
    CloseFriendsState friends,
  ) {
    final enabled =
        state.canPublish &&
        !guest &&
        (state.audience == Audience.public || friends.members.isNotEmpty);
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: TextButton(
          onPressed: enabled ? _publish : null,
          child: state.isPublishing
              ? _publishSpinner()
              : Text(context.l10n.publish),
        ),
      ),
    );
  }

  Widget _publishSpinner() {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }

  Future<void> _publish() async {
    final ok = await ref.read(composerProvider.notifier).publish();
    if (!mounted) return;
    if (ok) {
      final notice = ref.read(composerProvider).notice;
      _captionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(notice ?? context.l10n.momentPublished)),
      );
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(composerProvider);
    final auth = ref.watch(authProvider);
    final friends = ref.watch(closeFriendsProvider);
    final theme = Theme.of(context);

    // The composer is the truth: a caption changed elsewhere (a story shared
    // from the Home rail, a reset after publishing, the draft read late) shows
    // here, and so does an empty one. While somebody types, the state already
    // equals the field, so this never moves the cursor. (It only ever filled an
    // empty field: after a story shared elsewhere the box kept the old text
    // while the composer was empty, and the first keystroke put it back.)
    if (_captionController.text != state.caption && !state.isPublishing) {
      _captionController.value = TextEditingValue(
        text: state.caption,
        selection: TextSelection.collapsed(offset: state.caption.length),
      );
    }

    return Scaffold(
      appBar: AppBar(
        // Title and Publish share one row. A long translation at a large
        // text size used to overflow the action slot.
        titleSpacing: 16,
        title: Row(
          children: [
            Expanded(child: _barTitle(context.l10n.newMoment)),
            Flexible(
              flex: 2,
              child: _publishAction(state, auth.isGuest, friends),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (auth.isGuest)
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(context.l10n.guestMode),
                subtitle: Text(context.l10n.signInToPostMoments),
                trailing: TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(context.l10n.signIn),
                ),
              ),
            ),
          SegmentedButton<ComposerMode>(
            expandedInsets: EdgeInsets.zero,
            segments: [
              ButtonSegment(
                value: ComposerMode.photo,
                icon: const Icon(Icons.photo_outlined),
                label: _scaleLabel(context.l10n.kindPhoto),
              ),
              ButtonSegment(
                value: ComposerMode.video,
                icon: const Icon(Icons.videocam_outlined),
                label: _scaleLabel(context.l10n.kindVideo),
              ),
              ButtonSegment(
                value: ComposerMode.reel,
                icon: const Icon(Icons.play_circle_outline),
                label: _scaleLabel(context.l10n.kindReel),
              ),
              ButtonSegment(
                value: ComposerMode.story,
                icon: const Icon(Icons.auto_stories_outlined),
                label: _scaleLabel(context.l10n.kindStory),
              ),
            ],
            selected: {state.mode},
            onSelectionChanged: (sel) =>
                ref.read(composerProvider.notifier).setMode(sel.first),
          ),
          if (state.mode == ComposerMode.story) ...[
            const SizedBox(height: 8),
            Text(
              context.l10n.storyExpiryNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _AudienceSelector(
            audience: state.audience,
            friendCount: friends.members.length,
            onChanged: ref.read(composerProvider.notifier).setAudience,
            onManage: () => CloseFriendsScreen.open(context),
            canEncrypt: auth.signer.canEncrypt,
          ),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _PickerTile(
                    icon: switch (state.mode) {
                      ComposerMode.photo => Icons.add_photo_alternate_outlined,
                      ComposerMode.story => Icons.auto_stories_outlined,
                      _ => Icons.video_library_outlined,
                    },
                    label: switch (state.mode) {
                      ComposerMode.photo => context.l10n.fromGallery,
                      ComposerMode.story => context.l10n.galleryLongPressVideo,
                      _ => context.l10n.addVideo,
                    },
                    onTap: () => switch (state.mode) {
                      ComposerMode.photo || ComposerMode.story =>
                        ref.read(composerProvider.notifier).pickImages(),
                      _ => ref.read(composerProvider.notifier).pickVideo(),
                    },
                    onLongPress: state.mode == ComposerMode.story
                        ? () => ref.read(composerProvider.notifier).pickVideo()
                        : null,
                  ),
                ),
                if (state.mode != ComposerMode.video &&
                    state.mode != ComposerMode.reel) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 110,
                    child: _PickerTile(
                      icon: Icons.photo_camera_outlined,
                      label: context.l10n.camera,
                      onTap: () =>
                          ref.read(composerProvider.notifier).capturePhoto(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.exifRemovedNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          if (state.media.isNotEmpty)
            SizedBox(
              height: 110,
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.media.length,
                onReorderItem: ref.read(composerProvider.notifier).reorderMedia,
                itemBuilder: (context, i) {
                  final m = state.media[i];
                  return Padding(
                    key: ObjectKey(m),
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _editAlt(i),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: m.isVideo
                                ? Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.black,
                                    child: const Icon(
                                      Icons.play_circle_outline,
                                      color: Colors.white70,
                                      size: 40,
                                    ),
                                  )
                                : Image.memory(
                                    m.bytes,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          if (m.alt.isNotEmpty)
                            const Positioned(
                              bottom: 2,
                              left: 2,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.black54,
                                child: Text(
                                  'ALT',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          if (!m.isVideo)
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () => _editPhoto(i),
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.black54,
                                  child: Icon(
                                    Icons.crop,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () => ref
                                  .read(composerProvider.notifier)
                                  .removeMedia(i),
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.black54,
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          if (state.mode == ComposerMode.story && state.media.isNotEmpty) ...[
            const SizedBox(height: 12),
            _StoryTextButton(
              count: state.overlays.length,
              onPressed: state.isPublishing ? null : _editStoryTexts,
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _captionController,
            maxLines: 4,
            maxLength: 2200,
            decoration: InputDecoration(
              hintText: context.l10n.writeCaption,
              border: const OutlineInputBorder(),
            ),
            onChanged: ref.read(composerProvider.notifier).setCaption,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                state.audience == Audience.closeFriends
                    ? Icons.lock_outline
                    : Icons.tag,
                size: 16,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  state.audience == Audience.closeFriends
                      ? context.l10n.privatePostNote
                      : context.l10n.willPublishAs(
                          state.finalCaption(
                            addMialunaTag: ref
                                .watch(settingsProvider)
                                .addMialunaHashtag,
                          ),
                        ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (state.media.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              context.l10n.tapThumbnailForAlt,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.visibility_off_outlined),
            title: Text(context.l10n.sensitiveContent),
            subtitle: Text(context.l10n.sensitiveContentNote),
            value: state.sensitive,
            onChanged: ref.read(composerProvider.notifier).setSensitive,
          ),
          if (state.isPublishing) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(value: state.uploadProgress),
            const SizedBox(height: 8),
            Text(
              context.l10n.uploadingMedia,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
          if (state.error != null) ...[
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }
}

/// Opens the editor that lays texts over a story's picture.
class _StoryTextButton extends StatelessWidget {
  final int count;
  final VoidCallback? onPressed;
  const _StoryTextButton({required this.count, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.text_fields),
          label: Text(count == 0 ? l10n.storyAddText : l10n.storyEditText),
        ),
        if (count > 0)
          Text(
            l10n.storyTextsCount(count),
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}

/// Big tappable tile to pick media. Grows with the text instead of
/// overflowing a fixed height when the user enlarges the font.
class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _PickerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          constraints: const BoxConstraints(minHeight: 140),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

/// One line that shrinks instead of pushing the segment past the screen.
Widget _scaleLabel(String text) {
  return FittedBox(fit: BoxFit.scaleDown, child: Text(text, maxLines: 1));
}

/// Public or close friends — remembered, so the list does not have to be
/// picked for every post.
class _AudienceSelector extends StatelessWidget {
  final Audience audience;
  final int friendCount;
  final bool canEncrypt;
  final ValueChanged<Audience> onChanged;
  final VoidCallback onManage;

  const _AudienceSelector({
    required this.audience,
    required this.friendCount,
    required this.canEncrypt,
    required this.onChanged,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final closeFriends = audience == Audience.closeFriends;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<Audience>(
            expandedInsets: EdgeInsets.zero,
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: Audience.public,
                icon: const Icon(Icons.public),
                label: _scaleLabel(context.l10n.audiencePublic),
              ),
              ButtonSegment(
                value: Audience.closeFriends,
                icon: const Icon(Icons.star_outline),
                label: _scaleLabel(context.l10n.closeFriends),
              ),
            ],
            selected: {audience},
            onSelectionChanged: (s) => onChanged(s.first),
          ),
        ),
        if (closeFriends) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2EB872).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  !canEncrypt
                      ? context.l10n.signerCannotPublishCloseFriends
                      : friendCount == 0
                      ? context.l10n.closeFriendsEmptyPrompt
                      : context.l10n.onlyYourCloseFriendsSee(friendCount),
                  style: theme.textTheme.bodySmall,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onManage,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: Text(
                      friendCount == 0
                          ? context.l10n.addFriends
                          : context.l10n.manageList,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
