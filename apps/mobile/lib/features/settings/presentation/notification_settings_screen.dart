import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
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
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.notificationSettings)),
      body: ListView(
        children: [
          for (final category in ReminderCategory.values)
            CheckboxListTile(
              value: enabled.contains(category),
              title: Text(_labelFor(localizations, category)),
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

  String _labelFor(AppLocalizations localizations, ReminderCategory category) {
    return switch (category) {
      ReminderCategory.dailyPractice => localizations.dailyPractice,
      ReminderCategory.holyDays => localizations.holyDays,
      ReminderCategory.calendarEvents => localizations.calendarEvents,
      ReminderCategory.teachings => localizations.teachings,
      ReminderCategory.news => localizations.news,
    };
  }
}
