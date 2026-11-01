import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/profile_repository.dart';
import '../../l10n/strings.dart';

/// Edit kind 0 profile metadata: name, bio, avatar URL, NIP-05.
class EditProfileScreen extends ConsumerStatefulWidget {
  final ProfileMetadata? current;
  const EditProfileScreen({super.key, this.current});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _about;
  late final TextEditingController _picture;
  late final TextEditingController _nip05;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.current;
    _name = TextEditingController(text: c?.displayName ?? c?.name ?? '');
    _about = TextEditingController(text: c?.about ?? '');
    _picture = TextEditingController(text: c?.picture ?? '');
    _nip05 = TextEditingController(text: c?.nip05 ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _about.dispose();
    _picture.dispose();
    _nip05.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final signer = ref.read(authProvider).signer;
    if (!signer.canSign || _saving) return;
    setState(() => _saving = true);
    try {
      // Fields this form does not edit (lightning address, banner, website…)
      // are kept as they are.
      final content = jsonEncode({
        ...?widget.current?.toJson(),
        'name': _name.text.trim(),
        'display_name': _name.text.trim(),
        'about': _about.text.trim(),
        if (_picture.text.trim().isNotEmpty) 'picture': _picture.text.trim(),
        if (_nip05.text.trim().isNotEmpty) 'nip05': _nip05.text.trim(),
      });
      final event = await signer.signEvent(
        kind: NostrKinds.profileMetadata,
        tags: const [],
        content: content,
      );
      final report = await ref
          .read(relayPoolProvider)
          .publish(event, extraRelays: ref.read(indexerRelaysProvider));
      if (mounted) {
        setState(() => _saving = false);
        if (report.publishedSomewhere) {
          ref.read(profilesProvider.notifier).applyLocal(event);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.l10n.profileUpdated)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.noRelayAcceptedRetry)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.editProfile),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(context.l10n.save),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: context.l10n.fieldName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _about,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: context.l10n.fieldBio,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _picture,
            decoration: InputDecoration(
              labelText: context.l10n.fieldAvatarUrl,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nip05,
            decoration: InputDecoration(
              labelText: context.l10n.fieldNip05,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
