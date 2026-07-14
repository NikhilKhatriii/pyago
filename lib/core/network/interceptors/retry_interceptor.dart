import 'dart:async';
import 'package:dio/dio.dart';
import '../connectivity_service.dart';
import '../../errors/app_exception.dart';

/// Retries idempotent GETs with exponential backoff on transient
/// failures (timeouts, connection errors, 5xx), and short-circuits
/// immediately with [OfflineException] when there's no connectivity at
/// all — so repositories can catch that specific type and fall back to
/// cache without it looking like a "real" failure.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.connectivity,
    required this.dioForRetry,
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 400),
  });

  final ConnectivityService connectivity;
  final int maxRetries;
  final Duration baseDelay;

  /// The same [Dio] instance this interceptor is attached to. Retries
  /// are re-issued through it (not a throwaway client) so base options,
  /// other interceptors, and cookies/headers stay consistent.
  final Dio dioForRetry;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (await connectivity.isOnline) {
      handler.next(options);
      return;
    }
    handler.reject(
      DioException(
        requestOptions: options,
        error: const OfflineException(),
        type: DioExceptionType.connectionError,
      ),
    );
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final isIdempotentGet = err.requestOptions.method.toUpperCase() == 'GET';
    final isTransient = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);

    final attempt = (err.requestOptions.extra['pyago_retry_attempt'] as int?) ?? 0;

    if (!isIdempotentGet || !isTransient || attempt >= maxRetries) {
      handler.next(err);
      return;
    }

    final delay = baseDelay * (1 << attempt); // exponential backoff
    await Future.delayed(delay);

    try {
      final retryOptions = err.requestOptions..extra['pyago_retry_attempt'] = attempt + 1;
      final response = await dioForRetry.fetch(retryOptions);
      handler.resolve(response);
    } catch (_) {
      handler.next(err);
    }
  }
}
