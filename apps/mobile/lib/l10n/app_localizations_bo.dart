// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tibetan (`bo`).
class AppLocalizationsBo extends AppLocalizations {
  AppLocalizationsBo([String locale = 'bo']) : super(locale);

  @override
  String get today => 'དེ་རིང་།';

  @override
  String get calendar => 'ལོ་ཐོ།';

  @override
  String get practice => 'སྒྲུབ་པ།';

  @override
  String get more => 'དེ་ལས་མང་བ།';

  @override
  String get notificationSettings => 'བརྡ་ཐོ།';

  @override
  String get dailyPractice => 'ཉིན་རེའི་སྒྲུབ་པ།';

  @override
  String get holyDays => 'དུས་ཆེན།';

  @override
  String get calendarEvents => 'ལོ་ཐོའི་བྱེད་སྒོ།';

  @override
  String get teachings => 'ཆོས་ཁྲིད།';

  @override
  String get news => 'གསར་འགྱུར།';

  @override
  String lastUpdated(String date) {
    return 'ཐ་མའི་གསར་སྒྱུར། $date';
  }

  @override
  String get syncStatus => 'མཉམ་སྦྲེལ་གནས་ཚུལ།';

  @override
  String get notUpdatedYet => 'ད་དུང་གསར་སྒྱུར་བྱས་མེད།';

  @override
  String get retry => 'ཡང་བསྐྱར།';

  @override
  String get syncing => 'མཉམ་སྦྲེལ་བྱེད་བཞིན།';

  @override
  String get syncFailed => 'མཉམ་སྦྲེལ་མ་འགྲུབ། ལོ་ཐོའི་ནང་དོན་རྙིང་པ་ཉར་ཡོད།';
}
