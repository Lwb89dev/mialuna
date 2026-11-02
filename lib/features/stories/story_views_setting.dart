import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/strings.dart';
import 'story_views.dart';

/// Settings: whether watching a story tells its author.
class StoryViewsSetting extends ConsumerWidget {
  const StoryViewsSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    secondary: const Icon(Icons.visibility_outlined),
    title: Text(context.l10n.storyViewsSetting),
    subtitle: Text(context.l10n.storyViewsSettingExplain),
    value: ref.watch(storyViewReceiptsProvider),
    onChanged: ref.read(storyViewReceiptsProvider.notifier).set,
  );
}
