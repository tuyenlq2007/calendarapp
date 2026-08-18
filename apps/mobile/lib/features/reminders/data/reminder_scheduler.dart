import '../domain/reminder_category.dart';

abstract interface class NotificationsPort {
  Future<void> cancelCalendarNotifications();

  Future<bool> canScheduleNotifications();

  Future<void> schedule(CalendarNotification notification);
}

class CalendarReminderEntry {
  const CalendarReminderEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.category,
  });

  final String id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final ReminderCategory category;

  CalendarNotification toNotification() {
    return CalendarNotification(
      entryId: id,
      title: title,
      body: body,
      scheduledAt: scheduledAt,
      category: category,
    );
  }
}

class CalendarNotification {
  const CalendarNotification({
    required this.entryId,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.category,
  });

  final String entryId;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final ReminderCategory category;
}

class ReminderScheduler {
  ReminderScheduler(this.notifications);

  final NotificationsPort notifications;

  Future<void> rebuild(
    List<CalendarReminderEntry> entries,
    Set<ReminderCategory> enabled,
  ) async {
    await notifications.cancelCalendarNotifications();
    if (!await notifications.canScheduleNotifications()) return;

    for (final entry in entries.where((entry) => enabled.contains(entry.category))) {
      await notifications.schedule(entry.toNotification());
    }
  }
}
