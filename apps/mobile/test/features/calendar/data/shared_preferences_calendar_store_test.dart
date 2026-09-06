import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/calendar/data/calendar_database.dart';
import 'package:mobile/features/calendar/data/shared_preferences_calendar_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('stores published rows and withdraws archived rows', () async {
    final store = SharedPreferencesCalendarStore(SharedPreferencesAsync());

    await store.upsertOrWithdraw(row('entry', status: 'published'));
    expect((await store.publishedEntries()).map((entry) => entry.id), [
      'entry',
    ]);

    await store.upsertOrWithdraw(row('entry', status: 'archived'));
    expect(await store.publishedEntries(), isEmpty);
  });

  test(
    'transaction restores cached entries and version after failure',
    () async {
      final store = SharedPreferencesCalendarStore(SharedPreferencesAsync());

      await store.upsertOrWithdraw(row('entry', status: 'published'));
      await store.setCurrentVersion(3);

      await expectLater(
        store.transaction(() async {
          await store.upsertOrWithdraw(row('entry', status: 'archived'));
          await store.setCurrentVersion(4);
          throw const FormatException('rollback');
        }),
        throwsFormatException,
      );

      expect((await store.publishedEntries()).map((entry) => entry.id), [
        'entry',
      ]);
      expect(await store.currentVersion(), 3);
    },
  );

  test('persists the last successful sync timestamp', () async {
    final preferences = SharedPreferencesAsync();
    final store = SharedPreferencesCalendarStore(preferences);
    final lastSyncedAt = DateTime.utc(2026, 8, 17, 9, 30);

    await store.setLastSyncedAt(lastSyncedAt);

    final restartedStore = SharedPreferencesCalendarStore(preferences);
    expect(await restartedStore.lastSyncedAt(), lastSyncedAt);
  });

  test('persists the element Tibetan line for published rows', () async {
    final preferences = SharedPreferencesAsync();
    final store = SharedPreferencesCalendarStore(preferences);

    await store.upsertOrWithdraw(
      row('entry', status: 'published').copyWith(
        elementTibetanLine: 'ས་ཆུ་འཕྲད་པ་བདེ་སྐྱིད། ས་ཆུ་སྦྱོར་བས་དགེ་བ་འཕེལ།',
      ),
    );

    final restartedStore = SharedPreferencesCalendarStore(preferences);

    expect(
      (await restartedStore.publishedEntries()).single.elementTibetanLine,
      'ས་ཆུ་འཕྲད་པ་བདེ་སྐྱིད། ས་ཆུ་སྦྱོར་བས་དགེ་བ་འཕེལ།',
    );
  });
  test('persists the English element fields for published rows', () async {
    final preferences = SharedPreferencesAsync();
    final store = SharedPreferencesCalendarStore(preferences);

    await store.upsertOrWithdraw(
      row('entry', status: 'published').copyWith(
        elementPairEn: 'Water - Water',
        elementCombinationTitleEn: 'Auspicious Element Combination',
        elementDescriptionEn:
            "This elemental combination strengthens and extends one's life.",
      ),
    );

    final restartedStore = SharedPreferencesCalendarStore(preferences);
    final storedRow = (await restartedStore.publishedEntries()).single;

    expect(storedRow.elementPairEn, 'Water - Water');
    expect(
      storedRow.elementCombinationTitleEn,
      'Auspicious Element Combination',
    );
    expect(
      storedRow.elementDescriptionEn,
      "This elemental combination strengthens and extends one's life.",
    );
  });

  test('persists Tibetan date detail metadata for published rows', () async {
    final preferences = SharedPreferencesAsync();
    final store = SharedPreferencesCalendarStore(preferences);

    await store.upsertOrWithdraw(
      row('entry', status: 'published').copyWith(
        monthNumberText: '7',
        monthElementAnimalEn: 'Fire Dog',
        yearNumberText: '2153',
        yearElementAnimalEn: 'Fire Horse',
      ),
    );

    final restartedStore = SharedPreferencesCalendarStore(preferences);
    final storedRow = (await restartedStore.publishedEntries()).single;

    expect(storedRow.monthNumberText, '7');
    expect(storedRow.monthElementAnimalEn, 'Fire Dog');
    expect(storedRow.yearNumberText, '2153');
    expect(storedRow.yearElementAnimalEn, 'Fire Horse');
  });

  test('persists Tibetan day detail metadata for published rows', () async {
    final preferences = SharedPreferencesAsync();
    final store = SharedPreferencesCalendarStore(preferences);

    await store.upsertOrWithdraw(
      CalendarFeedRow.fromJson({
        'id': 'entry',
        'version': 1,
        'gregorian_date': '2026-08-17',
        'tibetan_date_text': '10th lunar day',
        'title_en': 'Guru Rinpoche day',
        'title_bo': 'Published Tibetan title',
        'description_en': '',
        'description_bo': '',
        'day_number_text': '10',
        'day_element_animal_en': 'Earth Dragon',
        'status': 'published',
      }),
    );

    final restartedStore = SharedPreferencesCalendarStore(preferences);
    final storedRow = (await restartedStore.publishedEntries()).single;

    expect(storedRow.dayNumberText, '10');
    expect(storedRow.dayElementAnimalEn, 'Earth Dragon');
  });

  test('persists practice day fields for published rows', () async {
    final preferences = SharedPreferencesAsync();
    final store = SharedPreferencesCalendarStore(preferences);

    await store.upsertOrWithdraw(
      CalendarFeedRow.fromJson({
        'id': 'entry',
        'version': 1,
        'gregorian_date': '2027-01-02',
        'tibetan_date_text': '10th lunar day',
        'title_en': 'Normal calendar title',
        'title_bo': 'Published Tibetan title',
        'description_en': '',
        'description_bo': '',
        'is_practice_day': true,
        'practice_day_title': 'Green Tara Practice',
        'practice_day_description': 'Practice of Green Tara.',
        'practice_day_image_url': 'https://azfsdtbmxzqomwsepjfx.supabase.co/storage/v1/object/public/images/Tara.JPG',
        'status': 'published',
      }),
    );

    final restartedStore = SharedPreferencesCalendarStore(preferences);
    final storedRow = (await restartedStore.publishedEntries()).single;

    expect(storedRow.isPracticeDay, isTrue);
    expect(storedRow.practiceDayTitle, 'Green Tara Practice');
    expect(storedRow.practiceDayDescription, 'Practice of Green Tara.');
    expect(
      storedRow.practiceDayImageUrl,
      'https://azfsdtbmxzqomwsepjfx.supabase.co/storage/v1/object/public/images/Tara.JPG',
    );
  });
}

CalendarFeedRow row(String id, {required String status}) {
  return CalendarFeedRow(
    id: id,
    version: 1,
    gregorianDate: DateTime(2026, 8, 17),
    tibetanDateText: status == 'published' ? '10th lunar day' : '',
    titleEn: status == 'published' ? 'Guru Rinpoche day' : '',
    titleBo: status == 'published' ? 'དུས་ཆེན།' : '',
    descriptionEn: '',
    descriptionBo: '',
    status: status,
  );
}
