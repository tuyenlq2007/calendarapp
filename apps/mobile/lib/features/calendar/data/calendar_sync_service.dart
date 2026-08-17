import 'calendar_database.dart';

class CalendarSyncService {
  CalendarSyncService(this.feed, this.store);

  final CalendarFeed feed;
  final CalendarStore store;

  Future<void> sync() async {
    final page = await feed.changesAfter(await store.currentVersion());
    await store.transaction(() async {
      int? latestProcessedVersion;
      for (final entry in page.entries) {
        entry.validate();
        await store.upsertOrWithdraw(entry);
        if (latestProcessedVersion == null ||
            entry.version > latestProcessedVersion) {
          latestProcessedVersion = entry.version;
        }
      }
      if (latestProcessedVersion != null) {
        await store.setCurrentVersion(latestProcessedVersion);
      }
    });
  }
}
