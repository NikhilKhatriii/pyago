import 'package:flutter_test/flutter_test.dart';
import 'package:pyago/core/errors/app_exception.dart';
import 'package:pyago/core/network/pagination.dart';
import 'package:pyago/core/network/result.dart';
import 'package:pyago/core/storage/hive_service.dart';
import 'package:pyago/features/home/data/repositories/bookmarks_repository.dart';
import 'package:pyago/features/home/domain/models/comment_model.dart';
import 'package:pyago/features/home/domain/models/post_model.dart';
import 'package:pyago/features/home/domain/repositories/feed_repository.dart';
import 'package:pyago/features/home/presentation/providers/home_provider.dart';

PostModel _post(String id, {int resonance = 0}) => PostModel(
      id: id,
      authorName: 'Author',
      type: PostType.thought,
      content: 'content $id',
      resonanceCount: resonance,
      createdAt: DateTime(2026, 1, 1),
    );

/// Hand-written fake so pagination/rollback logic can be tested without
/// any latency or randomness from `MockEngine`.
class _FakeFeedRepository implements FeedRepository {
  _FakeFeedRepository(this._pages);

  final List<Page<PostModel>> _pages;
  int _callIndex = 0;
  bool failNextResonanceToggle = false;

  @override
  List<PostModel> cachedFeed() => [];

  @override
  Future<Result<Page<PostModel>>> fetchFeed({String? cursor}) async {
    final page = _pages[_callIndex.clamp(0, _pages.length - 1)];
    _callIndex++;
    return Result.success(page);
  }

  @override
  Future<Result<void>> toggleResonance(String postId, {required bool resonated}) async {
    if (failNextResonanceToggle) {
      failNextResonanceToggle = false;
      return const Result.failure(NetworkException('could not resonate'));
    }
    return const Result.success(null);
  }

  @override
  Future<Result<Page<CommentModel>>> fetchComments(String postId, {String? cursor}) async =>
      Result.success(Page.empty());

  @override
  Future<Result<CommentModel>> addComment(String postId, String body) async =>
      throw UnimplementedError();

  @override
  Future<Result<PostModel>> publish({
    required String title,
    required String body,
    required PostType type,
    required int readingTimeMinutes,
  }) async =>
      throw UnimplementedError();
}

class _FakeBookmarksRepository extends BookmarksRepository {
  _FakeBookmarksRepository() : super(HiveService());
  final Set<String> _ids = {};

  @override
  List<PostModel> listAll() => [];

  @override
  bool isBookmarked(String postId) => _ids.contains(postId);

  @override
  Future<void> add(PostModel post) async => _ids.add(post.id);

  @override
  Future<void> remove(String postId) async => _ids.remove(postId);
}

void main() {
  group('FeedController', () {
    test('loadMore appends new items without duplicating existing ones', () async {
      final repo = _FakeFeedRepository([
        Page(items: [_post('p1'), _post('p2')], nextCursor: '2', hasMore: true),
        Page(items: [_post('p3'), _post('p4')], nextCursor: '4', hasMore: true),
      ]);
      final controller = FeedController(repo, _FakeBookmarksRepository());
      await Future.delayed(Duration.zero); // let initial load settle

      await controller.loadMore();

      expect(controller.state.posts.map((p) => p.id), ['p1', 'p2', 'p3', 'p4']);
      expect(controller.state.batchesLoaded, 2);
    });

    test('stops offering more after kMaxBatchesPerSession without losing loaded posts', () async {
      final repo = _FakeFeedRepository([
        Page(items: [_post('p1')], nextCursor: '1', hasMore: true),
        Page(items: [_post('p2')], nextCursor: '2', hasMore: true),
        Page(items: [_post('p3')], nextCursor: '3', hasMore: true),
        Page(items: [_post('p4')], nextCursor: '4', hasMore: true),
      ]);
      final controller = FeedController(repo, _FakeBookmarksRepository());
      await Future.delayed(Duration.zero);

      await controller.loadMore(); // batch 2
      await controller.loadMore(); // batch 3 -> reaches limit
      final postsAtLimit = controller.state.posts.length;
      await controller.loadMore(); // should be a no-op past the limit

      expect(controller.state.reachedSessionLimit, isTrue);
      expect(controller.state.posts.length, postsAtLimit);
    });

    test('toggleResonance rolls back the optimistic update on failure', () async {
      final repo = _FakeFeedRepository([
        Page(items: [_post('p1', resonance: 10)], nextCursor: null, hasMore: false),
      ]);
      repo.failNextResonanceToggle = true;
      final controller = FeedController(repo, _FakeBookmarksRepository());
      await Future.delayed(Duration.zero);

      await controller.toggleResonance('p1');

      expect(controller.state.posts.first.resonanceCount, 10);
      expect(controller.state.transientMessage, isNotNull);
    });

    test('toggleResonance keeps the optimistic increment on success', () async {
      final repo = _FakeFeedRepository([
        Page(items: [_post('p1', resonance: 10)], nextCursor: null, hasMore: false),
      ]);
      final controller = FeedController(repo, _FakeBookmarksRepository());
      await Future.delayed(Duration.zero);

      await controller.toggleResonance('p1');

      expect(controller.state.posts.first.resonanceCount, 11);
    });
  });
}
