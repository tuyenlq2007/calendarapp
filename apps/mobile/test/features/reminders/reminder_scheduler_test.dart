import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/reminders/data/reminder_scheduler.dart';
import 'package:mobile/features/reminders/domain/reminder_category.dart';

void main() {
  test('holy-day preference schedules only holy-day entries', () async {
    final notifications = FakeNotifications();
    final scheduler = ReminderScheduler(notifications, now: fixedNow);

    await scheduler.rebuild(entries, {ReminderCategory.holyDays});

    expect(notifications.scheduled.map((n) => n.entryId), ['holy-1']);
  });

  test('permission denial cancels existing notifications without error', () async {
    final notifications = FakeNotifications(canSchedule: false);
    final scheduler = ReminderScheduler(notifications, now: fixedNow);

    await scheduler.rebuild(entries, {ReminderCategory.holyDays});

    expect(notifications.cancelCount, 0);
    expect(notifications.scheduled, isEmpty);
  });

  test('time-zone rebuild cancels stale notifications before rescheduling', () async {
    final notifications = FakeNotifications();
    final scheduler = ReminderScheduler(notifications, now: fixedNow);

    await scheduler.rebuild(entries, {
      ReminderCategory.dailyPractice,
      ReminderCategory.holyDays,
    });
    await scheduler.rebuild(entries, {ReminderCategory.dailyPractice});

    expect(notifications.cancelCount, 2);
    expect(notifications.scheduled.map((n) => n.entryId), ['practice-1']);
  });

  test('notifications compare by value', () {
    expect(
      entries.first.toNotification(),
      CalendarNotification(
        entryId: 'practice-1',
        title: 'Daily practice',
        body: 'Morning practice',
        scheduledAt: DateTime(2026, 2, 1, 7),
        category: ReminderCategory.dailyPractice,
      ),
    );
  });

  test('past reminders and distant reminders are not scheduled', () async {
    final notifications = FakeNotifications();
    final scheduler = ReminderScheduler(
      notifications,
      now: fixedNow,
      schedulingHorizon: const Duration(days: 30),
    );

    await scheduler.rebuild(
      [
        CalendarReminderEntry(
          id: 'past',
          title: 'Past',
          body: 'Already happened',
          scheduledAt: DateTime(2026, 1, 31, 7),
          category: ReminderCategory.holyDays,
        ),
        entries[1],
        CalendarReminderEntry(
          id: 'distant',
          title: 'Distant',
          body: 'Too far away',
          scheduledAt: DateTime(2026, 3, 15, 7),
          category: ReminderCategory.holyDays,
        ),
      ],
      {ReminderCategory.holyDays},
    );

    expect(notifications.scheduled.map((n) => n.entryId), ['holy-1']);
  });

  test('scheduling is capped to the configured pending notification limit', () async {
    final notifications = FakeNotifications();
    final scheduler = ReminderScheduler(
      notifications,
      now: fixedNow,
      maxPendingNotifications: 1,
    );

    await scheduler.rebuild(entries, {
      ReminderCategory.dailyPractice,
      ReminderCategory.holyDays,
    });

    expect(notifications.scheduled.map((n) => n.entryId), ['practice-1']);
  });

  test('schedule failures are reported after computing a deterministic plan', () async {
    final notifications = FakeNotifications(failOnEntryId: 'holy-1');
    final scheduler = ReminderScheduler(notifications, now: fixedNow);

    await expectLater(
      scheduler.rebuild(entries, {
        ReminderCategory.dailyPractice,
        ReminderCategory.holyDays,
      }),
      throwsA(isA<ReminderSchedulingException>()),
    );

    expect(notifications.cancelCount, 1);
    expect(notifications.scheduled.map((n) => n.entryId), ['practice-1']);
  });
}

final fixedNow = DateTime(2026, 2);

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
  FakeNotifications({this.canSchedule = true, this.failOnEntryId});

  final bool canSchedule;
  final String? failOnEntryId;
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
    if (notification.entryId == failOnEntryId) {
      throw StateError('failed to schedule ${notification.entryId}');
    }
    scheduled.add(notification);
  }
}
