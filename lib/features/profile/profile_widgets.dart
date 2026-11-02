import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/profile_repository.dart';
import 'profile_screen.dart';

/// Opens the profile of [pubkey] on top of the current screen.
void openProfile(BuildContext context, String pubkey) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => ProfileScreen(pubkey: pubkey)));
}

/// Deterministic accent for the placeholder avatar of a pubkey.
Color _colorFor(String pubkey) {
  final hue = (int.tryParse(pubkey.substring(0, 6), radix: 16) ?? 0) % 360;
  return HSLColor.fromAHSL(1, hue.toDouble(), 0.38, 0.45).toColor();
}

/// Round avatar: the profile picture when known, initials otherwise.
class ProfileAvatar extends ConsumerWidget {
  final String pubkey;
  final double radius;
  final VoidCallback? onTap;
  final bool tappable;

  const ProfileAvatar({
    super.key,
    required this.pubkey,
    this.radius = 20,
    this.onTap,
    this.tappable = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = ref.watch(profileProvider(pubkey));
    final picture = meta?.picture;
    // Initials of the name, or of the key when there is none (never of the
    // "npub1…" that stands in for a missing name).
    final initials = (meta?.givenName ?? pubkey).replaceAll('…', '');
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: _colorFor(pubkey),
      foregroundColor: Colors.white,
      backgroundImage: picture == null
          ? null
          : CachedNetworkImageProvider(picture, maxWidth: (radius * 6).round()),
      onBackgroundImageError: picture == null ? null : (_, _) {},
      child: picture == null
          ? Text(
              initials.substring(0, initials.length >= 2 ? 2 : 1).toUpperCase(),
              style: TextStyle(
                fontSize: radius * 0.7,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
    );
    if (!tappable && onTap == null) return avatar;
    return GestureDetector(
      onTap: onTap ?? () => _open(context, ref),
      child: avatar,
    );
  }

  void _open(BuildContext context, WidgetRef ref) {
    openProfile(context, pubkey);
  }
}

/// Display name of [pubkey], falling back to a short key while loading.
class AuthorName extends ConsumerWidget {
  final String pubkey;
  final TextStyle? style;
  final int maxLines;
  final bool tappable;

  const AuthorName({
    super.key,
    required this.pubkey,
    this.style,
    this.maxLines = 1,
    this.tappable = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = ref.watch(profileProvider(pubkey));
    final text = Text(
      meta?.label ?? ProfileMetadata.shortNpub(pubkey),
      style: style,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
    if (!tappable) return text;
    return GestureDetector(
      onTap: () => openProfile(context, pubkey),
      child: text,
    );
  }
}

/// True when [pubkey] is the signed-in account.
bool isMe(WidgetRef ref, String pubkey) =>
    ref.read(authProvider).publicKey == pubkey;

/// Secondary line of a person: NIP-05 address or @username (empty while the
/// profile is still loading).
class ProfileHandle extends ConsumerWidget {
  final String pubkey;
  final TextStyle? style;
  const ProfileHandle({super.key, required this.pubkey, this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = ref.watch(profileProvider(pubkey));
    final text = meta?.nip05 ?? meta?.handle;
    if (text == null) return const SizedBox.shrink();
    return Text(
      text,
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
