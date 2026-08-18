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
