import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/shared/widgets/empty_state.dart';
import '../../../../core/shared/widgets/error_state.dart';
import '../../../../core/shared/widgets/pyago_avatar.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/comment_model.dart';
import '../../domain/models/post_model.dart';
import '../providers/comments_provider.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  const CommentsScreen({super.key, required this.post});

  final PostModel post;

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 200) {
        ref.read(commentsControllerProvider(widget.post.id).notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentsControllerProvider(widget.post.id));

    return Scaffold(
      appBar: AppBar(title: Text(widget.post.title ?? 'Thoughts on this piece')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody(context, state)),
            _Composer(
              controller: _controller,
              isSending: state.isSending,
              onSend: () {
                final text = _controller.text;
                _controller.clear();
                ref.read(commentsControllerProvider(widget.post.id).notifier).send(text);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CommentsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.comments.isEmpty) {
      return PyagoErrorState(
        message: state.error!,
        onRetry: () => ref.refresh(commentsControllerProvider(widget.post.id)),
      );
    }
    if (state.comments.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return PyagoEmptyState(
        icon: Icons.mode_comment_outlined,
        title: l10n.commentsEmptyTitle,
        message: l10n.commentsEmptyBody,
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal, AppSpacing.sm, AppSpacing.pageHorizontal, AppSpacing.lg,
      ),
      itemCount: state.comments.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.comments.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        return _CommentTile(comment: state.comments[index]);
      },
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});
  final CommentModel comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PyagoAvatar(name: comment.authorName, imageUrl: comment.authorAvatarUrl, size: PyagoAvatarSize.sm),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.authorName, style: context.textTheme.titleSmall),
                    const SizedBox(width: 8),
                    Text(_relativeTime(comment.createdAt),
                        style: context.textTheme.bodySmall
                            ?.copyWith(color: context.colors.onSurface.withValues(alpha: 0.5))),
                    if (comment.status == CommentStatus.pending) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 10, height: 10,
                        child: CircularProgressIndicator(strokeWidth: 1.5, color: context.colors.primary),
                      ),
                    ],
                    if (comment.status == CommentStatus.failed) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.error_outline, size: 14, color: context.colors.error),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(comment.body, style: context.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.isSending, required this.onSend});

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal, AppSpacing.sm, AppSpacing.pageHorizontal, AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).commentsHint,
                  filled: true,
                  fillColor: context.colors.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton.filled(
              onPressed: isSending ? null : onSend,
              icon: isSending
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.arrow_upward_rounded),
              tooltip: 'Send',
            ),
          ],
        ),
      ),
    );
  }
}
