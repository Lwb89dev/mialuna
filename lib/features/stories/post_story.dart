import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;

import '../../app/providers.dart';
import '../../core/media/video_frames.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/models/story_link.dart';
import '../../core/nostr/profile_repository.dart';
import '../../core/text/clip.dart';
import '../../core/theme/mialuna_theme.dart';
import '../feed/widgets/nostr_image.dart' show imageCandidates;

/// The picture of a story that shows a post, and where the post is on it.
typedef PostCardImage = ({Uint8List bytes, StoryArea area});

/// Loads one picture from the network, or null. Replaceable: tests have none.
final postImageLoaderProvider =
    Provider<Future<ui.Image?> Function(String url)>((ref) => _loadImage);

/// Draws the story picture of a post: its first photo (or a still of its
/// video) on a card with its author and caption.
final postCardRendererProvider =
    Provider<Future<PostCardImage> Function(MediaPost post)>((ref) {
      return (post) async {
        final load = ref.read(postImageLoaderProvider);
        final profile = await _profileOf(ref, post.author);
        final item = post.media.first;
        // A post behind a content warning stays behind it: nothing of its
        // picture or words goes on the card.
        final hidden = post.isSensitive;
        final media = hidden ? null : await _still(item, load);
        if (media == null && !hidden && !item.isVideo) {
          throw StateError('the picture of the post cannot be loaded');
        }
        final picture = profile?.picture;
        final avatar = picture == null
            ? null
            : await load(picture)
                  .timeout(const Duration(seconds: 6), onTimeout: () => null);
        try {
          return await drawPostCard(
            name: profile?.label ?? ProfileMetadata.shortNpub(post.author),
            caption: hidden ? '' : post.caption,
            media: media,
            avatar: avatar,
            aspect: item.aspectRatio,
            video: item.isVideo,
            hidden: hidden,
          );
        } finally {
          media?.dispose();
          avatar?.dispose();
        }
      };
    });

Future<ProfileMetadata?> _profileOf(Ref ref, String pubkey) async {
  final known = ref.read(profileProvider(pubkey));
  if (known != null) return known;
  try {
    return await ref
        .read(profileMetadataProvider(pubkey).future)
        .timeout(const Duration(seconds: 4));
  } catch (_) {
    return null; // the card then names the key
  }
}

Future<ui.Image?> _still(
  MediaItem item,
  Future<ui.Image?> Function(String url) load,
) async {
  if (!item.isVideo) {
    for (final url in imageCandidates(item)) {
      final image = await load(url);
      if (image != null) return image;
    }
    return null;
  }
  final preview = item.previewUrl;
  if (preview != null) {
    final image = await load(preview);
    if (image != null) return image;
  }
  final frame = await VideoFrames.extract(item.url);
  if (frame == null) return null;
  try {
    return await decodeImageFromList(frame.bytes);
  } catch (_) {
    return null;
  }
}

Future<ui.Image?> _loadImage(String url) {
  final done = Completer<ui.Image?>();
  final stream = ResizeImage(
    CachedNetworkImageProvider(url),
    width: _cardWidth.toInt(),
  ).resolve(ImageConfiguration.empty);
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (info, _) {
      if (!done.isCompleted) done.complete(info.image.clone());
      info.dispose();
    },
    onError: (_, _) {
      if (!done.isCompleted) done.complete(null);
    },
  );
  stream.addListener(listener);
  return done.future
      .timeout(const Duration(seconds: 15), onTimeout: () => null)
      .whenComplete(() => stream.removeListener(listener));
}

const _width = 1080.0;
const _height = 1920.0;
const _cardWidth = 820.0;
const _header = 136.0;
const _padding = 32.0;

TextPainter _text(
  String text, {
  required double size,
  required double maxWidth,
  Color color = MialunaColors.darkCharcoal,
  FontWeight weight = FontWeight.w400,
  int maxLines = 1,
  String? family,
}) => TextPainter(
  text: TextSpan(
    text: text,
    style: TextStyle(
      fontSize: size,
      color: color,
      fontWeight: weight,
      fontFamily: family,
      height: family == null ? 1.25 : 1,
    ),
  ),
  textDirection: TextDirection.ltr,
  maxLines: maxLines,
  ellipsis: '…',
)..layout(maxWidth: maxWidth);

void _icon(Canvas canvas, IconData icon, Offset centre, double size) {
  final glyph = _text(
    String.fromCharCode(icon.codePoint),
    size: size,
    maxWidth: size * 2,
    color: Colors.white,
    family: icon.fontFamily,
  );
  glyph.paint(canvas, centre - Offset(glyph.width / 2, glyph.height / 2));
  glyph.dispose();
}

/// [image] covering [into], cropped around its centre.
void _cover(Canvas canvas, ui.Image image, Rect into) {
  final size = Size(image.width.toDouble(), image.height.toDouble());
  final fitted = applyBoxFit(BoxFit.cover, size, into.size);
  canvas.drawImageRect(
    image,
    Alignment.center.inscribe(fitted.source, Offset.zero & size),
    into,
    Paint()..filterQuality = FilterQuality.medium,
  );
}

/// Draws a 1080×1920 story picture with the post on a card in its middle, and
/// says where on it the card is.
Future<PostCardImage> drawPostCard({
  required String name,
  required String caption,
  ui.Image? media,
  ui.Image? avatar,
  double? aspect,
  bool video = false,
  bool hidden = false,
}) async {
  final shape = (aspect ?? (media == null ? 1.0 : media.width / media.height))
      .clamp(0.8, 1.91);
  final mediaHeight = (_cardWidth / shape).roundToDouble();
  final words = clipForDisplay(caption).trim();
  final text = words.isEmpty
      ? null
      : _text(
          words,
          size: 34,
          maxWidth: _cardWidth - 2 * _padding,
          maxLines: 3,
        );
  final footer = text == null ? _padding : text.height + 2 * _padding;
  final card = Rect.fromLTWH(
    (_width - _cardWidth) / 2,
    ((_height - _header - mediaHeight - footer) / 2).roundToDouble(),
    _cardWidth,
    _header + mediaHeight + footer,
  );

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, _width, _height));
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, _width, _height),
    Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        const Offset(0, _height),
        const [MialunaColors.midnightNavy, Color(0xFF6A5478)],
      ),
  );
  final shapeOfCard = RRect.fromRectAndRadius(card, const Radius.circular(36));
  canvas.drawShadow(Path()..addRRect(shapeOfCard), Colors.black, 18, false);
  canvas.drawRRect(shapeOfCard, Paint()..color = MialunaColors.warmOffWhite);

  // Header: who published it.
  final face = Rect.fromCircle(
    center: Offset(card.left + _padding + 40, card.top + _header / 2),
    radius: 40,
  );
  if (avatar == null) {
    canvas.drawOval(face, Paint()..color = MialunaColors.mutedLavender);
    _icon(canvas, Icons.person, face.center, 48);
  } else {
    canvas
      ..save()
      ..clipPath(Path()..addOval(face));
    _cover(canvas, avatar, face);
    canvas.restore();
  }
  final who = _text(
    name,
    size: 38,
    weight: FontWeight.w600,
    maxWidth: card.right - face.right - 24 - _padding,
  );
  who.paint(canvas, Offset(face.right + 24, face.center.dy - who.height / 2));
  who.dispose();

  // The photo, or what stands in for it.
  final area = Rect.fromLTWH(
    card.left,
    card.top + _header,
    _cardWidth,
    mediaHeight,
  );
  if (media == null) {
    canvas.drawRect(area, Paint()..color = MialunaColors.darkCharcoal);
  } else {
    _cover(canvas, media, area);
  }
  final mark = hidden
      ? Icons.visibility_off_outlined
      : video
      ? Icons.play_circle_fill
      : null;
  if (mark != null) {
    _icon(canvas, mark, area.center, math.min(150, mediaHeight / 3));
  }

  if (text != null) {
    text.paint(canvas, Offset(card.left + _padding, area.bottom + _padding));
    text.dispose();
  }

  final picture = recorder.endRecording();
  final image = await picture.toImage(_width.toInt(), _height.toInt());
  picture.dispose();
  final raw = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  image.dispose();
  if (raw == null) throw StateError('the card cannot be drawn');
  final pixels = raw.buffer.asUint8List();
  final jpeg = await Isolate.run(() => _encode(pixels));
  return (
    bytes: jpeg,
    area: StoryArea(
      left: card.left / _width,
      top: card.top / _height,
      width: card.width / _width,
      height: card.height / _height,
    ),
  );
}

Uint8List _encode(Uint8List rgba) => img.encodeJpg(
  img.Image.fromBytes(
    width: _width.toInt(),
    height: _height.toInt(),
    bytes: rgba.buffer,
    numChannels: 4,
  ),
  quality: 92,
);
