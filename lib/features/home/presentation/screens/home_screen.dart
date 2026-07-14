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
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/post_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedControllerProvider);
    final user = ref.watch(authControllerProvider).user;
    final isOnline = ref.watch(isOnlineProvider).value ?? true;

    ref.listen(feedControllerProvider.select((s) => s.transientMessage), (prev, next) {
      if (next != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next), duration: const Duration(seconds: 3)));
        ref.read(feedControllerProvider.notifier).dismissTransientMessage();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pyago'),
        actions: [
          IconButton(
            onPressed: () => context.push('/notifications'),
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: GestureDetector(
              onTap: () => context.go('/profile'),
              child: PyagoAvatar(name: user?.displayName ?? '', imageUrl: user?.avatarUrl, size: PyagoAvatarSize.xs),
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal, AppSpacing.sm, AppSpacing.pageHorizontal, AppSpacing.xxxl,
      ),
      children: [
        PyagoSectionHeader(title: l10n.feedTitleToday, actionLabel: l10n.feedSeeAll, onAction: () => context.push('/explore')),
        for (final post in state.posts)
          PostCard(
            post: post,
            onResonate: () => controller.toggleResonance(post.id),
            onBookmark: () => controller.toggleBookmark(post.id),
            onOpen: () => context.push('/post/${post.id}/comments', extra: post),
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
