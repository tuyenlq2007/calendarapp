import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/calendar/data/calendar_database.dart';
import 'package:mobile/features/calendar/data/calendar_sync_service.dart';

void main() {
  test('failed page does not advance sync version', () async {
    final store = FakeCalendarStore(version: 4, failOnEntry: 'bad');
    final service = CalendarSyncService(FakeFeed(), store);

    await expectLater(service.sync(), throwsA(isA<FormatException>()));

    expect(await store.currentVersion(), 4);
    expect(store.upsertedEntries, isEmpty);
  });

  test('successful page advances to highest processed entry version', () async {
    final feed = FakeFeed();
    final store = FakeCalendarStore(version: 4);
    final service = CalendarSyncService(feed, store);

    await service.sync();

    expect(feed.afterVersion, 4);
    expect(store.upsertedEntries, ['good', 'bad']);
    expect(await store.currentVersion(), 6);
  });

  test('empty page does not advance sync version', () async {
    final feed = FakeFeed(entries: []);
    final store = FakeCalendarStore(version: 4);
    final service = CalendarSyncService(feed, store);

    await service.sync();

    expect(feed.afterVersion, 4);
    expect(store.upsertedEntries, isEmpty);
    expect(await store.currentVersion(), 4);
  });

  test('stale local cursor is replaced by a full published snapshot', () async {
    final feed = FakeFeed(
      fullSnapshotEntries: [FakeCalendarEntry('fresh', version: 3)],
      entriesByVersion: {20: []},
    );
    final store = SnapshotCalendarStore(
      version: 20,
      entries: {'stale': FakeCalendarEntry('stale', version: 20)},
    );
    final service = CalendarSyncService(feed, store);

    await service.sync();

    expect(feed.requestedVersions, [20, 0]);
    expect(store.entryIds, ['fresh']);
    expect(await store.currentVersion(), 3);
  });
}

class FakeFeed implements CalendarFeed {
  FakeFeed({
    List<FakeCalendarEntry>? entries,
    List<FakeCalendarEntry>? fullSnapshotEntries,
    Map<int, List<FakeCalendarEntry>>? entriesByVersion,
  })
    : entries =
          entries ??
          [
            FakeCalendarEntry('good', version: 5),
            FakeCalendarEntry('bad', version: 6),
          ],
      fullSnapshotEntries = fullSnapshotEntries ?? entries,
      entriesByVersion = entriesByVersion ?? const {};

  final List<FakeCalendarEntry> entries;
  final List<FakeCalendarEntry>? fullSnapshotEntries;
  final Map<int, List<FakeCalendarEntry>> entriesByVersion;
  int? afterVersion;
  final List<int> requestedVersions = [];

  @override
  Future<CalendarChangePage> changesAfter(int version) async {
    requestedVersions.add(version);
    afterVersion = version;
    if (version == 0 && fullSnapshotEntries != null) {
      return CalendarChangePage(entries: fullSnapshotEntries!);
    }
    final versionEntries = entriesByVersion[version];
    if (versionEntries != null) {
      return CalendarChangePage(entries: versionEntries);
    }
    return CalendarChangePage(entries: entries);
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
  FakeCalendarEntry(this.id, {required this.version});

  @override
  final String id;

  @override
  final int version;

  @override
  void validate() {}
}

class SnapshotCalendarStore implements CalendarSnapshotStore {
  SnapshotCalendarStore({
    required this.version,
    required Map<String, FakeCalendarEntry> entries,
  }) : _entries = Map<String, FakeCalendarEntry>.of(entries);

  int version;
  final Map<String, FakeCalendarEntry> _entries;

  List<String> get entryIds => _entries.keys.toList()..sort();

  @override
  Future<int> currentVersion() async => version;

  @override
  Future<void> replaceWithPublishedSnapshot(
    Iterable<CalendarFeedEntry> entries, {
    required int version,
  }) async {
    _entries
      ..clear()
      ..addEntries(
        entries.map((entry) => MapEntry(entry.id, entry as FakeCalendarEntry)),
      );
    this.version = version;
  }

  @override
  Future<void> setCurrentVersion(int version) async {
    this.version = version;
  }

  @override
  Future<void> transaction(Future<void> Function() action) async {
    await action();
  }

  @override
  Future<void> upsertOrWithdraw(CalendarFeedEntry entry) async {
    _entries[entry.id] = entry as FakeCalendarEntry;
  }
}
