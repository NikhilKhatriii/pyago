import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/shared/widgets/pyago_avatar.dart';
import '../../../../core/shared/widgets/pyago_badge.dart';
import '../../../../core/theme/app_colors.dart';
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
    this.index = 1,
  });

  final PostModel post;
  final VoidCallback onResonate;
  final VoidCallback onBookmark;
  final VoidCallback onOpen;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLongForm = post.type == PostType.article || post.type == PostType.journal;

    // Chapters mapping (e.g. Chapter 01 — Perception, Chapter 02 — Resonance, etc.)
    final List<String> concepts = [
      'PERCEPTION',
      'RESONANCE',
      'STILLNESS',
      'INTUITION',
      'ECHOES',
      'EXPRESSION',
    ];
    final conceptName = concepts[(index - 1) % concepts.length];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadius.radiusCard,
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpen,
          borderRadius: AppRadius.radiusCard,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chapter concept header
                Text(
                  'CHAPTER 0$index — $conceptName',
                  style: AppTypography.sectionLabel(color: scheme.onSurface.withValues(alpha: 0.45)),
                ),
                const SizedBox(height: 12),
                if (post.title != null) ...[
                  Text(
                    post.title!,
                    style: AppTypography.serifDisplay(
                      color: scheme.onSurface,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Text(
                  post.content,
                  maxLines: isLongForm ? 3 : 5,
                  overflow: TextOverflow.ellipsis,
                  style: isLongForm
                      ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.75),
                            height: 1.6,
                          )
                      : AppTypography.displaySerif(
                          color: scheme.onSurface,
                          fontSize: 16,
                        ),
                ),
                const SizedBox(height: 20),
                // Read Experience CTA
                GestureDetector(
                  onTap: onOpen,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Read Experience',
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 16, color: scheme.primary),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    PyagoAvatar(
                      name: post.authorName,
                      imageUrl: post.authorAvatarUrl,
                      size: PyagoAvatarSize.sm,
                      showGradientRing: true,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.authorName,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            '${post.readingTimeMinutes} min · ${post.type.label}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurface.withValues(alpha: 0.55),
                                  fontSize: 11,
                                ),
                          ),
                        ],
                      ),
                    ),
                    _ActionChip(
                      icon: Icons.favorite_rounded,
                      label: '${post.resonanceCount}',
                      color: scheme.primary,
                      onTap: onResonate,
                      semanticLabel: '${post.resonanceCount} resonances. Tap to resonate with this.',
                    ),
                    const SizedBox(width: 8),
                    _ActionChip(
                      icon: Icons.mode_comment_outlined,
                      label: '${post.commentCount}',
                      color: scheme.onSurface.withValues(alpha: 0.6),
                      onTap: onOpen,
                      semanticLabel: '${post.commentCount} comments. Tap to view.',
                    ),
                    const SizedBox(width: 4),
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

class _ActionChip extends StatefulWidget {
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
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTapDown: (_) {
          HapticFeedback.lightImpact();
          setState(() => _pressed = true);
        },
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 100),
          scale: _pressed ? 0.85 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: _pressed ? widget.color.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 16, color: widget.color),
                const SizedBox(width: 4),
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: widget.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
