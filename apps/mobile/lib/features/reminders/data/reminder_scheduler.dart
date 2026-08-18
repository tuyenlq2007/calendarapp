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

  @override
  bool operator ==(Object other) {
    return other is CalendarReminderEntry &&
        other.id == id &&
        other.title == title &&
        other.body == body &&
        other.scheduledAt == scheduledAt &&
        other.category == category;
  }

  @override
  int get hashCode => Object.hash(id, title, body, scheduledAt, category);
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

  @override
  bool operator ==(Object other) {
    return other is CalendarNotification &&
        other.entryId == entryId &&
        other.title == title &&
        other.body == body &&
        other.scheduledAt == scheduledAt &&
        other.category == category;
  }

  @override
  int get hashCode => Object.hash(entryId, title, body, scheduledAt, category);
}

class ReminderSchedulingException implements Exception {
  ReminderSchedulingException(this.entryId, this.cause, this.stackTrace);

  final String entryId;
  final Object cause;
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'ReminderSchedulingException($entryId, $cause)';
  }
}

class ReminderScheduler {
  ReminderScheduler(
    this.notifications, {
    required this.now,
    this.schedulingHorizon = const Duration(days: 90),
    this.maxPendingNotifications = 64,
  });

  final NotificationsPort notifications;
  final DateTime Function() now;
  final Duration schedulingHorizon;
  final int maxPendingNotifications;

  Future<void> rebuild(
    List<CalendarReminderEntry> entries,
    Set<ReminderCategory> enabled,
  ) async {
    final cutoff = now();
    final horizonEnd = cutoff.add(schedulingHorizon);
    final eligible = entries
        .where((entry) => enabled.contains(entry.category))
        .where((entry) => entry.scheduledAt.isAfter(cutoff))
        .where((entry) => !entry.scheduledAt.isAfter(horizonEnd))
        .toList()
      ..sort((left, right) {
        final timeComparison = left.scheduledAt.compareTo(right.scheduledAt);
        if (timeComparison != 0) return timeComparison;
        return left.id.compareTo(right.id);
      });

    final pending = eligible
        .take(maxPendingNotifications)
        .map((entry) => entry.toNotification())
        .toList(growable: false);

    await notifications.cancelCalendarNotifications();
    if (!await notifications.canScheduleNotifications()) return;

    for (final notification in pending) {
      try {
        await notifications.schedule(notification);
      } catch (error, stackTrace) {
        throw ReminderSchedulingException(
          notification.entryId,
          error,
          stackTrace,
        );
      }
    }
  }
}
