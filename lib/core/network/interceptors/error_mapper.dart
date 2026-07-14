import 'package:dio/dio.dart';
import '../../errors/app_exception.dart';

/// Central place that turns transport-level errors (Dio, sockets, JSON
/// parsing) into the [AppException] hierarchy the rest of the app
/// understands. Repositories should never see a raw [DioException].
AppException mapDioError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const TimeoutException();
    case DioExceptionType.connectionError:
      return const NetworkException();
    case DioExceptionType.badCertificate:
      return const NetworkException('A secure connection to Pyago could not be verified.');
    case DioExceptionType.cancel:
      return const NetworkException('Request cancelled.');
    case DioExceptionType.badResponse:
      return _mapStatusCode(error.response?.statusCode, error.response?.data);
    case DioExceptionType.unknown:
      return const UnknownAppException();
  }
}

AppException _mapStatusCode(int? status, dynamic data) {
  final serverMessage = _extractMessage(data);
  switch (status) {
    case 400:
    case 422:
      return ValidationException(serverMessage ?? 'That request looks invalid.');
    case 401:
      return const SessionExpiredException();
    case 403:
      return AuthException(serverMessage ?? "You don't have permission to do that.");
    case 404:
      return NotFoundException(serverMessage ?? 'That could not be found.');
    case 429:
      return const RateLimitedException();
    default:
      if (status != null && status >= 500) {
        return const ServerException();
      }
      return UnknownAppException(serverMessage ?? 'Something unexpected happened.');
  }
}

String? _extractMessage(dynamic data) {
  if (data is Map && data['message'] is String) return data['message'] as String;
  if (data is Map && data['error'] is String) return data['error'] as String;
  return null;
}
