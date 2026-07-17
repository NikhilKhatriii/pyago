import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../extensions/string_extensions.dart';
import '../../theme/app_colors.dart';

enum PyagoAvatarSize { xs, sm, md, lg, xl }

/// Circular avatar with optional gradient border ring for premium/verified
/// authors. Supports network images with fallback to name initials.
class PyagoAvatar extends StatelessWidget {
  const PyagoAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = PyagoAvatarSize.md,
    this.showOnlineDot = false,
    this.showGradientRing = false,
  });

  final String name;
  final String? imageUrl;
  final PyagoAvatarSize size;
  final bool showOnlineDot;

  /// Shows a gradient border ring around the avatar (brand gradient).
  final bool showGradientRing;

  double get _diameter => switch (size) {
        PyagoAvatarSize.xs => 24,
        PyagoAvatarSize.sm => 32,
        PyagoAvatarSize.md => 44,
        PyagoAvatarSize.lg => 64,
        PyagoAvatarSize.xl => 96,
      };

  double get _ringWidth => switch (size) {
        PyagoAvatarSize.xs => 1.5,
        PyagoAvatarSize.sm => 2,
        PyagoAvatarSize.md => 2.5,
        PyagoAvatarSize.lg => 3,
        PyagoAvatarSize.xl => 3.5,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final d = _diameter;

    Widget avatar = ClipOval(
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

    // Wrap with gradient ring if enabled
    if (showGradientRing) {
      avatar = Container(
        padding: EdgeInsets.all(_ringWidth),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: AppColors.brandGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(_ringWidth * 0.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.surface,
          ),
          child: avatar,
        ),
      );
    }

    if (!showOnlineDot) return Semantics(label: '$name avatar', child: avatar);

    return Semantics(
      label: '$name avatar, online',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: showGradientRing ? _ringWidth * 2 : 0,
            bottom: showGradientRing ? _ringWidth * 2 : 0,
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary.withValues(alpha: 0.15),
            scheme.primary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
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
