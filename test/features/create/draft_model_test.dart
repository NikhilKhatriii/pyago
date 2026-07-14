import 'package:flutter_test/flutter_test.dart';
import 'package:pyago/features/create/domain/models/draft_model.dart';
import 'package:pyago/features/home/domain/models/post_model.dart';

void main() {
  DraftModel makeDraft({String title = '', String body = ''}) {
    final now = DateTime(2026, 1, 1);
    return DraftModel(id: 'd1', title: title, body: body, createdAt: now, updatedAt: now);
  }

  group('DraftModel', () {
    test('isEmpty is true only when title, body, and attachments are all empty', () {
      expect(makeDraft().isEmpty, isTrue);
      expect(makeDraft(title: 'Hello').isEmpty, isFalse);
      expect(makeDraft(body: 'Some words').isEmpty, isFalse);
    });

    test('wordCount counts whitespace-separated words', () {
      expect(makeDraft(body: 'one two three').wordCount, 3);
      expect(makeDraft(body: '   ').wordCount, 0);
      expect(makeDraft().wordCount, 0);
    });

    test('readingTimeMinutes is at least 1 for any non-empty body', () {
      expect(makeDraft(body: 'a few words').readingTimeMinutes, 1);
    });

    test('readingTimeMinutes scales at roughly 200 words per minute', () {
      final longBody = List.filled(450, 'word').join(' ');
      expect(makeDraft(body: longBody).readingTimeMinutes, 3);
    });

    test('round-trips through JSON without losing fields', () {
      final draft = makeDraft(title: 'T', body: 'B').copyWith(type: PostType.poetry);
      final restored = DraftModel.fromJson(draft.toJson());

      expect(restored.id, draft.id);
      expect(restored.title, draft.title);
      expect(restored.body, draft.body);
      expect(restored.type, draft.type);
    });
  });
}
