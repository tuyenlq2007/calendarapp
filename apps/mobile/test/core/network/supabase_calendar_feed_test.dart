import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/calendar/data/calendar_database.dart';

void main() {
  test('calendar change page parses published and archived feed rows', () {
    final page = CalendarChangePage.fromJsonRows([
      {
        'id': 'published-entry',
        'version': 7,
        'gregorian_date': '2026-08-17',
        'tibetan_date_text': '10th lunar day',
        'title_en': 'Guru Rinpoche day',
        'title_bo': 'དུས་ཆེན།',
        'description_en': 'Practice day',
        'description_bo': 'ཉམས་ལེན།',
        'status': 'published',
      },
      {
        'id': 'archived-entry',
        'version': 8,
        'gregorian_date': '2026-08-18',
        'tibetan_date_text': '',
        'title_en': '',
        'title_bo': '',
        'description_en': '',
        'description_bo': '',
        'status': 'archived',
      },
    ]);

    expect(page.entries, hasLength(2));
    expect(page.entries.first.id, 'published-entry');
    expect(page.entries.first.version, 7);
    expect(
      (page.entries.first as CalendarFeedRow).titleEn,
      'Guru Rinpoche day',
    );
    expect((page.entries.last as CalendarFeedRow).isWithdrawn, isTrue);
  });

  test('published feed rows require bilingual publication fields', () {
    final page = CalendarChangePage.fromJsonRows([
      {
        'id': 'invalid-entry',
        'version': 7,
        'gregorian_date': '2026-08-17',
        'tibetan_date_text': '10th lunar day',
        'title_en': 'Guru Rinpoche day',
        'title_bo': '',
        'description_en': 'Practice day',
        'description_bo': '',
        'status': 'published',
      },
    ]);

    expect(page.entries.single.validate, throwsFormatException);
  });
}
