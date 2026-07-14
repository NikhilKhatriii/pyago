import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/comment_model.dart';
import 'home_provider.dart';

class CommentsState {
  const CommentsState({
    this.comments = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.isSending = false,
  });

  final List<CommentModel> comments;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final bool isSending;

  CommentsState copyWith({
    List<CommentModel>? comments,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
    bool? isSending,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      isSending: isSending ?? this.isSending,
    );
  }
}

class CommentsController extends StateNotifier<CommentsState> {
  CommentsController(this._ref, this.postId) : super(const CommentsState()) {
    _load();
  }

  final Ref _ref;
  final String postId;
  String? _cursor;

  Future<void> _load() async {
    final result = await _ref.read(feedRepositoryProvider).fetchComments(postId);
    result.when(
      success: (page) {
        _cursor = page.nextCursor;
        state = state.copyWith(comments: page.items, isLoading: false, hasMore: page.hasMore);
      },
      failure: (error) => state = state.copyWith(isLoading: false, error: error.message),
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    final result = await _ref.read(feedRepositoryProvider).fetchComments(postId, cursor: _cursor);
    result.when(
      success: (page) {
        _cursor = page.nextCursor;
        state = state.copyWith(
          comments: [...state.comments, ...page.items],
          isLoadingMore: false,
          hasMore: page.hasMore,
        );
      },
      failure: (error) => state = state.copyWith(isLoadingMore: false, error: error.message),
    );
  }

  Future<void> send(String body) async {
    if (body.trim().isEmpty) return;
    state = state.copyWith(isSending: true, clearError: true);
    final result = await _ref.read(feedRepositoryProvider).addComment(postId, body.trim());
    result.when(
      success: (comment) {
        state = state.copyWith(comments: [comment, ...state.comments], isSending: false);
      },
      failure: (error) {
        state = state.copyWith(isSending: false, error: error.message);
      },
    );
  }
}

final commentsControllerProvider =
    StateNotifierProvider.autoDispose.family<CommentsController, CommentsState, String>(
  (ref, postId) => CommentsController(ref, postId),
);
