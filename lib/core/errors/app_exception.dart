/// Base class for all handled exceptions in Pyago. Every repository and
/// service throws one of these subtypes rather than a raw exception, so
/// the presentation layer can always show a meaningful message.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Unable to reach Pyago. Check your connection.']);
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'That could not be found.']);
}

class StorageException extends AppException {
  const StorageException([super.message = 'Could not save your data locally.']);
}

class UnknownAppException extends AppException {
  const UnknownAppException([super.message = 'Something unexpected happened.']);
}

/// No connectivity at all — distinct from [NetworkException] (server
/// unreachable/timeout) so the UI can short-circuit to cache silently
/// instead of showing an error.
class OfflineException extends AppException {
  const OfflineException([super.message = "You're offline. Showing saved content."]);
}

class TimeoutException extends AppException {
  const TimeoutException([super.message = 'That took too long. Please try again.']);
}

/// 5xx-class or malformed-response errors from the backend.
class ServerException extends AppException {
  const ServerException([super.message = 'Pyago is having trouble right now. Please try again.']);
}

/// The access token is invalid/expired and refresh also failed —
/// the auth interceptor throws this to force a logout.
class SessionExpiredException extends AppException {
  const SessionExpiredException([super.message = 'Your session has expired. Please sign in again.']);
}

class RateLimitedException extends AppException {
  const RateLimitedException([super.message = "You're doing that a bit too much. Try again shortly."]);
}

/// A queued offline action (e.g. publish) couldn't be replayed even
/// after connectivity returned.
class SyncFailedException extends AppException {
  const SyncFailedException([super.message = 'Some changes could not be synced.']);
}
