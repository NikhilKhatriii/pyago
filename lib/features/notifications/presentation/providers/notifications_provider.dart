import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

import '../../../create/domain/models/collaboration_invite.dart';
import '../../domain/models/notification_model.dart';

// ── Mock seed data ────────────────────────────────────────────────────────────

final _mockInviteId = const Uuid().v4();
final _mockDraftId = 'collab_draft_mock_001';

/// Seed notifications used in dev/mock flavor. The collab invite is always
/// first so the user can immediately test Accept/Decline.
List<NotificationModel> _seedNotifications() => [
      CollabInviteNotification(
        id: const Uuid().v4(),
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        invite: CollaborationInvite(
          id: _mockInviteId,
          draftId: _mockDraftId,
          inviterUserId: 'user_maya',
          inviteeUserId: 'current_user',
          role: CollaboratorRole.coAuthor,
          status: InviteStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        inviterDisplayName: 'Maya Osei',
        draftTitle: 'What the River Keeps',
        draftType: 'story',
      ),
      GenericNotification(
        id: const Uuid().v4(),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        icon: Icons.favorite_rounded.codePoint,
        actorName: 'Daniel Cruz',
        message: 'resonated with your journal entry',
      ),
      GenericNotification(
        id: const Uuid().v4(),
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        icon: Icons.mode_comment_rounded.codePoint,
        actorName: 'Daniel Cruz',
        message: 'commented on "What the River Keeps"',
      ),
      GenericNotification(
        id: const Uuid().v4(),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        icon: Icons.groups_rounded.codePoint,
        actorName: 'Quiet Writers',
        message: 'approved your join request',
      ),
      GenericNotification(
        id: const Uuid().v4(),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        icon: Icons.person_add_alt_1_rounded.codePoint,
        actorName: 'Amara Diallo',
        message: 'started following you',
      ),
    ];

// ── Controller ────────────────────────────────────────────────────────────────

class NotificationsController
    extends StateNotifier<List<NotificationModel>> {
  NotificationsController() : super(_seedNotifications());

  /// Mark all as read.
  void markAllRead() {
    state = state.map((n) => n.copyWithRead()).toList();
  }

  void markRead(String notificationId) {
    state = state
        .map((n) => n.id == notificationId ? n.copyWithRead() : n)
        .toList();
  }

  int get unreadCount => state.where((n) => !n.isRead).length;

  // ── Collaboration invite actions ──────────────────────────────────────────────

  /// Accept the collab invite for [notificationId].
  /// Updates the local notification state immediately (optimistic).
  /// Returns the accepted [CollaborationInvite] so the caller can open the draft.
  CollaborationInvite? acceptInvite(String notificationId) {
    CollaborationInvite? accepted;
    state = state.map((n) {
      if (n is CollabInviteNotification && n.id == notificationId) {
        final updatedInvite = n.invite.copyWith(
          status: InviteStatus.accepted,
          respondedAt: DateTime.now(),
        );
        accepted = updatedInvite;
        return n.copyWithRead().copyWithInvite(updatedInvite);
      }
      return n;
    }).toList();
    return accepted;
  }

  /// Decline the collab invite for [notificationId].
  void declineInvite(String notificationId) {
    state = state.map((n) {
      if (n is CollabInviteNotification && n.id == notificationId) {
        final updatedInvite = n.invite.copyWith(
          status: InviteStatus.declined,
          respondedAt: DateTime.now(),
        );
        return n.copyWithRead().copyWithInvite(updatedInvite);
      }
      return n;
    }).toList();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final notificationsControllerProvider = StateNotifierProvider<
    NotificationsController, List<NotificationModel>>((ref) {
  return NotificationsController();
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsControllerProvider).where((n) => !n.isRead).length;
});
