import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../core/storage/hive_service.dart';
import '../../domain/models/draft_model.dart';

/// Drafts live entirely in Hive — there is no network dependency to
/// read, write, or delete a draft, so the Create screen and the Drafts
/// list both work with zero connectivity by construction.
class DraftsRepository {
  DraftsRepository(this._hive);

  final HiveService _hive;
  Box<String> get _box => _hive.box(HiveService.draftsBox);

  List<DraftModel> listAll() {
    final drafts = _box.values.map((v) => DraftModel.fromJson(jsonDecode(v) as Map<String, dynamic>)).toList();
    drafts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return drafts;
  }

  DraftModel? get(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    return DraftModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(DraftModel draft) => _box.put(draft.id, jsonEncode(draft.toJson()));

  Future<void> delete(String id) => _box.delete(id);
}

final draftsRepositoryProvider = Provider<DraftsRepository>((ref) {
  return DraftsRepository(ref.watch(hiveServiceProvider));
});
