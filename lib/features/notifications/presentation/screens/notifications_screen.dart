import 'package:flutter/material.dart';
import '../../../../core/shared/widgets/empty_state.dart';
import '../../../../core/shared/widgets/pyago_avatar.dart';
import '../../../../core/theme/app_spacing.dart';

class _NotificationItem {
  const _NotificationItem(this.icon, this.actor, this.message, this.timeAgo);
  final IconData icon;
  final String actor;
  final String message;
  final String timeAgo;
}

const _notifications = [
  _NotificationItem(Icons.favorite_rounded, 'Maya Osei', 'resonated with your journal entry', '2h'),
  _NotificationItem(Icons.mode_comment_rounded, 'Daniel Cruz', 'commented on "What the River Keeps"', '5h'),
  _NotificationItem(Icons.groups_rounded, 'Quiet Writers', 'approved your join request', '1d'),
  _NotificationItem(Icons.person_add_alt_1_rounded, 'Amara Diallo', 'started following you', '2d'),
];

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: _notifications.isEmpty
          ? const PyagoEmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'All quiet',
              message: "You'll see resonances, comments, and community updates here.",
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final n = _notifications[i];
                return ListTile(
                  leading: PyagoAvatar(name: n.actor, size: PyagoAvatarSize.sm),
                  title: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(text: '${n.actor} ', style: const TextStyle(fontWeight: FontWeight.w600)),
                        TextSpan(text: n.message),
                      ],
                    ),
                  ),
                  subtitle: Text(n.timeAgo, style: Theme.of(context).textTheme.bodySmall),
                  trailing: Icon(n.icon, size: 18, color: Theme.of(context).colorScheme.primary),
                );
              },
            ),
    );
  }
}
