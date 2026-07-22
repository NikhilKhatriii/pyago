import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/empty_state.dart';
import '../../../../core/shared/widgets/pyago_avatar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../create/domain/models/collaboration_invite.dart';
import '../../../create/domain/models/draft_model.dart';
import '../../domain/models/notification_model.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () =>
                  ref.read(notificationsControllerProvider.notifier).markAllRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const PyagoEmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'All quiet',
              message:
                  "You'll see resonances, comments, collaborations, and community updates here.",
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: notifications.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: scheme.outlineVariant.withOpacity(0.5)),
              itemBuilder: (context, i) {
                final notification = notifications[i];
                return _NotificationTile(notification: notification)
                    .animate()
                    .fadeIn(delay: (i * 30).ms, duration: 250.ms)
                    .slideY(begin: 0.05, duration: 250.ms);
              },
            ),
    );
  }
}

// ── Tile dispatcher ───────────────────────────────────────────────────────────

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});
  final NotificationModel notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (notification) {
      CollabInviteNotification n => _CollabInviteTile(notification: n),
      GenericNotification n      => _GenericTile(notification: n),
    };
  }
}

// ── Collab Invite Tile ────────────────────────────────────────────────────────

class _CollabInviteTile extends ConsumerWidget {
  const _CollabInviteTile({required this.notification});
  final CollabInviteNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final controller = ref.read(notificationsControllerProvider.notifier);
    final isPending = notification.invite.status == InviteStatus.pending;
    final isAccepted = notification.invite.status == InviteStatus.accepted;
    final isDeclined = notification.invite.status == InviteStatus.declined;

    return Container(
      color: notification.isRead
          ? Colors.transparent
          : scheme.primaryContainer.withOpacity(0.08),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  PyagoAvatar(name: notification.inviterDisplayName, size: PyagoAvatarSize.sm),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: scheme.surface, width: 1.5),
                      ),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 9,
                        color: scheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: '${notification.inviterDisplayName} ',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: 'invited you to co-write ',
                          ),
                          TextSpan(
                            text: '"${notification.draftTitle}"',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: scheme.primary,
                            ),
                          ),
                          TextSpan(text: ' as ${notification.roleLabel}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _FormatChip(type: notification.draftType),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          notification.timeAgo,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.declineInvite(notification.id),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: scheme.outlineVariant),
                      foregroundColor: scheme.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      final accepted = controller.acceptInvite(notification.id);
                      if (accepted != null && context.mounted) {
                        // Navigate to the shared draft.
                        context.go(
                          '/create',
                          extra: DraftModel(
                            id: accepted.draftId,
                            title: notification.draftTitle,
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                            collaborators: [accepted],
                          ),
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  isAccepted ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 14,
                  color: isAccepted ? AppColors.success : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  isAccepted ? 'Accepted' : 'Declined',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isAccepted ? AppColors.success : scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Generic Tile ──────────────────────────────────────────────────────────────

class _GenericTile extends StatelessWidget {
  const _GenericTile({required this.notification});
  final GenericNotification notification;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      color: notification.isRead
          ? Colors.transparent
          : scheme.primaryContainer.withOpacity(0.08),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: PyagoAvatar(name: notification.actorName, size: PyagoAvatarSize.sm),
        title: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(
                text: '${notification.actorName} ',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              TextSpan(text: notification.message),
            ],
          ),
        ),
        subtitle: Text(
          notification.timeAgo,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        trailing: Icon(
          IconData(notification.icon, fontFamily: 'MaterialIcons'),
          size: 18,
          color: scheme.primary,
        ),
      ),
    );
  }
}

// ── Format chip ───────────────────────────────────────────────────────────────

class _FormatChip extends StatelessWidget {
  const _FormatChip({required this.type});
  final String type;

  static const _icons = {
    'story':   Icons.auto_stories_rounded,
    'journal': Icons.book_rounded,
    'article': Icons.article_rounded,
    'poetry':  Icons.format_quote_rounded,
    'voice':   Icons.mic_rounded,
    'thought': Icons.lightbulb_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon = _icons[type] ?? Icons.edit_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withOpacity(0.6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: scheme.primary),
          const SizedBox(width: 3),
          Text(
            type,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
