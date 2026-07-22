import '../../../../core/network/pagination.dart';
import '../../../../core/network/result.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';

/// Contract for the home feed. `MockFeedRepository` is the only
/// implementation until a real backend exists — swapping it means
/// implementing this interface (talking through `ApiClient`) and
/// updating the single override in `home_provider.dart`.
abstract interface class FeedRepository {
  /// First page comes from cache instantly if available; callers that
  /// want the cache-then-network pattern should call [cachedFeed] first
  /// and then this.
  Future<Result<Page<PostModel>>> fetchFeed({String? cursor});

  /// Returns whatever was last cached, synchronously-fast, for the
  /// cache-then-network pattern. Empty if nothing has ever been fetched.
  List<PostModel> cachedFeed();

  Future<Result<void>> toggleResonance(String postId, {required bool resonated});

  Future<Result<Page<CommentModel>>> fetchComments(String postId, {String? cursor});

  Future<Result<CommentModel>> addComment(String postId, String body);

  /// Publishes a new post (from the Create screen) so it appears at the
  /// top of the feed. Used directly when online, and via the offline
  /// outbox handler registered in `create_provider.dart` when not.
  Future<Result<PostModel>> publish({
    required String title,
    required String body,
    required PostType type,
    required int readingTimeMinutes,
    List<String>? authorIds,
    List<String>? authorNames,
  });
}
