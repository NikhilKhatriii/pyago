import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/empty_state.dart';
import '../../../../core/shared/widgets/error_state.dart';
import '../../../../core/shared/widgets/pyago_avatar.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/chat_provider.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(threadListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(threadListProvider.notifier).refresh(),
        child: threads.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => PyagoErrorState(
            message: err.toString(),
            onRetry: () => ref.read(threadListProvider.notifier).refresh(),
          ),
          data: (list) {
            if (list.isEmpty) {
              final l10n = AppLocalizations.of(context);
              return PyagoEmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: l10n.chatEmptyTitle,
                message: l10n.chatEmptyBody,
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final thread = list[i];
                return ListTile(
                  leading: PyagoAvatar(
                    name: thread.title,
                    imageUrl: thread.avatarUrl,
                    size: PyagoAvatarSize.md,
                    showOnlineDot: thread.unreadCount > 0,
                  ),
                  title: Text(
                    thread.title,
                    style: TextStyle(fontWeight: thread.unreadCount > 0 ? FontWeight.w700 : FontWeight.w500),
                  ),
                  subtitle: Text(thread.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text(_timeAgo(thread.lastMessageAt), style: Theme.of(context).textTheme.bodySmall),
                  onTap: () => context.push('/chat/${thread.id}', extra: {'title': thread.title}),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
