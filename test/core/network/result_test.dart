import 'package:flutter_test/flutter_test.dart';
import 'package:pyago/core/errors/app_exception.dart';
import 'package:pyago/core/network/result.dart';

void main() {
  group('Result', () {
    test('Success carries its value and reports isSuccess', () {
      const result = Result<int>.success(42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.valueOrNull, 42);
      expect(result.errorOrNull, isNull);
    });

    test('Failure carries its error and reports isFailure', () {
      const error = NetworkException('no connection');
      const result = Result<int>.failure(error);
      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.errorOrNull, error);
    });

    test('when() dispatches to the matching branch', () {
      const success = Result<int>.success(1);
      const failure = Result<int>.failure(NetworkException());

      expect(success.when(success: (v) => 'ok:$v', failure: (_) => 'fail'), 'ok:1');
      expect(failure.when(success: (v) => 'ok:$v', failure: (_) => 'fail'), 'fail');
    });

    test('map() transforms a success value and leaves a failure untouched', () {
      const success = Result<int>.success(2);
      const failure = Result<int>.failure(NetworkException('x'));

      expect(success.map((v) => v * 10).valueOrNull, 20);
      expect(failure.map((v) => v * 10).errorOrNull, isA<NetworkException>());
    });

    test('asValue() returns the value on success and throws on failure', () {
      const success = Result<int>.success(7);
      const failure = Result<int>.failure(NetworkException());

      expect(success.asValue(), 7);
      expect(() => failure.asValue(), throwsA(isA<NetworkException>()));
    });
  });
}
