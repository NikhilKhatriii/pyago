import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/empty_state.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../home/data/repositories/bookmarks_repository.dart';
import '../../../home/domain/models/post_model.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../home/presentation/widgets/post_card.dart';
import '../../../../l10n/app_localizations.dart';

final bookmarksListProvider = Provider.autoDispose<List<PostModel>>((ref) {
  return ref.watch(bookmarksRepositoryProvider).listAll();
});

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(bookmarksListProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: saved.isEmpty
          ? PyagoEmptyState(
              icon: Icons.bookmark_border_rounded,
              title: l10n.bookmarksEmptyTitle,
              message: l10n.bookmarksEmptyBody,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal, AppSpacing.md, AppSpacing.pageHorizontal, AppSpacing.xxxl,
              ),
              children: [
                for (final post in saved)
                  PostCard(
                    post: post,
                    onResonate: () => ref.read(feedControllerProvider.notifier).toggleResonance(post.id),
                    onBookmark: () async {
                      await ref.read(bookmarksRepositoryProvider).remove(post.id);
                      ref.invalidate(bookmarksListProvider);
                    },
                    onOpen: () => context.push('/post/${post.id}/comments', extra: post),
                  ),
              ],
            ),
    );
  }
}
