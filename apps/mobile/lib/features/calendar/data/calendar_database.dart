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

  int get version;

  void validate();
}

class CalendarChangePage {
  const CalendarChangePage({required this.entries});

  final List<CalendarFeedEntry> entries;
}
