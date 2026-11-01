import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/strings.dart';
import '../profile/profile_widgets.dart';
import '../search/people_search.dart';

/// Pick several people by name (the follow list is searchable offline, other
/// people through the search relays). Returns the chosen pubkeys.
class PeoplePickerSheet extends ConsumerStatefulWidget {
  final Set<String> exclude;
  final String? title;
  final String? confirmLabel;
  final int? limit;

  const PeoplePickerSheet({
    super.key,
    this.exclude = const {},
    this.title,
    this.confirmLabel,
    this.limit,
  });

  static Future<List<String>?> show(
    BuildContext context, {
    Set<String> exclude = const {},
    String? title,
    String? confirmLabel,
    int? limit,
  }) => showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => PeoplePickerSheet(
      exclude: exclude,
      title: title,
      confirmLabel: confirmLabel,
      limit: limit,
    ),
  );

  @override
  ConsumerState<PeoplePickerSheet> createState() => _PeoplePickerSheetState();
}

class _PeoplePickerSheetState extends ConsumerState<PeoplePickerSheet> {
  final _search = TextEditingController();
  final Set<String> _selected = {};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final search = ref.watch(peopleSearchProvider);
    final shown = [
      for (final pk in search.results)
        if (!widget.exclude.contains(pk)) pk,
    ];
    final atLimit = widget.limit != null && _selected.length >= widget.limit!;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.78,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  (widget.title ?? context.l10n.addPeople),
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                controller: _search,
                onChanged: ref.read(peopleSearchProvider.notifier).setQuery,
                decoration: InputDecoration(
                  hintText: context.l10n.searchByNameOrUsername,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (search.searching) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: shown.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          search.searching
                              ? context.l10n.searching
                              : context.l10n.noOneWithThisName,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: shown.length,
                      itemBuilder: (context, i) {
                        final pk = shown[i];
                        final checked = _selected.contains(pk);
                        return CheckboxListTile(
                          value: checked,
                          onChanged: !checked && atLimit
                              ? null
                              : (v) => setState(() {
                                  v == true
                                      ? _selected.add(pk)
                                      : _selected.remove(pk);
                                }),
                          secondary: ProfileAvatar(
                            pubkey: pk,
                            radius: 20,
                            tappable: false,
                          ),
                          title: AuthorName(pubkey: pk, tappable: false),
                          subtitle: ProfileHandle(
                            pubkey: pk,
                            style: theme.textTheme.bodySmall,
                          ),
                          controlAffinity: ListTileControlAffinity.trailing,
                        );
                      },
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selected.isEmpty
                      ? null
                      : () => Navigator.of(context).pop(_selected.toList()),
                  child: Text(
                    _selected.isEmpty
                        ? (widget.confirmLabel ?? context.l10n.add)
                        : '${(widget.confirmLabel ?? context.l10n.add)} (${_selected.length})',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
