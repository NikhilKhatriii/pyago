import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Reusable premium gradient header background with optional child content.
/// Frequently used for editorial headers, profile screens, and feature intros.
class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.height,
    this.child,
    this.imageUrl,
    this.gradientColors,
  });

  final double height;
  final Widget? child;
  final String? imageUrl;
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? AppColors.brandGradient;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null)
            Opacity(
              opacity: 0.35,
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          // Gradient bottom scrim for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          if (child != null) SafeArea(child: child!),
        ],
      ),
    );
  }
}
