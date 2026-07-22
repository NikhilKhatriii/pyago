import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/connectivity_service.dart';
import '../../../../core/shared/widgets/empty_state.dart';
import '../../../../core/shared/widgets/error_state.dart';
import '../../../../core/shared/widgets/pyago_avatar.dart';
import '../../../../core/shared/widgets/pyago_button.dart';
import '../../../../core/shared/widgets/section_header.dart';
import '../../../../core/shared/widgets/skeleton_loader.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/post_card.dart';
import '../../domain/models/post_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedControllerProvider);
    final user = ref.watch(authControllerProvider).user;
    final isOnline = ref.watch(isOnlineProvider).value ?? true;
    final scheme = Theme.of(context).colorScheme;

    ref.listen(feedControllerProvider.select((s) => s.transientMessage), (prev, next) {
      if (next != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(next),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        ref.read(feedControllerProvider.notifier).dismissTransientMessage();
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: scheme.surface.withValues(alpha: 0.75),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Text(
          'Sanctuary',
          style: AppTypography.serifDisplay(
            color: scheme.primary,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/notifications'),
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: GestureDetector(
              onTap: () => context.go('/profile'),
              child: PyagoAvatar(
                name: user?.displayName ?? '',
                imageUrl: user?.avatarUrl,
                size: PyagoAvatarSize.xs,
                showGradientRing: true,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!isOnline) const _OfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(feedControllerProvider.notifier).refresh(),
              color: scheme.primary,
              child: _buildBody(context, ref, state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, FeedState state) {
    if (state.isInitialLoading) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
        children: const [SkeletonPostCard(), SkeletonPostCard(), SkeletonPostCard()],
      );
    }
    if (state.error != null && state.posts.isEmpty) {
      return PyagoErrorState(
        message: state.error!.message,
        onRetry: () => ref.read(feedControllerProvider.notifier).refresh(),
      );
    }
    if (state.posts.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return PyagoEmptyState(
        icon: Icons.auto_stories_outlined,
        title: l10n.feedEmptyTitle,
        message: l10n.feedEmptyBody,
      );
    }

    final controller = ref.read(feedControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    // Extract the first post to use as the "Featured Masterpiece" hero banner
    final featuredPost = state.posts.first;
    final feedPosts = state.posts.skip(1).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, AppSpacing.xxxl),
      children: [
        // ── Featured Masterpiece Section ─────────────────────────────────────
        _buildFeaturedHero(context, featuredPost, controller),

        const SizedBox(height: AppSpacing.xxl),

        // ── Continuing Journey Carousel ──────────────────────────────────────
        if (feedPosts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
            child: Text(
              'CONTINUING JOURNEY',
              style: AppTypography.sectionLabel(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 12),
          _buildContinuingJourney(context, feedPosts.first, controller),
          const SizedBox(height: AppSpacing.xxl),
        ],

        // ── Primary Feed List ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
          child: PyagoSectionHeader(
            title: l10n.feedTitleToday,
            actionLabel: l10n.feedSeeAll,
            onAction: () => context.push('/explore'),
          ),
        ),
        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
          child: Column(
            children: [
              for (int i = 0; i < feedPosts.length; i++)
                PostCard(
                  post: feedPosts[i],
                  index: i + 1, // Visual chapter ordering
                  onResonate: () => controller.toggleResonance(feedPosts[i].id),
                  onBookmark: () => controller.toggleBookmark(feedPosts[i].id),
                  onOpen: () => context.push('/post/${feedPosts[i].id}/comments', extra: feedPosts[i]),
                ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),
        if (state.isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (state.reachedSessionLimit)
          _CaughtUpNotice(onLoadAnyway: state.hasMore ? controller.loadMore : null)
        else if (state.hasMore)
          Center(
            child: PyagoButton(
              label: l10n.actionShowMore,
              variant: PyagoButtonVariant.secondary,
              expand: false,
              onPressed: controller.loadMore,
            ),
          )
        else
          const _CaughtUpNotice(onLoadAnyway: null),
      ],
    );
  }

  Widget _buildFeaturedHero(BuildContext context, PostModel post, FeedController controller) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => context.push('/post/${post.id}/comments', extra: post),
      child: Container(
        width: double.infinity,
        height: 480,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/welcome_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.8),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'THE FEATURED MASTERPIECE',
                style: AppTypography.sectionLabel(color: Colors.white.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: 12),
              Text(
                post.title ?? 'Silence of the Inner Horizon',
                style: AppTypography.serifDisplay(
                  color: Colors.white,
                  fontSize: 38,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  PyagoButton(
                    label: 'EXPLORE NOW',
                    variant: PyagoButtonVariant.gradient,
                    size: PyagoButtonSize.medium,
                    expand: false,
                    trailingIcon: Icons.arrow_outward_rounded,
                    onPressed: () => context.push('/post/${post.id}/comments', extra: post),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    '${post.readingTimeMinutes} min journey',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinuingJourney(BuildContext context, PostModel post, FeedController controller) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            PyagoAvatar(
              name: post.authorName,
              imageUrl: post.authorAvatarUrl,
              size: PyagoAvatarSize.lg,
              showGradientRing: true,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Continuing Journey',
                    style: AppTypography.serifDisplay(
                      color: scheme.onSurface,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Resume "${post.title ?? 'The Architecture of Stillness'}"',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.play_circle_fill, size: 36, color: scheme.primary),
              onPressed: () => context.push('/post/${post.id}/comments', extra: post),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaughtUpNotice extends StatelessWidget {
  const _CaughtUpNotice({required this.onLoadAnyway});
  final VoidCallback? onLoadAnyway;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Icon(Icons.self_improvement_outlined, color: scheme.onSurface.withValues(alpha: 0.4), size: 32),
          const SizedBox(height: 10),
          Text(l10n.feedCaughtUpTitle, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            l10n.feedCaughtUpBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurface.withValues(alpha: 0.55)),
          ),
          if (onLoadAnyway != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onLoadAnyway, child: Text(l10n.feedCaughtUpLoadAnyway)),
          ],
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      color: scheme.tertiaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, size: 16, color: scheme.onTertiaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.offlineBanner,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
