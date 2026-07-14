import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pyago/core/config/app_config.dart';
import 'package:pyago/core/errors/app_exception.dart';
import 'package:pyago/core/network/connectivity_service.dart';
import 'package:pyago/core/network/interceptors/auth_interceptor.dart';
import 'package:pyago/core/network/interceptors/error_mapper.dart';
import 'package:pyago/core/network/interceptors/logging_interceptor.dart';
import 'package:pyago/core/network/interceptors/retry_interceptor.dart';
import 'package:pyago/core/network/result.dart';
import 'package:pyago/core/storage/secure_token_storage.dart';

/// Thin, typed wrapper around [Dio]. Every real repository implementation
/// (the ones used once [AppConfig.useMockData] is false) goes through
/// this instead of touching Dio directly, so error mapping and the
/// `Result<T>` boundary are enforced in exactly one place.
class ApiClient {
  ApiClient({
    required AppConfig config,
    required SecureTokenStorage tokenStorage,
    required ConnectivityService connectivity,
    Future<void> Function()? onSessionExpired,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: config.baseUrl,
            connectTimeout: const Duration(seconds: 12),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    _dio.interceptors.addAll([
      TimingInterceptor(),
      RetryInterceptor(connectivity: connectivity, dioForRetry: _dio),
      AuthInterceptor(
        tokenStorage: tokenStorage,
        refreshDio: Dio(BaseOptions(baseUrl: config.baseUrl)),
        baseUrl: config.baseUrl,
        onSessionExpired: onSessionExpired,
      ),
      LoggingInterceptor(),
    ]);
  }

  final Dio _dio;

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(dynamic data) parse,
  }) =>
      _wrap(() => _dio.get(path, queryParameters: query), parse);

  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    required T Function(dynamic data) parse,
  }) =>
      _wrap(() => _dio.post(path, data: data), parse);

  Future<Result<T>> put<T>(
    String path, {
    dynamic data,
    required T Function(dynamic data) parse,
  }) =>
      _wrap(() => _dio.put(path, data: data), parse);

  Future<Result<T>> patch<T>(
    String path, {
    dynamic data,
    required T Function(dynamic data) parse,
  }) =>
      _wrap(() => _dio.patch(path, data: data), parse);

  Future<Result<T>> delete<T>(
    String path, {
    dynamic data,
    required T Function(dynamic data) parse,
  }) =>
      _wrap(() => _dio.delete(path, data: data), parse);

  /// Multipart upload with live progress, used by the media pipeline.
  Future<Result<T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? fields,
    required T Function(dynamic data) parse,
    void Function(double progress)? onProgress,
  }) =>
      _wrap(
        () async {
          final formData = FormData.fromMap({
            ...?fields,
            fieldName: await MultipartFile.fromFile(filePath),
          });
          return _dio.post(
            path,
            data: formData,
            onSendProgress: (sent, total) {
              if (total > 0) onProgress?.call(sent / total);
            },
          );
        },
        parse,
      );

  Future<Result<T>> _wrap<T>(
    Future<Response<dynamic>> Function() request,
    T Function(dynamic data) parse,
  ) async {
    try {
      final response = await request();
      return Result.success(parse(response.data));
    } on DioException catch (e) {
      final mapped = e.error is AppException ? e.error as AppException : mapDioError(e);
      return Result.failure(mapped);
    } catch (e) {
      return Result.failure(UnknownAppException(e.toString()));
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final notifier = ref.watch(sessionExpiredNotifierProvider.notifier);
  return ApiClient(
    config: AppConfig.current,
    tokenStorage: ref.watch(secureTokenStorageProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    onSessionExpired: () async => notifier.signal(),
  );
});

// ── Session-expiry signalling ────────────────────────────────────────────────

/// Emitted by [SessionExpiredNotifier] whenever the auth interceptor
/// force-logs out due to an unrecoverable token refresh failure.
///
/// `AuthController` listens to [sessionExpiredNotifierProvider] via
/// `ref.listen` and clears its state accordingly. Using a typed
/// [AsyncNotifier] instead of the former `StateProvider<int>` counter
/// means the signal is self-documenting and can carry a payload in the
/// future (e.g. a reason code) without a breaking change.
class SessionExpiredNotifier extends AsyncNotifier<void> {
  late final StreamController<void> _controller;

  @override
  Future<void> build() async {
    _controller = StreamController<void>.broadcast();
    ref.onDispose(_controller.close);
  }

  /// Fire the session-expired signal. Called exclusively by [ApiClient]'s
  /// `onSessionExpired` callback; never call this from UI code.
  void signal() {
    if (!_controller.isClosed) _controller.add(null);
  }

  /// Stream that [AuthController] subscribes to.
  Stream<void> get events => _controller.stream;
}

final sessionExpiredNotifierProvider =
    AsyncNotifierProvider<SessionExpiredNotifier, void>(
  SessionExpiredNotifier.new,
);
