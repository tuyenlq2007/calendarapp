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
  String lastUpdated(String date) {
    return 'Last updated: $date';
  }
}
