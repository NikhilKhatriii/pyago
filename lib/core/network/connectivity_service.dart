import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Thin wrapper over `connectivity_plus` so the rest of the app depends on
/// an abstraction (easy to fake in tests, easy to swap implementations).
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity}) : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  Stream<bool> get onStatusChange =>
      _connectivity.onConnectivityChanged.map(_hasConnection).distinct();

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) => ConnectivityService());

/// Live online/offline status as a Riverpod stream, used to drive the
/// "offline — showing saved content" / "will publish when back online"
/// banners across the app. Emits an initial value immediately so widgets
/// don't flash an "unknown" state on first build.
final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final service = ref.watch(connectivityServiceProvider);
  yield await service.isOnline;
  yield* service.onStatusChange;
});
