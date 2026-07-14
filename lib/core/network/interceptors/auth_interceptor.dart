import 'package:dio/dio.dart';
import '../../storage/secure_token_storage.dart';
import '../../errors/app_exception.dart';

/// Attaches the bearer token to every request, and on a 401 transparently
/// refreshes the token and retries the original request exactly once.
/// If the refresh itself fails, it clears stored tokens and calls
/// [onSessionExpired] so the app can force a logout — the caller still
/// receives a [SessionExpiredException] either way.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenStorage,
    required this.refreshDio,
    required this.baseUrl,
    this.onSessionExpired,
  });

  final SecureTokenStorage tokenStorage;

  /// A separate, interceptor-free [Dio] instance used only for the
  /// refresh call, to avoid recursive interception.
  final Dio refreshDio;
  final String baseUrl;
  final Future<void> Function()? onSessionExpired;

  bool _isRefreshing = false;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await tokenStorage.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['pyago_retried_after_refresh'] == true;

    if (!isUnauthorized || alreadyRetried) {
      handler.next(err);
      return;
    }

    // Only one refresh in flight at a time; concurrent 401s all wait on it.
    if (_isRefreshing) {
      handler.next(err);
      return;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await tokenStorage.refreshToken;
      if (refreshToken == null) {
        await _forceLogout();
        handler.reject(_sessionExpiredError(err));
        return;
      }

      final response = await refreshDio.post(
        '$baseUrl/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final newAccessToken = response.data['access_token'] as String?;
      if (newAccessToken == null) {
        await _forceLogout();
        handler.reject(_sessionExpiredError(err));
        return;
      }

      await tokenStorage.saveAccessToken(newAccessToken);

      final retryOptions = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newAccessToken'
        ..extra['pyago_retried_after_refresh'] = true;

      final retryResponse = await refreshDio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      await _forceLogout();
      handler.reject(_sessionExpiredError(err));
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _forceLogout() async {
    await tokenStorage.clear();
    await onSessionExpired?.call();
  }

  DioException _sessionExpiredError(DioException original) => DioException(
        requestOptions: original.requestOptions,
        error: const SessionExpiredException(),
        type: DioExceptionType.badResponse,
        response: original.response,
      );
}
