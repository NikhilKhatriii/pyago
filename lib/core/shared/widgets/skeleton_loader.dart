import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

/// A shimmering placeholder block, used while content is loading so the
/// layout doesn't jump once real data arrives. Overridden with warm tones
/// matching Pyago's refined editorial palette.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height = 16, this.radius});

  final double? width;
  final double height;
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use warm ivory/parchment tones for light, custom violet-slate for dark
    final Color baseCol = isDark ? AppColors.darkSurfaceVariant : AppColors.parchment;
    final Color highlightCol = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Shimmer.fromColors(
      baseColor: baseCol,
      highlightColor: highlightCol,
      period: const Duration(milliseconds: 2500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseCol,
          borderRadius: radius ?? AppRadius.radiusSm,
        ),
      ),
    );
  }
}

/// A skeleton shaped like a [PostCard]-style feed item.
class SkeletonPostCard extends StatelessWidget {
  const SkeletonPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonBox(
                width: 36,
                height: 36,
                radius: BorderRadius.all(Radius.circular(18)),
              ),
              const SizedBox(width: 12),
              SkeletonBox(width: 120, height: 12, radius: AppRadius.radiusXs),
            ],
          ),
          const SizedBox(height: 16),
          SkeletonBox(width: double.infinity, height: 140, radius: AppRadius.radiusCard),
          const SizedBox(height: 12),
          SkeletonBox(width: double.infinity, height: 14, radius: AppRadius.radiusXs),
          const SizedBox(height: 8),
          SkeletonBox(width: 220, height: 14, radius: AppRadius.radiusXs),
        ],
      ),
    );
  }
}
