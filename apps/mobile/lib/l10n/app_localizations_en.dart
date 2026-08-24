// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get today => 'Today';

  @override
  String get calendar => 'Calendar';

  @override
  String get practice => 'Practice';

  @override
  String get more => 'More';

  @override
  String get notificationSettings => 'Notifications';

  @override
  String get dailyPractice => 'Daily practice';

  @override
  String get holyDays => 'Holy days';

  @override
  String get calendarEvents => 'Calendar events';

  @override
  String get teachings => 'Dharma';

  @override
  String get news => 'News';

  @override
  String lastUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get syncStatus => 'Sync status';

  @override
  String get notUpdatedYet => 'Not updated yet';

  @override
  String get retry => 'Retry';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncFailed => 'Sync failed. Existing calendar content was kept.';
}
