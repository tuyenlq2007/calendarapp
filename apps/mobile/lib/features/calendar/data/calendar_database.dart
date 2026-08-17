abstract interface class CalendarFeed {
  Future<CalendarChangePage> changesAfter(int version);
}

abstract interface class CalendarStore {
  Future<int> currentVersion();

  Future<void> transaction(Future<void> Function() action);

  Future<void> upsertOrWithdraw(CalendarFeedEntry entry);

  Future<void> setCurrentVersion(int version);
}

abstract interface class CalendarFeedEntry {
  String get id;

  void validate();
}

class CalendarChangePage {
  const CalendarChangePage({required this.version, required this.entries});

  final int version;
  final List<CalendarFeedEntry> entries;
}
