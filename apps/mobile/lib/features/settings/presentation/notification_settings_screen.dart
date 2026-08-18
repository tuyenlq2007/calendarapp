import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../reminders/domain/reminder_category.dart';
import 'sync_status_tile.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({
    super.key,
    required this.enabled,
    required this.onChanged,
    required this.lastSyncedAt,
    required this.onRetrySync,
    this.isSyncing = false,
  });

  final Set<ReminderCategory> enabled;
  final ValueChanged<Set<ReminderCategory>> onChanged;
  final DateTime? lastSyncedAt;
  final VoidCallback? onRetrySync;
  final bool isSyncing;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.notificationSettings)),
      body: ListView(
        children: [
          SyncStatusTile(
            lastUpdated: lastSyncedAt,
            onRetry: onRetrySync,
            isSyncing: isSyncing,
          ),
          const Divider(height: 1),
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
