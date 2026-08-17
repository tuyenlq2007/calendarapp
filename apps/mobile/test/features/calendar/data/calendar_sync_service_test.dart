import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/calendar/data/calendar_database.dart';
import 'package:mobile/features/calendar/data/calendar_sync_service.dart';

void main() {
  test('failed page does not advance sync version', () async {
    final store = FakeCalendarStore(version: 4, failOnEntry: 'bad');
    final service = CalendarSyncService(FakeFeed(version: 5), store);

    await expectLater(service.sync(), throwsA(isA<FormatException>()));

    expect(await store.currentVersion(), 4);
  });

  test('successful page upserts entries and advances sync version', () async {
    final feed = FakeFeed(version: 5);
    final store = FakeCalendarStore(version: 4);
    final service = CalendarSyncService(feed, store);

    await service.sync();

    expect(feed.afterVersion, 4);
    expect(store.upsertedEntries, ['good', 'bad']);
    expect(await store.currentVersion(), 5);
  });
}

class FakeFeed implements CalendarFeed {
  FakeFeed({required this.version});

  final int version;
  int? afterVersion;

  @override
  Future<CalendarChangePage> changesAfter(int version) async {
    afterVersion = version;
    return CalendarChangePage(
      version: this.version,
      entries: [FakeCalendarEntry('good'), FakeCalendarEntry('bad')],
    );
  }
}

class FakeCalendarStore implements CalendarStore {
  FakeCalendarStore({required this.version, this.failOnEntry});

  int version;
  final String? failOnEntry;
  final List<String> upsertedEntries = [];

  @override
  Future<int> currentVersion() async => version;

  @override
  Future<void> setCurrentVersion(int version) async {
    this.version = version;
  }

  @override
  Future<void> transaction(Future<void> Function() action) async {
    final versionBeforeTransaction = version;
    final upsertedBeforeTransaction = List<String>.of(upsertedEntries);
    try {
      await action();
    } catch (_) {
      version = versionBeforeTransaction;
      upsertedEntries
        ..clear()
        ..addAll(upsertedBeforeTransaction);
      rethrow;
    }
  }

  @override
  Future<void> upsertOrWithdraw(CalendarFeedEntry entry) async {
    if (entry.id == failOnEntry) {
      throw const FormatException('invalid entry');
    }
    upsertedEntries.add(entry.id);
  }
}

class FakeCalendarEntry implements CalendarFeedEntry {
  FakeCalendarEntry(this.id);

  @override
  final String id;

  @override
  void validate() {}
}
