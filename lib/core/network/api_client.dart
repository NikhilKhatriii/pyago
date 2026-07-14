import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../errors/app_exception.dart';
import '../storage/secure_token_storage.dart';
import 'connectivity_service.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_mapper.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'result.dart';

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
    Future<Response> Function() request,
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
  return ApiClient(
    config: AppConfig.current,
    tokenStorage: ref.watch(secureTokenStorageProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    onSessionExpired: () async {
      // Reaches into auth at call time to avoid a circular provider
      // dependency; auth_provider.dart listens on this via
      // `sessionExpiredNotifierProvider` (see auth_provider.dart).
      ref.read(sessionExpiredSignalProvider.notifier).state++;
    },
  );
});

/// Bumped whenever the auth interceptor force-logs-out due to an
/// unrecoverable session expiry. `AuthController` listens to this and
/// clears its state — kept as a tiny counter provider (rather than a
/// direct method call) specifically to avoid `api_client.dart` and
/// `auth_provider.dart` importing each other.
final sessionExpiredSignalProvider = StateProvider<int>((ref) => 0);
