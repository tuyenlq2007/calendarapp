enum ReminderCategory {
  dailyPractice,
  holyDays,
  calendarEvents,
  teachings,
  news,
}

extension ReminderCategoryKey on ReminderCategory {
  String get storageKey {
    return switch (this) {
      ReminderCategory.dailyPractice => 'daily_practice',
      ReminderCategory.holyDays => 'holy_days',
      ReminderCategory.calendarEvents => 'calendar_events',
      ReminderCategory.teachings => 'teachings',
      ReminderCategory.news => 'news',
    };
  }
}
