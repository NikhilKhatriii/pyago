import 'package:flutter/material.dart';
import '../../../../core/shared/widgets/pyago_avatar.dart';
import '../../../../core/shared/widgets/pyago_badge.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/post_model.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onResonate,
    required this.onBookmark,
    required this.onOpen,
  });

  final PostModel post;
  final VoidCallback onResonate;
  final VoidCallback onBookmark;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLongForm = post.type == PostType.article || post.type == PostType.journal;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: scheme.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PyagoAvatar(name: post.authorName, imageUrl: post.authorAvatarUrl, size: PyagoAvatarSize.sm),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.authorName, style: Theme.of(context).textTheme.titleSmall),
                          Text(
                            '${post.readingTimeMinutes} min · ${post.type.label}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurface.withValues(alpha: 0.55),
                                ),
                          ),
                        ],
                      ),
                    ),
                    PyagoBadge(label: post.type.label),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (post.title != null) ...[
                  Text(post.title!, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                ],
                Text(
                  post.content,
                  maxLines: isLongForm ? 3 : 6,
                  overflow: TextOverflow.ellipsis,
                  style: isLongForm
                      ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.75),
                          )
                      : AppTypography.displaySerif(color: scheme.onSurface, fontSize: 16),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _ActionChip(
                      icon: Icons.favorite_rounded,
                      label: '${post.resonanceCount}',
                      color: scheme.primary,
                      onTap: onResonate,
                      semanticLabel: '${post.resonanceCount} resonances. Tap to resonate with this.',
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    _ActionChip(
                      icon: Icons.mode_comment_outlined,
                      label: '${post.commentCount}',
                      color: scheme.onSurface.withValues(alpha: 0.6),
                      onTap: onOpen,
                      semanticLabel: '${post.commentCount} comments. Tap to view.',
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onBookmark,
                      icon: Icon(
                        post.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: post.isBookmarked ? scheme.primary : scheme.onSurface.withValues(alpha: 0.6),
                      ),
                      tooltip: post.isBookmarked ? 'Remove bookmark' : 'Bookmark',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.semanticLabel,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
