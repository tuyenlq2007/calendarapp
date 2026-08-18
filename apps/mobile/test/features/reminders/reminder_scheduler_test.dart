import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/reminders/data/reminder_scheduler.dart';
import 'package:mobile/features/reminders/domain/reminder_category.dart';

void main() {
  test('holy-day preference schedules only holy-day entries', () async {
    final notifications = FakeNotifications();
    final scheduler = ReminderScheduler(notifications);

    await scheduler.rebuild(entries, {ReminderCategory.holyDays});

    expect(notifications.scheduled.map((n) => n.entryId), ['holy-1']);
  });

  test('permission denial cancels existing notifications without error', () async {
    final notifications = FakeNotifications(canSchedule: false);
    final scheduler = ReminderScheduler(notifications);

    await scheduler.rebuild(entries, {ReminderCategory.holyDays});

    expect(notifications.cancelCount, 1);
    expect(notifications.scheduled, isEmpty);
  });

  test('time-zone rebuild cancels stale notifications before rescheduling', () async {
    final notifications = FakeNotifications();
    final scheduler = ReminderScheduler(notifications);

    await scheduler.rebuild(entries, {
      ReminderCategory.dailyPractice,
      ReminderCategory.holyDays,
    });
    await scheduler.rebuild(entries, {ReminderCategory.dailyPractice});

    expect(notifications.cancelCount, 2);
    expect(notifications.scheduled.map((n) => n.entryId), ['practice-1']);
  });
}

final entries = [
  CalendarReminderEntry(
    id: 'practice-1',
    title: 'Daily practice',
    body: 'Morning practice',
    scheduledAt: DateTime(2026, 2, 1, 7),
    category: ReminderCategory.dailyPractice,
  ),
  CalendarReminderEntry(
    id: 'holy-1',
    title: 'Guru Rinpoche day',
    body: 'Practice day',
    scheduledAt: DateTime(2026, 2, 2, 7),
    category: ReminderCategory.holyDays,
  ),
];

class FakeNotifications implements NotificationsPort {
  FakeNotifications({this.canSchedule = true});

  final bool canSchedule;
  int cancelCount = 0;
  final scheduled = <CalendarNotification>[];

  @override
  Future<void> cancelCalendarNotifications() async {
    cancelCount += 1;
    scheduled.clear();
  }

  @override
  Future<bool> canScheduleNotifications() async => canSchedule;

  @override
  Future<void> schedule(CalendarNotification notification) async {
    scheduled.add(notification);
  }
}
