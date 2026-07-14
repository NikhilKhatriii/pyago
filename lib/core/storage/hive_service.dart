import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Structured, queryable local persistence beyond `SharedPreferences`.
/// Every box stores plain JSON strings (`Map<String, dynamic>` encoded
/// via `jsonEncode`) rather than generated Hive `TypeAdapter`s — this
/// keeps the storage layer decoupled from any single model's shape and
/// avoids a build_runner codegen step being a hard requirement to open
/// the app; each feature repository owns its own `toJson`/`fromJson`.
///
/// Box map:
/// - `feed_cache`      — last-known feed pages, keyed by post id
/// - `drafts`          — offline-first draft posts, keyed by draft id
/// - `bookmarks`       — bookmarked posts, keyed by post id
/// - `profile_cache`   — cached profile data, keyed by user id
/// - `outbox`          — queued mutations (publish, resonance, comment)
///                       waiting for connectivity, keyed by a uuid
class HiveService {
  static const feedCacheBox = 'feed_cache';
  static const draftsBox = 'drafts';
  static const bookmarksBox = 'bookmarks';
  static const profileCacheBox = 'profile_cache';
  static const outboxBox = 'outbox';
  static const chatCacheBox = 'chat_cache';

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<String>(feedCacheBox),
      Hive.openBox<String>(draftsBox),
      Hive.openBox<String>(bookmarksBox),
      Hive.openBox<String>(profileCacheBox),
      Hive.openBox<String>(outboxBox),
      Hive.openBox<String>(chatCacheBox),
    ]);
    _initialized = true;
  }

  Box<String> box(String name) => Hive.box<String>(name);
}

final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError('hiveServiceProvider must be overridden after HiveService.init()');
});
