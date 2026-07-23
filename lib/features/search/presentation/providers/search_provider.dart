import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/local_storage_service.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesController, List<String>>((ref) {
  return RecentSearchesController(ref.watch(localStorageProvider));
});

class RecentSearchesController extends StateNotifier<List<String>> {
  RecentSearchesController(this._storage)
      : super(_storage.getStringList(StorageKeys.recentSearches) ?? const []);

  final LocalStorageService _storage;

  Future<void> add(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final next = <String>[trimmed, ...state.where((q) => q != trimmed)].take(10).toList();
    state = next;
    await _storage.setStringList(StorageKeys.recentSearches, next);
  }

  Future<void> clear() async {
    state = [];
    await _storage.setStringList(StorageKeys.recentSearches, []);
  }
}

const searchSuggestions = [
  'poetry about grief',
  'morning pages',
  'short fiction',
  'travel journals',
  'voice notes',
  'community: quiet writers',
];
