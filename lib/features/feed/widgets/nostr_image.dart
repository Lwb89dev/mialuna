import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/nostr/models/media_event.dart';
import '../../../l10n/strings.dart';
import '../../settings/settings_controller.dart';

/// Whether a loading error will never go away by retrying the same URL
/// (HTTP 4xx, undecodable data) as opposed to a network hiccup.
bool isPermanentImageError(Object error) {
  final text = error.toString();
  final status = RegExp(r'statusCode:\s*(\d{3})').firstMatch(text);
  if (status != null) {
    final code = int.parse(status.group(1)!);
    return code >= 400 && code < 500 && code != 408 && code != 429;
  }
  return text.contains('Invalid image data') ||
      text.contains('Codec failed') ||
      text.contains('Failed to decode') ||
      text.contains('Could not instantiate image codec');
}

/// Candidate URLs for [item], best first: https upgrades of plain http
/// links (cleartext traffic is blocked by the OS), the thumbnail when asked
/// for, the original and any `fallback` mirrors the publisher listed.
List<String> imageCandidates(MediaItem item, {bool preferThumbnail = false}) {
  final raw = <String>[
    if (preferThumbnail && item.previewUrl != null) item.previewUrl!,
    item.url,
    if (!preferThumbnail && item.previewUrl != null && item.isVideo)
      item.previewUrl!,
    ...item.fallbackUrls,
  ];
  final out = <String>[];
  for (final u in raw) {
    if (u.startsWith('http://')) {
      final https = 'https://${u.substring(7)}';
      if (!out.contains(https)) out.add(https);
    }
    if (!out.contains(u)) out.add(u);
  }
  return out;
}

/// A network image that survives the real Nostr world: it falls back to
/// mirrors, tells permanent failures from flaky networks, decodes at the
/// size it is shown (huge originals no longer exhaust memory), and reports a
/// permanently dead post so the feed can hide it.
class NostrImage extends ConsumerStatefulWidget {
  final MediaItem item;

  /// Event the image belongs to; lets the feed hide posts whose media is
  /// permanently unreachable.
  final String? postId;
  final BoxFit fit;
  final bool preferThumbnail;
  final ValueChanged<Size>? onSize;

  /// Called once nothing is left to try: every mirror failed.
  final VoidCallback? onFailed;
  final String? semanticLabel;

  const NostrImage({
    super.key,
    required this.item,
    this.postId,
    this.fit = BoxFit.cover,
    this.preferThumbnail = false,
    this.onSize,
    this.onFailed,
    this.semanticLabel,
  });

  @override
  ConsumerState<NostrImage> createState() => _NostrImageState();
}

class _NostrImageState extends ConsumerState<NostrImage> {
  late List<String> _urls;
  int _index = 0;
  int _attempt = 0;
  bool _failed = false;
  bool _allPermanent = true;
  bool _sizeReported = false;

  /// A frame of the current picture has been painted at least once. From then
  /// on the widget never goes back to the placeholder: if Flutter's image
  /// cache dropped the decoded picture and it is read again from disk, the
  /// old pixels stay on screen until the new ones are ready.
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    _urls = _buildUrls();
  }

  @override
  void didUpdateWidget(NostrImage old) {
    super.didUpdateWidget(old);
    if (old.item.url != widget.item.url ||
        old.preferThumbnail != widget.preferThumbnail) {
      _urls = _buildUrls();
      _index = 0;
      _failed = false;
      _allPermanent = true;
      _sizeReported = false;
      _shown = false;
    }
  }

  List<String> _buildUrls() => imageCandidates(
    widget.item,
    preferThumbnail:
        widget.preferThumbnail || ref.read(settingsProvider).dataSaver,
  );

  void _onError(Object error) {
    if (!isPermanentImageError(error)) _allPermanent = false;
    // Never mutate state while building: move on after this frame. The error
    // builder can run more than once before that, so only the URL that
    // failed moves on (not every call).
    final failedIndex = _index;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _failed || _index != failedIndex) return;
      if (_index < _urls.length - 1) {
        setState(() => _index++);
        return;
      }
      setState(() => _failed = true);
      widget.onFailed?.call();
      final id = widget.postId;
      if (id != null && _allPermanent) {
        final broken = ref.read(brokenMediaProvider);
        if (!broken.contains(id)) {
          ref.read(brokenMediaProvider.notifier).state = {...broken, id};
        }
      }
    });
  }

  void _reportSize(ImageProvider provider) {
    if (_sizeReported || widget.onSize == null) return;
    _sizeReported = true;
    final stream = provider.resolve(ImageConfiguration.empty);
    late ImageStreamListener listener;
    listener = ImageStreamListener((info, _) {
      widget.onSize?.call(
        Size(info.image.width.toDouble(), info.image.height.toDouble()),
      );
      stream.removeListener(listener);
    }, onError: (_, _) => stream.removeListener(listener));
    stream.addListener(listener);
  }

  void _retry() => setState(() {
    _index = 0;
    _attempt++;
    _failed = false;
    _allPermanent = true;
    _shown = false;
  });

  /// Placeholder until the first frame, then a short fade-in. Once a picture
  /// has been shown the same widget keeps being returned (see [_shown]), so a
  /// reload never flashes back to the placeholder or fades again.
  Widget _frame(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
    ImageProvider provider,
  ) {
    if (frame == null && !_shown) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      );
    }
    if (frame != null) _reportSize(provider);
    final animate = !_shown && !wasSynchronouslyLoaded;
    _shown = true;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: animate ? 0.0 : 1.0, end: 1.0),
      duration: const Duration(milliseconds: 150),
      builder: (_, opacity, child) => Opacity(opacity: opacity, child: child),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final item = widget.item;
    // Close-friends media is ciphertext on the server: fetch and decrypt.
    if (item.isEncrypted ||
        (widget.preferThumbnail &&
            item.previewUrl != null &&
            item.previewEncryption != null)) {
      return EncryptedImage(
        key: ValueKey('enc-${item.url}-${widget.preferThumbnail}'),
        item: item,
        preview:
            item.previewEncryption != null &&
            (widget.preferThumbnail || item.isVideo),
        fit: widget.fit,
        onSize: widget.onSize,
        onFailed: widget.onFailed,
        semanticLabel: widget.semanticLabel,
      );
    }
    if (_failed) {
      return _ImageUnavailable(onRetry: _retry);
    }
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final cacheWidth = (width * dpr).clamp(240, 1600).round();
        // The Image is built here, from a provider resized to the size it is
        // shown at: `CachedNetworkImage` hands its `imageBuilder` the
        // *unresized* provider, so a 12-megapixel original was decoded in
        // full (≈48 MB) for every 130 px grid cell, overflowed Flutter's
        // 100 MB image cache after a couple of pictures, and the evicted
        // thumbnails all reloaded (placeholder, fade) when a screen was
        // uncovered.
        final provider = ResizeImage.resizeIfNeeded(
          cacheWidth,
          null,
          CachedNetworkImageProvider(_urls[_index]),
        );
        final image = Image(
          key: ValueKey('$_attempt-$_index-${_urls[_index]}'),
          image: provider,
          fit: widget.fit,
          gaplessPlayback: true,
          frameBuilder: (context, child, frame, sync) =>
              _frame(context, child, frame, sync, provider),
          errorBuilder: (context, error, _) {
            _onError(error);
            return ColoredBox(color: colors.surfaceContainerHighest);
          },
        );
        final label = widget.semanticLabel ?? widget.item.alt;
        return Semantics(
          image: true,
          label: label ?? context.l10n.postImage,
          child: image,
        );
      },
    );
  }
}

class _ImageUnavailable extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;
  const _ImageUnavailable({required this.onRetry, this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onRetry,
      child: ColoredBox(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.broken_image_outlined,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.errorTapToRetryNewline(
                  message ?? context.l10n.imageUnavailable,
                ),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A close-friends picture: downloaded as ciphertext, decrypted on the device
/// and shown from memory (never written to disk).
class EncryptedImage extends ConsumerStatefulWidget {
  final MediaItem item;

  /// Show the (encrypted) cover instead of the file itself.
  final bool preview;
  final BoxFit fit;
  final ValueChanged<Size>? onSize;

  /// Called when the picture cannot be fetched, decrypted or decoded.
  final VoidCallback? onFailed;
  final String? semanticLabel;

  const EncryptedImage({
    super.key,
    required this.item,
    this.preview = false,
    this.fit = BoxFit.cover,
    this.onSize,
    this.onFailed,
    this.semanticLabel,
  });

  @override
  ConsumerState<EncryptedImage> createState() => _EncryptedImageState();
}

class _EncryptedImageState extends ConsumerState<EncryptedImage> {
  late Future<Uint8List> _bytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _bytes = ref
        .read(privateMediaProvider)
        .imageBytes(widget.item, preview: widget.preview);
    _bytes.then(
      (b) async {
        final onSize = widget.onSize;
        if (onSize == null && widget.onFailed == null) return;
        try {
          final image = await decodeImageFromList(b);
          final size = Size(image.width.toDouble(), image.height.toDouble());
          image.dispose();
          if (mounted) onSize?.call(size);
        } catch (_) {
          if (mounted) widget.onFailed?.call();
        }
      },
      onError: (_) {
        if (mounted) widget.onFailed?.call();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FutureBuilder<Uint8List>(
      future: _bytes,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ImageUnavailable(
            onRetry: () => setState(_load),
            message: context.l10n.cannotOpenPrivateContent,
          );
        }
        final bytes = snapshot.data;
        if (bytes == null) {
          return ColoredBox(
            color: colors.surfaceContainerHighest,
            child: Center(
              child: Icon(Icons.lock_outline, color: colors.outline, size: 28),
            ),
          );
        }
        return Semantics(
          image: true,
          label:
              widget.semanticLabel ??
              widget.item.alt ??
              context.l10n.privateImage,
          child: Image.memory(
            bytes,
            fit: widget.fit,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => _ImageUnavailable(
              onRetry: () => setState(_load),
              message: context.l10n.invalidImage,
            ),
          ),
        );
      },
    );
  }
}
