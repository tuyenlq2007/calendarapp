import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/network/supabase_calendar_feed.dart';
import 'package:mobile/features/calendar/data/calendar_database.dart';

void main() {
  test('calendar change page parses Tibetan date detail metadata fields', () {
    final page = CalendarChangePage.fromJsonRows([
      {
        'id': 'metadata-entry',
        'version': 9,
        'gregorian_date': '2026-08-24',
        'tibetan_date_text': '10th lunar day',
        'title_en': 'Guru Rinpoche day',
        'title_bo': 'Published Tibetan title',
        'description_en': 'Practice day',
        'description_bo': '',
        'month_number_text': '7',
        'month_element_animal_en': 'Fire Dog',
        'year_number_text': '2153',
        'year_element_animal_en': 'Fire Horse',
        'status': 'published',
      },
    ]);

    final row = page.entries.single as CalendarFeedRow;

    expect(row.monthNumberText, '7');
    expect(row.monthElementAnimalEn, 'Fire Dog');
    expect(row.yearNumberText, '2153');
    expect(row.yearElementAnimalEn, 'Fire Horse');
  });

  test('calendar change page parses Tibetan day detail metadata fields', () {
    final page = CalendarChangePage.fromJsonRows([
      {
        'id': 'day-metadata-entry',
        'version': 9,
        'gregorian_date': '2026-08-24',
        'tibetan_date_text': '10th lunar day',
        'title_en': 'Guru Rinpoche day',
        'title_bo': 'Published Tibetan title',
        'description_en': 'Practice day',
        'description_bo': '',
        'day_number_text': '10',
        'day_element_animal_en': 'Earth Dragon',
        'status': 'published',
      },
    ]);

    final row = page.entries.single as CalendarFeedRow;

    expect(row.dayNumberText, '10');
    expect(row.dayElementAnimalEn, 'Earth Dragon');
  });

  test('calendar change page parses practice day fields', () {
    final page = CalendarChangePage.fromJsonRows([
      {
        'id': 'practice-day-entry',
        'version': 9,
        'gregorian_date': '2027-01-02',
        'tibetan_date_text': '10th lunar day',
        'title_en': 'Normal calendar title',
        'title_bo': 'Published Tibetan title',
        'description_en': 'Normal calendar description',
        'description_bo': '',
        'is_practice_day': true,
        'practice_day_title': 'Green Tara Practice',
        'practice_day_description': 'Practice of Green Tara.',
        'practice_day_image_url': 'https://azfsdtbmxzqomwsepjfx.supabase.co/storage/v1/object/public/images/Tara.JPG',
        'status': 'published',
      },
    ]);

    final row = page.entries.single as CalendarFeedRow;

    expect(row.isPracticeDay, isTrue);
    expect(row.practiceDayTitle, 'Green Tara Practice');
    expect(row.practiceDayDescription, 'Practice of Green Tara.');
    expect(
      row.practiceDayImageUrl,
      'https://azfsdtbmxzqomwsepjfx.supabase.co/storage/v1/object/public/images/Tara.JPG',
    );
  });

  test('calendar change page defaults missing practice day fields safely', () {
    final page = CalendarChangePage.fromJsonRows([
      {
        'id': 'normal-entry',
        'version': 9,
        'gregorian_date': '2027-01-02',
        'tibetan_date_text': '10th lunar day',
        'title_en': 'Normal calendar title',
        'title_bo': 'Published Tibetan title',
        'description_en': 'Normal calendar description',
        'description_bo': '',
        'status': 'published',
      },
    ]);

    final row = page.entries.single as CalendarFeedRow;

    expect(row.isPracticeDay, isFalse);
    expect(row.practiceDayTitle, isNull);
    expect(row.practiceDayDescription, isNull);
    expect(row.practiceDayImageUrl, isNull);
  });

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
        'element_pair_en': 'Water - Water',
        'element_combination_title_en': 'Auspicious Element Combination',
        'element_description_en':
            "This elemental combination strengthens and extends one's life.",
        'description_bo': 'ཉམས་ལེན།',
        'element_tibetan_line':
            'ས་ཆུ་འཕྲད་པ་བདེ་སྐྱིད། ས་ཆུ་སྦྱོར་བས་དགེ་བ་འཕེལ།',
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
        'element_pair_en': '',
        'element_combination_title_en': '',
        'element_description_en': '',
        'description_bo': '',
        'element_tibetan_line': '',
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
    expect(
      (page.entries.first as CalendarFeedRow).elementPairEn,
      'Water - Water',
    );
    expect(
      (page.entries.first as CalendarFeedRow).elementCombinationTitleEn,
      'Auspicious Element Combination',
    );
    expect(
      (page.entries.first as CalendarFeedRow).elementDescriptionEn,
      "This elemental combination strengthens and extends one's life.",
    );
    expect(
      (page.entries.first as CalendarFeedRow).elementTibetanLine,
      'ས་ཆུ་འཕྲད་པ་བདེ་སྐྱིད། ས་ཆུ་སྦྱོར་བས་དགེ་བ་འཕེལ།',
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

  test('feed rows require positive versions', () {
    final page = CalendarChangePage.fromJsonRows([
      {
        'id': 'invalid-version',
        'version': 0,
        'gregorian_date': '2026-08-17',
        'tibetan_date_text': '10th lunar day',
        'title_en': 'Guru Rinpoche day',
        'title_bo': 'Published Tibetan title',
        'description_en': 'Practice day',
        'description_bo': '',
        'status': 'published',
      },
    ]);

    expect(page.entries.single.validate, throwsFormatException);
  });

  test('feed rows reject fractional versions', () {
    expect(
      () => CalendarChangePage.fromJsonRows([
        {
          'id': 'fractional-version',
          'version': 1.9,
          'gregorian_date': '2026-08-17',
          'tibetan_date_text': '10th lunar day',
          'title_en': 'Guru Rinpoche day',
          'title_bo': 'Published Tibetan title',
          'description_en': 'Practice day',
          'description_bo': '',
          'status': 'published',
        },
      ]),
      throwsFormatException,
    );
  });

  test('supabase feed passes cursor version into row loader', () async {
    int? afterVersion;
    final feed = SupabaseCalendarFeed((version) async {
      afterVersion = version;
      return [
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
      ];
    });

    final page = await feed.changesAfter(4);

    expect(afterVersion, 4);
    expect(page.entries.single.id, 'published-entry');
  });

  test('supabase feed wraps rpc failures as network exceptions', () async {
    final feed = SupabaseCalendarFeed((_) async => throw StateError('offline'));

    await expectLater(feed.changesAfter(4), throwsA(isA<NetworkException>()));
  });

  test('supabase feed retries transient rpc failures', () async {
    var attempts = 0;
    final feed = SupabaseCalendarFeed((_) async {
      attempts++;
      if (attempts == 1) {
        throw StateError('temporary dns failure');
      }
      return [
        {
          'id': 'published-entry',
          'version': 7,
          'gregorian_date': '2026-08-17',
          'tibetan_date_text': '10th lunar day',
          'title_en': 'Guru Rinpoche day',
          'title_bo': 'Published Tibetan title',
          'description_en': 'Practice day',
          'description_bo': '',
          'status': 'published',
        },
      ];
    }, retryDelay: Duration.zero);

    final page = await feed.changesAfter(4);

    expect(attempts, 2);
    expect(page.entries.single.id, 'published-entry');
  });

  test('supabase feed tolerates several temporary dns failures', () async {
    var attempts = 0;
    final feed = SupabaseCalendarFeed((_) async {
      attempts++;
      if (attempts < 5) {
        throw StateError('temporary dns failure');
      }
      return [
        {
          'id': 'published-entry',
          'version': 7,
          'gregorian_date': '2026-08-17',
          'tibetan_date_text': '10th lunar day',
          'title_en': 'Guru Rinpoche day',
          'title_bo': 'Published Tibetan title',
          'description_en': 'Practice day',
          'description_bo': '',
          'status': 'published',
        },
      ];
    }, retryDelay: Duration.zero);

    final page = await feed.changesAfter(4);

    expect(attempts, 5);
    expect(page.entries.single.id, 'published-entry');
  });

  test('supabase feed rejects non-object rows', () async {
    final feed = SupabaseCalendarFeed((_) async => ['bad row']);

    await expectLater(feed.changesAfter(4), throwsFormatException);
  });
}
