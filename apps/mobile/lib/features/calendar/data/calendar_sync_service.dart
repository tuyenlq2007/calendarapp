import 'calendar_database.dart';

class CalendarSyncService {
  CalendarSyncService(this.feed, this.store);

  final CalendarFeed feed;
  final CalendarStore store;

  Future<void> sync() async {
    final page = await feed.changesAfter(await store.currentVersion());
    await store.transaction(() async {
      for (final entry in page.entries) {
        entry.validate();
        await store.upsertOrWithdraw(entry);
      }
      await store.setCurrentVersion(page.version);
    });
  }
}
