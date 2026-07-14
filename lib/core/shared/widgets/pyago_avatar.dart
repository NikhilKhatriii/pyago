import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../extensions/string_extensions.dart';

enum PyagoAvatarSize { xs, sm, md, lg, xl }

class PyagoAvatar extends StatelessWidget {
  const PyagoAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = PyagoAvatarSize.md,
    this.showOnlineDot = false,
  });

  final String name;
  final String? imageUrl;
  final PyagoAvatarSize size;
  final bool showOnlineDot;

  double get _diameter => switch (size) {
        PyagoAvatarSize.xs => 24,
        PyagoAvatarSize.sm => 32,
        PyagoAvatarSize.md => 44,
        PyagoAvatarSize.lg => 64,
        PyagoAvatarSize.xl => 96,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final d = _diameter;

    final avatar = ClipOval(
      child: SizedBox(
        width: d,
        height: d,
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _initials(scheme, d),
                placeholder: (_, __) => _initials(scheme, d),
              )
            : _initials(scheme, d),
      ),
    );

    if (!showOnlineDot) return Semantics(label: '$name avatar', child: avatar);

    return Semantics(
      label: '$name avatar, online',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: d * 0.28,
              height: d * 0.28,
              decoration: BoxDecoration(
                color: const Color(0xFF2FA76A),
                shape: BoxShape.circle,
                border: Border.all(color: scheme.surface, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initials(ColorScheme scheme, double d) {
    return Container(
      color: scheme.primary.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Text(
        name.initialsFrom(),
        style: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: d * 0.36,
        ),
      ),
    );
  }
}
