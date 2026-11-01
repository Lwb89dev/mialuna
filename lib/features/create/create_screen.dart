import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import 'create_controller.dart';

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

  Future<void> _publish() async {
    final ok = await ref.read(composerProvider.notifier).publish();
    if (!mounted) return;
    if (ok) {
      _captionController.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Momento pubblicato ✨')));
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(composerProvider);
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);

    if (_captionController.text != state.caption &&
        !state.isPublishing &&
        _captionController.text.isEmpty) {
      _captionController.text = state.caption;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuovo momento'),
        actions: [
          TextButton(
            onPressed: state.canPublish && !auth.isGuest ? _publish : null,
            child: state.isPublishing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Pubblica'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (auth.isGuest)
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Modalità ospite'),
                subtitle: const Text('Accedi per pubblicare i tuoi momenti.'),
                trailing: TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Accedi'),
                ),
              ),
            ),
          GestureDetector(
            onTap: () => ref.read(composerProvider.notifier).pickImages(),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    const Text('Aggiungi foto'),
                  ],
                ),
              ),
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
                    key: ValueKey(m.file.path + i.toString()),
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            m.bytes,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
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
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _captionController,
            maxLines: 4,
            maxLength: 2200,
            decoration: const InputDecoration(
              hintText: 'Scrivi una didascalia…',
              border: OutlineInputBorder(),
            ),
            onChanged: ref.read(composerProvider.notifier).setCaption,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.tag, size: 16, color: theme.colorScheme.secondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Verrà pubblicato come: "${state.finalCaption}"',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (state.isPublishing) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(value: state.uploadProgress),
            const SizedBox(height: 8),
            Text(
              'Caricamento media…',
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
