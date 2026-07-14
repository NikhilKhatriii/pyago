import 'package:flutter_test/flutter_test.dart';
import 'package:pyago/core/config/app_config.dart';
import 'package:pyago/core/network/mock/mock_engine.dart';

void main() {
  group('MockEngine.paginate', () {
    test('returns first page with correct cursor and hasMore', () {
      final engine = MockEngine();
      final items = List.generate(20, (i) => i);

      final page = engine.paginate(items, pageSize: 6);

      expect(page.items, [0, 1, 2, 3, 4, 5]);
      expect(page.hasMore, isTrue);
      expect(page.nextCursor, '6');
    });

    test('walks through every page without dropping or repeating items', () {
      final engine = MockEngine();
      final items = List.generate(20, (i) => i);

      final seen = <int>[];
      String? cursor;
      do {
        final page = engine.paginate(items, cursor: cursor, pageSize: 6);
        seen.addAll(page.items);
        cursor = page.nextCursor;
        if (!page.hasMore) break;
      } while (true);

      expect(seen, items);
    });

    test('reports hasMore=false and null cursor on the last page', () {
      final engine = MockEngine();
      final items = List.generate(10, (i) => i);

      final page = engine.paginate(items, cursor: '6', pageSize: 6);

      expect(page.items, [6, 7, 8, 9]);
      expect(page.hasMore, isFalse);
      expect(page.nextCursor, isNull);
    });

    test('an out-of-range cursor returns an empty, exhausted page', () {
      final engine = MockEngine();
      final items = List.generate(5, (i) => i);

      final page = engine.paginate(items, cursor: '999', pageSize: 6);

      expect(page.items, isEmpty);
      expect(page.hasMore, isFalse);
    });
  });

  group('MockEngine.maybeFail', () {
    test('never throws when the configured failure rate is zero', () {
      final engine = MockEngine(
        config: const AppConfig.forTest(simulatedFailureRate: 0, simulatedLatencyMs: 0),
      );
      for (var i = 0; i < 50; i++) {
        expect(() => engine.maybeFail(), returnsNormally);
      }
    });

    test('always throws when the configured failure rate is one', () {
      final engine = MockEngine(
        config: const AppConfig.forTest(simulatedFailureRate: 1, simulatedLatencyMs: 0),
      );
      expect(() => engine.maybeFail(), throwsA(isA<Exception>()));
    });
  });
}
