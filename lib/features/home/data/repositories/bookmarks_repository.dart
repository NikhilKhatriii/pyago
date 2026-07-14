import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../core/storage/hive_service.dart';
import '../../domain/models/post_model.dart';

/// Bookmarks are stored independently of the feed cache, so a bookmarked
/// post remains available offline even after it scrolls out of the
/// feed's cached window.
class BookmarksRepository {
  BookmarksRepository(this._hive);

  final HiveService _hive;
  Box<String> get _box => _hive.box(HiveService.bookmarksBox);

  List<PostModel> listAll() {
    final posts = _box.values.map((v) => PostModel.fromJson(jsonDecode(v) as Map<String, dynamic>)).toList();
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }

  bool isBookmarked(String postId) => _box.containsKey(postId);

  Future<void> add(PostModel post) => _box.put(post.id, jsonEncode(post.toJson()));

  Future<void> remove(String postId) => _box.delete(postId);
}

final bookmarksRepositoryProvider = Provider<BookmarksRepository>((ref) {
  return BookmarksRepository(ref.watch(hiveServiceProvider));
});
