import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_chat_repository.dart';
import '../../domain/models/chat_models.dart';
import '../../domain/repositories/chat_repository.dart';

/// Swap seam: override with an `HttpChatRepository` (ApiClient +
/// WebSocketRealtimeChannel) once a real backend exists.
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final repo = MockChatRepository();
  ref.onDispose(repo.disconnect);
  return repo;
});

final threadListProvider = AsyncNotifierProvider<ThreadListController, List<ThreadModel>>(
  ThreadListController.new,
);

class ThreadListController extends AsyncNotifier<List<ThreadModel>> {
  @override
  Future<List<ThreadModel>> build() async {
    final result = await ref.read(chatRepositoryProvider).fetchThreads();
    return result.when(success: (v) => v, failure: (e) => throw e);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(chatRepositoryProvider).fetchThreads();
      return result.when(success: (v) => v, failure: (e) => throw e);
    });
  }
}

class ChatThreadState {
  const ChatThreadState({
    this.messages = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.otherPartyTyping = false,
  });

  final List<MessageModel> messages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final bool otherPartyTyping;

  ChatThreadState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
    bool? otherPartyTyping,
  }) {
    return ChatThreadState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      otherPartyTyping: otherPartyTyping ?? this.otherPartyTyping,
    );
  }
}

class ChatThreadController extends StateNotifier<ChatThreadState> {
  ChatThreadController(this._ref, this.threadId) : super(const ChatThreadState()) {
    _load();
    _sub = _ref.read(chatRepositoryProvider).eventsFor(threadId).listen(_onEvent);
  }

  final Ref _ref;
  final String threadId;
  late final StreamSubscription _sub;
  String? _cursor;

  Future<void> _load() async {
    final result = await _ref.read(chatRepositoryProvider).fetchMessages(threadId);
    result.when(
      success: (page) {
        _cursor = page.nextCursor;
        state = state.copyWith(
          messages: page.items.reversed.toList(),
          isLoading: false,
          hasMore: page.hasMore,
        );
        if (page.items.isNotEmpty) {
          _ref.read(chatRepositoryProvider).markRead(threadId, page.items.first.id);
        }
      },
      failure: (error) => state = state.copyWith(isLoading: false, error: error.message),
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    final result = await _ref.read(chatRepositoryProvider).fetchMessages(threadId, cursor: _cursor);
    result.when(
      success: (page) {
        _cursor = page.nextCursor;
        state = state.copyWith(
          messages: [...page.items.reversed, ...state.messages],
          isLoadingMore: false,
          hasMore: page.hasMore,
        );
      },
      failure: (error) => state = state.copyWith(isLoadingMore: false, error: error.message),
    );
  }

  void send(String body) {
    if (body.trim().isEmpty) return;
    _ref.read(chatRepositoryProvider).sendMessage(threadId, body.trim());
  }

  void _onEvent(ChatEvent event) {
    switch (event) {
      case MessageEvent(:final message):
        final existingIndex = state.messages.indexWhere((m) => m.id == message.id);
        if (existingIndex != -1) {
          final copy = [...state.messages];
          copy[existingIndex] = message;
          state = state.copyWith(messages: copy);
        } else {
          state = state.copyWith(messages: [...state.messages, message], otherPartyTyping: false);
        }
      case TypingEvent(:final isTyping):
        state = state.copyWith(otherPartyTyping: isTyping);
      case ReadReceiptEvent():
        break;
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final chatThreadControllerProvider =
    StateNotifierProvider.autoDispose.family<ChatThreadController, ChatThreadState, String>(
  (ref, threadId) => ChatThreadController(ref, threadId),
);
