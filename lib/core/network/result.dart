import '../errors/app_exception.dart';

/// Typed success/failure wrapper. Repositories that talk to the network
/// layer prefer returning `Result<T>` over throwing so callers are forced
/// to handle failure explicitly; use [asFuture] at the boundary (e.g. in
/// a notifier's try/catch) if a throwing API is more convenient there.
sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(AppException error) = Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get valueOrNull => switch (this) {
        Success<T>(:final value) => value,
        Failure<T>() => null,
      };

  AppException? get errorOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(:final error) => error,
      };

  R when<R>({
    required R Function(T value) success,
    required R Function(AppException error) failure,
  }) {
    return switch (this) {
      Success<T>(:final value) => success(value),
      Failure<T>(:final error) => failure(error),
    };
  }

  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success<T>(:final value) => Result.success(transform(value)),
      Failure<T>(:final error) => Result.failure(error),
    };
  }

  /// Escape hatch for call sites (older notifiers, tests) that prefer
  /// try/catch over pattern matching.
  T asValue() => switch (this) {
        Success<T>(:final value) => value,
        Failure<T>(:final error) => throw error,
      };
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);
  final AppException error;
}
