import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/reminders/data/reminder_scheduler.dart';
import 'package:mobile/features/reminders/domain/reminder_category.dart';

void main() {
  test('holy-day preference schedules only holy-day entries', () async {
    final notifications = FakeNotifications();
    final scheduler = ReminderScheduler(notifications, now: () => fixedNow);

    await scheduler.rebuild(entries, {ReminderCategory.holyDays});

    expect(notifications.scheduled.map((n) => n.entryId), ['holy-1']);
  });

  test('permission denial cancels existing notifications without error', () async {
    final notifications = FakeNotifications(canSchedule: false);
    final scheduler = ReminderScheduler(notifications, now: () => fixedNow);

    await scheduler.rebuild(entries, {ReminderCategory.holyDays});

    expect(notifications.cancelCount, 1);
    expect(notifications.scheduled, isEmpty);
  });

  test('time-zone rebuild cancels stale notifications before rescheduling', () async {
    final notifications = FakeNotifications();
    final scheduler = ReminderScheduler(notifications, now: () => fixedNow);

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
      now: () => fixedNow,
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
      now: () => fixedNow,
      maxPendingNotifications: 1,
    );

    await scheduler.rebuild(entries, {
      ReminderCategory.dailyPractice,
      ReminderCategory.holyDays,
    });

    expect(notifications.scheduled.map((n) => n.entryId), ['practice-1']);
  });

  test('pending notification cap keeps the earliest reminders first', () async {
    final notifications = FakeNotifications();
    final scheduler = ReminderScheduler(
      notifications,
      now: () => fixedNow,
      maxPendingNotifications: 2,
    );

    await scheduler.rebuild(
      [
        CalendarReminderEntry(
          id: 'later',
          title: 'Later',
          body: 'Later reminder',
          scheduledAt: DateTime(2026, 2, 5, 7),
          category: ReminderCategory.holyDays,
        ),
        CalendarReminderEntry(
          id: 'same-time-b',
          title: 'Same time B',
          body: 'Same time reminder',
          scheduledAt: DateTime(2026, 2, 2, 7),
          category: ReminderCategory.holyDays,
        ),
        CalendarReminderEntry(
          id: 'same-time-a',
          title: 'Same time A',
          body: 'Same time reminder',
          scheduledAt: DateTime(2026, 2, 2, 7),
          category: ReminderCategory.holyDays,
        ),
      ],
      {ReminderCategory.holyDays},
    );

    expect(notifications.scheduled.map((n) => n.entryId), [
      'same-time-a',
      'same-time-b',
    ]);
  });

  test('reused scheduler evaluates the clock at rebuild time', () async {
    var now = DateTime(2026, 2, 1, 6);
    final notifications = FakeNotifications();
    final scheduler = ReminderScheduler(notifications, now: () => now);

    await scheduler.rebuild(entries, {ReminderCategory.dailyPractice});
    expect(notifications.scheduled.map((n) => n.entryId), ['practice-1']);

    now = DateTime(2026, 2, 1, 8);
    await scheduler.rebuild(entries, {ReminderCategory.dailyPractice});
    expect(notifications.scheduled, isEmpty);
  });

  test('schedule failures are aggregated after attempting the full plan', () async {
    final notifications = FakeNotifications(failOnEntryIds: {'holy-1', 'teaching-1'});
    final scheduler = ReminderScheduler(notifications, now: () => fixedNow);

    await expectLater(
      scheduler.rebuild(
        [
          ...entries,
          CalendarReminderEntry(
            id: 'teaching-1',
            title: 'Teaching',
            body: 'New teaching',
            scheduledAt: DateTime(2026, 2, 3, 7),
            category: ReminderCategory.teachings,
          ),
        ],
        {
          ReminderCategory.dailyPractice,
          ReminderCategory.holyDays,
          ReminderCategory.teachings,
        },
      ),
      throwsA(
        isA<ReminderSchedulingException>()
            .having(
              (error) => error.failures.map((failure) => failure.entryId),
              'failed entry ids',
              ['holy-1', 'teaching-1'],
            )
            .having(
              (error) => error.stackTrace.toString(),
              'stackTrace',
              contains('FakeNotifications.schedule'),
            ),
      ),
    );

    expect(notifications.cancelCount, 1);
    expect(notifications.scheduled.map((n) => n.entryId), ['practice-1']);
  });

  test('invalid scheduling policies fail fast in debug builds', () {
    expect(
      () => ReminderScheduler(
        FakeNotifications(),
        now: () => fixedNow,
        maxPendingNotifications: -1,
      ),
      throwsA(isA<AssertionError>()),
    );

    expect(
      () => ReminderScheduler(
        FakeNotifications(),
        now: () => fixedNow,
        schedulingHorizon: const Duration(days: -1),
      ),
      throwsA(isA<AssertionError>()),
    );
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
  FakeNotifications({this.canSchedule = true, Set<String>? failOnEntryIds})
    : failOnEntryIds = failOnEntryIds ?? const {};

  final bool canSchedule;
  final Set<String> failOnEntryIds;
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
    if (failOnEntryIds.contains(notification.entryId)) {
      throw StateError('failed to schedule ${notification.entryId}');
    }
    scheduled.add(notification);
  }
}
