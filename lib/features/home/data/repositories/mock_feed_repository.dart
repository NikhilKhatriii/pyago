import 'dart:convert';
import 'dart:math';

import 'package:hive/hive.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/mock/mock_engine.dart';
import '../../../../core/network/pagination.dart';
import '../../../../core/network/result.dart';
import '../../../../core/storage/hive_service.dart';
import '../../domain/models/comment_model.dart';
import '../../domain/models/post_model.dart';
import '../../domain/repositories/feed_repository.dart';

/// Realistic in-memory fake backend for the home feed.
///
/// Deliberately behaves like a real paginated API: small page sizes (no
/// infinite/addictive scroll — Pyago's "for today" feed has a natural
/// stopping point per session), simulated latency, and an injected
/// transient-failure rate (see [MockEngine]). Every read that succeeds is
/// written through to the Hive `feed_cache` box, so [cachedFeed] can
/// serve instantly on next launch even fully offline.
///
/// Swap seam: replace this class with an `HttpFeedRepository` that talks
/// through `ApiClient` instead of [MockEngine]/the in-memory pool, and
/// update the single override in `home_provider.dart`. Nothing in the
/// domain layer, providers, or UI needs to change.
class MockFeedRepository implements FeedRepository {
  MockFeedRepository({required HiveService hive, MockEngine? engine})
      : _hive = hive,
        _engine = engine ?? MockEngine() {
    _seedPool();
  }

  final HiveService _hive;
  final MockEngine _engine;

  late final List<PostModel> _pool;
  final Map<String, List<CommentModel>> _comments = {};

  Box<String> get _feedBox => _hive.box(HiveService.feedCacheBox);

  @override
  List<PostModel> cachedFeed() {
    final raw = _feedBox.values;
    final posts = raw.map((v) => PostModel.fromJson(jsonDecode(v) as Map<String, dynamic>)).toList();
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }

  @override
  Future<Result<Page<PostModel>>> fetchFeed({String? cursor}) async {
    await _engine.latency();
    try {
      _engine.maybeFail();
    } on AppException catch (e) {
      return Result.failure(e);
    }
    final page = _engine.paginate(_pool, cursor: cursor, pageSize: 6);
    for (final post in page.items) {
      await _feedBox.put(post.id, jsonEncode(post.toJson()));
    }
    return Result.success(page);
  }

  @override
  Future<Result<void>> toggleResonance(String postId, {required bool resonated}) async {
    await _engine.latency(multiplier: 0.4);
    try {
      _engine.maybeFail(error: () => const NetworkException('Could not update resonance.'));
    } on AppException catch (e) {
      return Result.failure(e);
    }
    final index = _pool.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _pool[index] = _pool[index].copyWith(
        resonanceCount: _pool[index].resonanceCount + (resonated ? 1 : -1),
      );
      await _feedBox.put(postId, jsonEncode(_pool[index].toJson()));
    }
    return const Result.success(null);
  }

  @override
  Future<Result<Page<CommentModel>>> fetchComments(String postId, {String? cursor}) async {
    await _engine.latency(multiplier: 0.6);
    try {
      _engine.maybeFail();
    } on AppException catch (e) {
      return Result.failure(e);
    }
    final all = _comments[postId] ?? _seedComments(postId);
    return Result.success(_engine.paginate(all, cursor: cursor, pageSize: 10));
  }

  @override
  Future<Result<CommentModel>> addComment(String postId, String body) async {
    await _engine.latency(multiplier: 0.5);
    try {
      _engine.maybeFail(error: () => const NetworkException('Your comment could not be posted.'));
    } on AppException catch (e) {
      return Result.failure(e);
    }
    final comment = CommentModel(
      id: 'c_${DateTime.now().microsecondsSinceEpoch}',
      postId: postId,
      authorName: 'You',
      body: body,
      createdAt: DateTime.now(),
    );
    _comments.putIfAbsent(postId, () => []).insert(0, comment);
    final index = _pool.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _pool[index] = _pool[index].copyWith(commentCount: _pool[index].commentCount + 1);
      await _feedBox.put(postId, jsonEncode(_pool[index].toJson()));
    }
    return Result.success(comment);
  }

  @override
  Future<Result<PostModel>> publish({
    required String title,
    required String body,
    required PostType type,
    required int readingTimeMinutes,
  }) async {
    await _engine.latency(multiplier: 1.2);
    try {
      _engine.maybeFail(error: () => const ServerException('Your post could not be published. It will retry automatically.'));
    } on AppException catch (e) {
      return Result.failure(e);
    }
    final post = PostModel(
      id: 'p_${DateTime.now().microsecondsSinceEpoch}',
      authorName: 'You',
      type: type,
      title: title.isEmpty ? null : title,
      content: body,
      readingTimeMinutes: readingTimeMinutes,
      resonanceCount: 0,
      commentCount: 0,
      createdAt: DateTime.now(),
    );
    _pool.insert(0, post);
    await _feedBox.put(post.id, jsonEncode(post.toJson()));
    return Result.success(post);
  }

  List<CommentModel> _seedComments(String postId) {
    final rand = Random(postId.hashCode);
    final names = ['Sofia Reyes', 'Tomas Berg', 'Aiko Sato', 'Liam Okafor', 'Nadia Farouk'];
    final bodies = [
      'This stayed with me longer than I expected.',
      'The last line undid me a little.',
      'Reading this again on a slower morning.',
      'Thank you for writing this down.',
      'I felt this exactly last spring.',
    ];
    final count = 2 + rand.nextInt(5);
    final list = List.generate(count, (i) {
      return CommentModel(
        id: '${postId}_seed_$i',
        postId: postId,
        authorName: names[rand.nextInt(names.length)],
        body: bodies[rand.nextInt(bodies.length)],
        createdAt: DateTime.now().subtract(Duration(hours: i * 3 + rand.nextInt(3))),
      );
    });
    _comments[postId] = list;
    return list;
  }

  void _seedPool() {
    final now = DateTime.now();
    const authors = [
      'Maya Osei', 'Daniel Cruz', 'Amara Diallo', 'Kenji Watanabe', 'Priya Nair',
      'Sofia Reyes', 'Tomas Berg', 'Aiko Sato', 'Liam Okafor', 'Nadia Farouk',
    ];
    const lines = [
      ('poetry', 'What the River Keeps',
          'The river does not remember my name,\nonly the shape I leave when I wade in—\na small disturbance, briefly held,\nthen smoothed away like it never happened.'),
      ('journal', 'Six months in',
          "I keep waiting for the day this stops feeling like borrowed time. It hasn't come yet, and I'm starting to think that's the point."),
      ('article', 'On writing slower than you think',
          'We treat first drafts like confessions we have to defend. They are not. A first draft is just the first place a thought decided to stand still.'),
      ('thought', null, 'Some days the only honest sentence I can write is: I am still here.'),
      ('voice', 'A note to my younger self',
          'A short voice journal recorded on a train, three minutes long.'),
      ('journal', 'Learning to sit with unfinished things',
          "Not every open loop needs closing this year. Some of them are just still growing."),
      ('poetry', 'Late Kitchen Light',
          'Onions gone soft in butter,\nthe radio low,\nsomeone I love\nasking about my day\nlike it matters,\nbecause it does.'),
      ('thought', null, 'Grief is just love that ran out of places to go, for a while.'),
      ('article', 'The discipline of finishing small things',
          'Momentum is not a feeling you wait for. It is a residue left behind by starting anyway.'),
      ('image', 'Morning walk, unedited', 'A photo from a walk before the city woke up.'),
    ];

    _pool = List.generate(32, (i) {
      final (typeStr, title, content) = lines[i % lines.length];
      final type = PostType.values.firstWhere((t) => t.name == typeStr);
      return PostModel(
        id: 'p${i + 1}',
        authorName: authors[i % authors.length],
        type: type,
        title: title,
        content: content,
        readingTimeMinutes: 1 + (content.length ~/ 220),
        resonanceCount: 40 + (i * 37) % 460,
        commentCount: 2 + (i * 5) % 60,
        createdAt: now.subtract(Duration(hours: i * 3 + 1)),
      );
    });
  }
}
