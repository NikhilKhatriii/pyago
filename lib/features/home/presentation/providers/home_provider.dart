import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/mock/mock_engine.dart';
import '../../../../core/storage/hive_service.dart';
import '../../data/repositories/bookmarks_repository.dart';
import '../../data/repositories/mock_feed_repository.dart';
import '../../domain/models/post_model.dart';
import '../../domain/repositories/feed_repository.dart';

/// Swap seam: override this provider with an `HttpFeedRepository` once a
/// real backend exists (see `AppConfig`/`FeedRepository` docs). No other
/// provider or widget needs to change.
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return MockFeedRepository(hive: ref.watch(hiveServiceProvider), engine: MockEngine());
});

/// Pyago shows a deliberate, bounded feed rather than infinite scroll:
/// after this many small batches in a single session, the feed says
/// "you're caught up for today" instead of quietly continuing forever.
const int kMaxBatchesPerSession = 3;

class FeedState {
  const FeedState({
    this.posts = const [],
    this.isInitialLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.batchesLoaded = 0,
    this.error,
    this.transientMessage,
  });

  final List<PostModel> posts;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int batchesLoaded;
  final AppException? error;

  /// One-shot message for a rollback/failure toast; cleared after read.
  final String? transientMessage;

  bool get reachedSessionLimit => batchesLoaded >= kMaxBatchesPerSession;

  FeedState copyWith({
    List<PostModel>? posts,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? batchesLoaded,
    AppException? error,
    bool clearError = false,
    String? transientMessage,
    bool clearTransient = false,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      batchesLoaded: batchesLoaded ?? this.batchesLoaded,
      error: clearError ? null : (error ?? this.error),
      transientMessage: clearTransient ? null : (transientMessage ?? this.transientMessage),
    );
  }
}

class FeedController extends StateNotifier<FeedState> {
  FeedController(this._repository, this._bookmarks) : super(const FeedState()) {
    _loadInitial();
  }

  final FeedRepository _repository;
  final BookmarksRepository _bookmarks;
  String? _cursor;

  List<PostModel> _withBookmarkFlags(List<PostModel> posts) {
    final bookmarkedIds = _bookmarks.listAll().map((p) => p.id).toSet();
    if (bookmarkedIds.isEmpty) return posts;
    return posts.map((p) => bookmarkedIds.contains(p.id) ? p.copyWith(isBookmarked: true) : p).toList();
  }

  Future<void> _loadInitial() async {
    // Cache-then-network: show cached content instantly, then refresh.
    final cached = _repository.cachedFeed();
    if (cached.isNotEmpty) {
      state = state.copyWith(posts: _withBookmarkFlags(cached), isInitialLoading: false);
    }
    final result = await _repository.fetchFeed();
    result.when(
      success: (page) {
        _cursor = page.nextCursor;
        state = state.copyWith(
          posts: _withBookmarkFlags(page.items),
          isInitialLoading: false,
          hasMore: page.hasMore,
          batchesLoaded: 1,
          clearError: true,
        );
      },
      failure: (error) {
        if (cached.isNotEmpty) {
          // Already showing cache; surface a quiet banner, not a hard error.
          state = state.copyWith(isInitialLoading: false, transientMessage: error.message);
        } else {
          state = state.copyWith(isInitialLoading: false, error: error);
        }
      },
    );
  }

  Future<void> refresh() async {
    final result = await _repository.fetchFeed();
    result.when(
      success: (page) {
        _cursor = page.nextCursor;
        // Reconcile without duplicating/reordering already-seen items:
        // merge the fresh page in front of whatever wasn't refetched.
        final freshIds = page.items.map((p) => p.id).toSet();
        final remaining = state.posts.where((p) => !freshIds.contains(p.id)).toList();
        state = state.copyWith(
          posts: [...page.items, ...remaining],
          hasMore: page.hasMore,
          batchesLoaded: 1,
          clearError: true,
        );
      },
      failure: (error) {
        state = state.copyWith(transientMessage: error.message);
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.reachedSessionLimit) return;
    state = state.copyWith(isLoadingMore: true);
    final result = await _repository.fetchFeed(cursor: _cursor);
    result.when(
      success: (page) {
        _cursor = page.nextCursor;
        final existingIds = state.posts.map((p) => p.id).toSet();
        final newItems = page.items.where((p) => !existingIds.contains(p.id));
        state = state.copyWith(
          posts: [...state.posts, ...newItems],
          isLoadingMore: false,
          hasMore: page.hasMore,
          batchesLoaded: state.batchesLoaded + 1,
        );
      },
      failure: (error) {
        state = state.copyWith(isLoadingMore: false, transientMessage: error.message);
      },
    );
  }

  Future<void> toggleResonance(String postId) async {
    final index = state.posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    final original = state.posts[index];
    final willResonate = true; // resonance is a one-way "this moved me" tap, not a toggle-off
    final optimistic = original.copyWith(resonanceCount: original.resonanceCount + 1);

    state = state.copyWith(posts: _replace(state.posts, index, optimistic));

    final result = await _repository.toggleResonance(postId, resonated: willResonate);
    result.when(
      success: (_) {},
      failure: (error) {
        // Roll back on failure, with an unobtrusive toast (transientMessage).
        state = state.copyWith(
          posts: _replace(state.posts, index, original),
          transientMessage: 'Could not save that — ${error.message}',
        );
      },
    );
  }

  void toggleBookmark(String postId) {
    final index = state.posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    final post = state.posts[index];
    final nowBookmarked = !post.isBookmarked;
    final updated = post.copyWith(isBookmarked: nowBookmarked);
    state = state.copyWith(posts: _replace(state.posts, index, updated));
    if (nowBookmarked) {
      _bookmarks.add(updated);
    } else {
      _bookmarks.remove(postId);
    }
  }

  void dismissTransientMessage() {
    state = state.copyWith(clearTransient: true);
  }

  List<PostModel> _replace(List<PostModel> posts, int index, PostModel value) {
    final copy = [...posts];
    copy[index] = value;
    return copy;
  }
}

final feedControllerProvider = StateNotifierProvider<FeedController, FeedState>((ref) {
  return FeedController(ref.watch(feedRepositoryProvider), ref.watch(bookmarksRepositoryProvider));
});
