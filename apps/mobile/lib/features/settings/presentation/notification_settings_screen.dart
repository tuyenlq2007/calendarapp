import 'package:flutter/material.dart';

import '../../reminders/domain/reminder_category.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({
    super.key,
    required this.enabled,
    required this.onChanged,
  });

  final Set<ReminderCategory> enabled;
  final ValueChanged<Set<ReminderCategory>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        children: [
          for (final category in ReminderCategory.values)
            CheckboxListTile(
              value: enabled.contains(category),
              title: Text(_labelFor(category)),
              onChanged: (selected) {
                final next = Set<ReminderCategory>.of(enabled);
                if (selected ?? false) {
                  next.add(category);
                } else {
                  next.remove(category);
                }
                onChanged(next);
              },
            ),
        ],
      ),
    );
  }

  String _labelFor(ReminderCategory category) {
    return switch (category) {
      ReminderCategory.dailyPractice => 'Daily practice',
      ReminderCategory.holyDays => 'Holy days',
      ReminderCategory.calendarEvents => 'Calendar events',
      ReminderCategory.teachings => 'Teachings',
      ReminderCategory.news => 'News',
    };
  }
}
