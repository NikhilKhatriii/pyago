import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/network/offline_queue.dart';
import '../../../home/domain/models/post_model.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../data/repositories/drafts_repository.dart';
import '../../data/services/media_pipeline_service.dart';
import '../../domain/models/draft_model.dart';
import '../../domain/models/media_attachment.dart';

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

  void loadDraft(DraftModel draft) => state = draft;

  void startNew() {
    state = DraftModel(id: const Uuid().v4(), createdAt: DateTime.now(), updatedAt: DateTime.now());
  }

  void updateTitle(String value) => state = state.copyWith(title: value);
  void updateBody(String value) => state = state.copyWith(body: value);
  void updateType(PostType type) => state = state.copyWith(type: type);

  Future<void> addAttachment(MediaAttachment attachment) async {
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
    state = state.copyWith(attachments: state.attachments.where((a) => a.id != id).toList());
  }

  void reorderAttachments(int oldIndex, int newIndex) {
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
    await _drafts.delete(state.id);
    startNew();
  }

  /// Publishes immediately if online; otherwise queues it and marks the
  /// draft as "will publish when back online".
  Future<bool> publish() async {
    await saveDraft();
    final isOnline = await _ref.read(connectivityServiceProvider).isOnline;

    if (!isOnline) {
      await _ref.read(offlineQueueProvider).enqueue('publish_post', {
        'draftId': state.id,
        'title': state.title,
        'body': state.body,
        'type': state.type.name,
        'readingTimeMinutes': state.readingTimeMinutes,
      });
      state = state.copyWith(publishState: DraftPublishState.queuedForPublish);
      await _drafts.save(state);
      return false; // queued, not yet published
    }

    final result = await _ref.read(feedRepositoryProvider).publish(
          title: state.title,
          body: state.body,
          type: state.type,
          readingTimeMinutes: state.readingTimeMinutes,
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

  @override
  void dispose() {
    _autoSaveTimer.cancel();
    super.dispose();
  }
}

final createControllerProvider = StateNotifierProvider.autoDispose<CreateController, DraftModel>((ref) {
  return CreateController(ref);
});
