import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Structured, debug-only logging. Compiled out of release builds via
/// [kDebugMode] so nothing sensitive (tokens, payloads) ever hits a
/// release log.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[pyago:http] → ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[pyago:http] ← ${response.statusCode} ${response.requestOptions.method} '
        '${response.requestOptions.uri} (${response.requestOptions.extra['pyago_elapsed_ms'] ?? '?'}ms)',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[pyago:http] ✕ ${err.requestOptions.method} ${err.requestOptions.uri} — '
        '${err.type} ${err.response?.statusCode ?? ''} ${err.message ?? ''}',
      );
    }
    handler.next(err);
  }
}

/// Stamps a start time so [LoggingInterceptor] can report elapsed time.
class TimingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['pyago_start_time'] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final start = response.requestOptions.extra['pyago_start_time'] as int?;
    if (start != null) {
      response.requestOptions.extra['pyago_elapsed_ms'] =
          DateTime.now().millisecondsSinceEpoch - start;
    }
    handler.next(response);
  }
}
