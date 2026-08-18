import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/network/supabase_calendar_feed.dart';
import 'package:mobile/features/calendar/data/calendar_database.dart';
import 'package:mobile/features/calendar/data/calendar_sync_service.dart';

void main() {
  test('published entry syncs and remains after network failure', () async {
    final store = InMemoryCalendarStore();
    final feed = ToggleCalendarFeed();
    final service = CalendarSyncService(feed, store);

    await service.sync();

    expect(store.findTitle('Guru Rinpoche day'), isNotNull);
    expect(await store.currentVersion(), 1);

    feed.goOffline();

    await expectLater(service.sync(), throwsA(isA<NetworkException>()));
    expect(store.findTitle('Guru Rinpoche day'), isNotNull);
    expect(await store.currentVersion(), 1);
  });
}

class ToggleCalendarFeed implements CalendarFeed {
  bool _isOffline = false;

  void goOffline() {
    _isOffline = true;
  }

  @override
  Future<CalendarChangePage> changesAfter(int version) async {
    if (_isOffline) {
      throw const NetworkException('offline');
    }

    return CalendarChangePage.fromJsonRows([
      {
        'id': 'guru-rinpoche-day',
        'version': 1,
        'gregorian_date': '2026-08-17',
        'tibetan_date_text': '10th lunar day',
        'title_en': 'Guru Rinpoche day',
        'title_bo': 'དུས་ཆེན།',
        'description_en': 'Practice day',
        'description_bo': 'ཉམས་ལེན།',
        'status': 'published',
      },
    ]);
  }
}

class InMemoryCalendarStore implements CalendarStore {
  int _version = 0;
  final Map<String, CalendarFeedRow> _entries = {};

  CalendarFeedRow? findTitle(String title) {
    for (final entry in _entries.values) {
      if (entry.titleEn == title) return entry;
    }
    return null;
  }

  @override
  Future<int> currentVersion() async => _version;

  @override
  Future<void> setCurrentVersion(int version) async {
    _version = version;
  }

  @override
  Future<void> transaction(Future<void> Function() action) async {
    final versionBefore = _version;
    final entriesBefore = Map<String, CalendarFeedRow>.of(_entries);
    try {
      await action();
    } catch (_) {
      _version = versionBefore;
      _entries
        ..clear()
        ..addAll(entriesBefore);
      rethrow;
    }
  }

  @override
  Future<void> upsertOrWithdraw(CalendarFeedEntry entry) async {
    final row = entry as CalendarFeedRow;
    if (row.isWithdrawn) {
      _entries.remove(row.id);
    } else {
      _entries[row.id] = row;
    }
  }
}
