import 'calendar_database.dart';

class CalendarSyncService {
  CalendarSyncService(this.feed, this.store);

  final CalendarFeed feed;
  final CalendarStore store;

  Future<void> sync() async {
    final currentVersion = await store.currentVersion();
    final page = await feed.changesAfter(currentVersion);
    if (page.entries.isEmpty &&
        currentVersion > 0 &&
        store is CalendarSnapshotStore) {
      await _replaceFromFullSnapshot(store as CalendarSnapshotStore);
      return;
    }

    await _applyChanges(page.entries);
  }

  Future<void> _applyChanges(Iterable<CalendarFeedEntry> entries) async {
    await store.transaction(() async {
      int? latestProcessedVersion;
      for (final entry in entries) {
        entry.validate();
        await store.upsertOrWithdraw(entry);
        latestProcessedVersion = _maxVersion(
          latestProcessedVersion,
          entry.version,
        );
      }
      if (latestProcessedVersion != null) {
        await store.setCurrentVersion(latestProcessedVersion);
      }
    });
  }

  Future<void> _replaceFromFullSnapshot(CalendarSnapshotStore store) async {
    final fullSnapshot = await feed.changesAfter(0);
    int latestProcessedVersion = 0;
    for (final entry in fullSnapshot.entries) {
      entry.validate();
      latestProcessedVersion = _maxVersion(
        latestProcessedVersion,
        entry.version,
      );
    }

    await store.transaction(() async {
      await store.replaceWithPublishedSnapshot(
        fullSnapshot.entries,
        version: latestProcessedVersion,
      );
    });
  }

  int _maxVersion(int? left, int right) {
    if (left == null || right > left) return right;
    return left;
  }
}
