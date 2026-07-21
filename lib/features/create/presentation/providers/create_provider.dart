import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/network/offline_queue.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/domain/models/post_model.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../data/repositories/drafts_repository.dart';
import '../../data/services/collab_sync_service.dart';
import '../../data/services/media_pipeline_service.dart';
import '../../domain/models/collaboration_invite.dart';
import '../../domain/models/draft_model.dart';
import '../../domain/models/media_attachment.dart';
import '../../domain/templates/template_resolver.dart';

/// Drives the Create editor. Autosaves the full structured draft
/// (formatting + attachments) to Hive on a timer — this works with zero
/// connectivity by construction, since Hive is local storage. Publishing
/// goes straight through the feed repository when online, or is queued
/// in the offline outbox (with a visible "will publish when back
/// online" state) when not — and is replayed automatically once
/// connectivity returns.
class CreateController extends StateNotifier<DraftModel> {
  CreateController(this._ref)
      : super(DraftModel(id: const Uuid().v4(), createdAt: DateTime.now(), updatedAt: DateTime.now())) {
    _registerOutboxHandler();
    _autoSaveTimer = Timer.periodic(
      const Duration(seconds: AppConstants.autoSaveIntervalSeconds),
      (_) => saveDraft(),
    );
  }

  final Ref _ref;
  late final Timer _autoSaveTimer;
  bool _isSaving = false;
  bool _handlerRegistered = false;

  DraftsRepository get _drafts => _ref.read(draftsRepositoryProvider);

  void _registerOutboxHandler() {
    if (_handlerRegistered) return;
    _handlerRegistered = true;
    _ref.read(offlineQueueProvider).registerHandler('publish_post', (entry) async {
      final payload = entry.payload;
      final result = await _ref.read(feedRepositoryProvider).publish(
            title: payload['title'] as String,
            body: payload['body'] as String,
            type: PostType.values.byName(payload['type'] as String),
            readingTimeMinutes: payload['readingTimeMinutes'] as int,
            authorIds: (payload['authorIds'] as List?)?.cast<String>(),
            authorNames: (payload['authorNames'] as List?)?.cast<String>(),
          );
      return result.when(
        success: (_) async {
          await _drafts.delete(payload['draftId'] as String);
          _ref.read(feedControllerProvider.notifier).refresh();
          return true;
        },
        failure: (_) => false,
      );
    });
  }

  void _requireRole(Set<CollaboratorRole> allowed) {
    if (state.collaborators.isEmpty) return;

    final authState = _ref.read(authControllerProvider);
    final userId = authState.user?.id;
    if (userId == null) throw const CollaborationException('User not authenticated.');

    final isAuthor = state.collaborators.any((c) => c.inviterUserId == userId);
    if (isAuthor) return;

    final invite = state.collaborators.where((c) => c.inviteeUserId == userId && c.status == InviteStatus.accepted).firstOrNull;
    if (invite == null) throw const CollaborationException('You do not have access to this draft.');

    if (!allowed.contains(invite.role)) {
      throw const CollaborationException("You don't have permission to do that.");
    }
  }

  void loadDraft(DraftModel draft) => state = draft;

  void startNew() {
    state = DraftModel(id: const Uuid().v4(), createdAt: DateTime.now(), updatedAt: DateTime.now());
  }

  void updateTitle(String value) {
    _requireRole({CollaboratorRole.coAuthor});
    state = state.copyWith(title: value);
  }
  
  void updateBody(String value) {
    _requireRole({CollaboratorRole.coAuthor});
    String newValue = value;
    if (state.type == PostType.story && shouldPromoteToChapterHeading(newValue)) {
      newValue = '## Chapter 1\n\n$newValue';
    }
    state = state.copyWith(body: newValue);
  }

  void updateBodyFromCollab(String value) {
    state = state.copyWith(body: value);
  }
  
  void updateType(PostType type, {bool force = false}) {
    _requireRole({CollaboratorRole.coAuthor});
    if (state.type == type) return;
    
    final hasContent = state.body.trim().isNotEmpty || state.title.trim().isNotEmpty;
    if (hasContent && !force) {
      throw const FormatException('confirm_template_switch');
    }
    
    applyTemplate(type);
  }

  void applyTemplate(PostType type) {
    final template = templateFor(type);
    state = state.copyWith(
      type: type,
      body: state.body.trim().isEmpty ? template.initialBody : state.body,
    );
  }

  Future<void> addAttachment(MediaAttachment attachment) async {
    _requireRole({CollaboratorRole.coAuthor});
    state = state.copyWith(attachments: [...state.attachments, attachment]);
    await for (final updated in _ref.read(mediaPipelineServiceProvider).processAndUpload(attachment)) {
      final index = state.attachments.indexWhere((a) => a.id == attachment.id);
      if (index == -1) return; // removed mid-upload
      final copy = [...state.attachments];
      copy[index] = updated;
      state = state.copyWith(attachments: copy);
    }
  }

  void removeAttachment(String id) {
    _requireRole({CollaboratorRole.coAuthor});
    state = state.copyWith(attachments: state.attachments.where((a) => a.id != id).toList());
  }

  void reorderAttachments(int oldIndex, int newIndex) {
    _requireRole({CollaboratorRole.coAuthor});
    final list = [...state.attachments];
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = state.copyWith(attachments: list);
  }

  Future<void> saveDraft() async {
    if (state.isEmpty || _isSaving) return;
    _isSaving = true;
    await _drafts.save(state);
    state = state.copyWith(updatedAt: DateTime.now());
    _isSaving = false;
  }

  Future<void> deleteCurrentDraft() async {
    _requireRole({}); // Only author can delete
    await _drafts.delete(state.id);
    startNew();
  }

  /// Publishes immediately if online; otherwise queues it and marks the
  /// draft as "will publish when back online".
  Future<bool> publish() async {
    _requireRole({CollaboratorRole.coAuthor});
    await saveDraft();
    final isOnline = await _ref.read(connectivityServiceProvider).isOnline;

    final user = _ref.read(authControllerProvider).user;
    final activePersona = user?.activePersona;
    final authorId = activePersona?.id ?? user?.id ?? 'mock_user_id';
    final authorName = activePersona?.displayName ?? user?.displayName ?? 'You';

    if (!isOnline) {
      await _ref.read(offlineQueueProvider).enqueue('publish_post', {
        'draftId': state.id,
        'title': state.title,
        'body': state.resolvedBody,
        'type': state.type.name,
        'readingTimeMinutes': state.readingTimeMinutes,
        'authorIds': [authorId],
        'authorNames': [authorName],
      });
      state = state.copyWith(publishState: DraftPublishState.queuedForPublish);
      await _drafts.save(state);
      return false; // queued, not yet published
    }

    final result = await _ref.read(feedRepositoryProvider).publish(
          title: state.title,
          body: state.resolvedBody,
          type: state.type,
          readingTimeMinutes: state.readingTimeMinutes,
          authorIds: [authorId],
          authorNames: [authorName],
        );
    return result.when(
      success: (_) async {
        await _drafts.delete(state.id);
        _ref.read(feedControllerProvider.notifier).refresh();
        startNew();
        return true;
      },
      failure: (_) async {
        state = state.copyWith(publishState: DraftPublishState.failed);
        await _drafts.save(state);
        return false;
      },
    );
  }

  void inviteCollaborator(String inviteeId, CollaboratorRole role) {
    final authState = _ref.read(authControllerProvider);
    final userId = authState.user?.id;
    if (userId == null) return;
    
    if (state.collaborators.isNotEmpty && !state.collaborators.any((c) => c.inviterUserId == userId)) {
      throw const CollaborationException('Only the author can invite collaborators.');
    }

    final invite = CollaborationInvite(
      id: const Uuid().v4(),
      draftId: state.id,
      inviterUserId: userId,
      inviteeUserId: inviteeId,
      role: role,
      status: InviteStatus.pending,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(collaborators: [...state.collaborators, invite]);
  }

  void acceptInvite(String inviteId) {
    final copy = [...state.collaborators];
    final idx = copy.indexWhere((c) => c.id == inviteId);
    if (idx != -1) {
      copy[idx] = copy[idx].copyWith(status: InviteStatus.accepted, respondedAt: DateTime.now());
      state = state.copyWith(collaborators: copy);
    }
  }

  void revokeInvite(String inviteId) {
    final authState = _ref.read(authControllerProvider);
    final userId = authState.user?.id;
    
    if (state.collaborators.isNotEmpty && !state.collaborators.any((c) => c.inviterUserId == userId)) {
      throw const CollaborationException('Only the author can revoke access.');
    }

    final copy = [...state.collaborators];
    final idx = copy.indexWhere((c) => c.id == inviteId);
    if (idx != -1) {
      copy[idx] = copy[idx].copyWith(status: InviteStatus.revoked);
      state = state.copyWith(collaborators: copy);
    }
  }

  // ── Suggestion actions (delegate to CollabSyncService) ─────────────────────

  /// Accept a pending suggestion from an editor-role collaborator.
  /// The [CollabSyncService] owns the CRDT state; we just proxy here so the
  /// create screen only needs to call into one controller.
  void acceptSuggestion(String opId) {
    if (!_hasActiveCollab) return;
    _ref.read(collabSyncServiceProvider(state.id).notifier).acceptSuggestion(opId);
  }

  void rejectSuggestion(String opId) {
    if (!_hasActiveCollab) return;
    _ref.read(collabSyncServiceProvider(state.id).notifier).rejectSuggestion(opId);
  }

  bool get _hasActiveCollab =>
      state.collaborators.any((c) => c.status == InviteStatus.accepted);

  @override
  void dispose() {
    _autoSaveTimer.cancel();
    super.dispose();
  }
}

final createControllerProvider = StateNotifierProvider.autoDispose<CreateController, DraftModel>((ref) {
  return CreateController(ref);
});
