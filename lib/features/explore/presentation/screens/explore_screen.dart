import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/shared/widgets/error_state.dart';
import '../../../../core/shared/widgets/pyago_badge.dart';
import '../../../../core/shared/widgets/skeleton_loader.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../home/presentation/widgets/post_card.dart';
import '../../../home/domain/models/post_model.dart';

final _exploreFilterProvider = StateProvider<PostType?>((ref) => null);

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedControllerProvider);
    final filter = ref.watch(_exploreFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
              children: [
                PyagoTag(
                  label: 'All',
                  selected: filter == null,
                  onTap: () => ref.read(_exploreFilterProvider.notifier).state = null,
                ),
                const SizedBox(width: AppSpacing.sm),
                for (final type in PostType.values) ...[
                  PyagoTag(
                    label: type.label,
                    selected: filter == type,
                    onTap: () => ref.read(_exploreFilterProvider.notifier).state = type,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: Builder(builder: (context) {
              if (feed.isInitialLoading) {
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
                  children: const [SkeletonPostCard(), SkeletonPostCard()],
                );
              }
              if (feed.error != null && feed.posts.isEmpty) {
                return PyagoErrorState(
                  message: feed.error!.message,
                  onRetry: () => ref.read(feedControllerProvider.notifier).refresh(),
                );
              }
              final filtered = filter == null ? feed.posts : feed.posts.where((p) => p.type == filter).toList();
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, 0, AppSpacing.pageHorizontal, AppSpacing.xxxl,
                ),
                children: [
                  for (final post in filtered)
                    PostCard(
                      post: post,
                      onResonate: () => ref.read(feedControllerProvider.notifier).toggleResonance(post.id),
                      onBookmark: () => ref.read(feedControllerProvider.notifier).toggleBookmark(post.id),
                      onOpen: () => context.push('/post/${post.id}/comments', extra: post),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
