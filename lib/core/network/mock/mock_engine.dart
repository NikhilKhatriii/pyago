import 'dart:math';
import '../../config/app_config.dart';
import '../../errors/app_exception.dart';
import '../pagination.dart';

/// Shared behavior for every `Mock*Repository`, so the "fake backend"
/// behaves consistently like a real one would: network-ish latency,
/// cursor pagination, and an injected transient-failure rate. Because
/// every mock repository routes through this instead of ad hoc
/// `Future.delayed` calls, swapping a mock repository for a real
/// `Http*Repository` later changes nothing about how the UI/providers
/// perceive latency, pagination, or errors.
class MockEngine {
  MockEngine({AppConfig? config, Random? random})
      : _config = config ?? AppConfig.current,
        _random = random ?? Random();

  final AppConfig _config;
  final Random _random;

  /// Simulates realistic, slightly-variable network latency.
  Future<void> latency({double multiplier = 1.0}) {
    final base = _config.simulatedLatencyMs * multiplier;
    final jitter = _random.nextInt((base * 0.6).clamp(1, 100000).toInt());
    return Future.delayed(Duration(milliseconds: (base * 0.7 + jitter).round()));
  }

  /// Call after [latency] on any mutating or list call to occasionally
  /// throw a transient error, exercising the same retry/error UI a real,
  /// occasionally-flaky backend would.
  void maybeFail({AppException Function()? error}) {
    if (_random.nextDouble() < _config.simulatedFailureRate) {
      throw error?.call() ?? const ServerException();
    }
  }

  /// Cursor-paginates an in-memory list the same way a real REST/GraphQL
  /// list endpoint would: opaque cursor = stringified offset, small
  /// deliberate page sizes (Pyago avoids infinite/addictive scroll).
  Page<T> paginate<T>(List<T> all, {String? cursor, int pageSize = 8}) {
    final offset = cursor == null ? 0 : int.tryParse(cursor) ?? 0;
    if (offset >= all.length) {
      return Page<T>(items: const [], nextCursor: null, hasMore: false);
    }
    final end = (offset + pageSize).clamp(0, all.length);
    final slice = all.sublist(offset, end);
    final hasMore = end < all.length;
    return Page<T>(
      items: slice,
      nextCursor: hasMore ? end.toString() : null,
      hasMore: hasMore,
    );
  }
}
