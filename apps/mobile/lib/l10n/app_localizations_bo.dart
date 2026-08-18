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
  String get syncStatus =>
      'à½˜à½‰à½˜à¼‹à½¦à¾¦à¾²à½ºà½£à¼‹à½‚à½“à½¦à¼‹à½šà½´à½£à¼';

  @override
  String get notUpdatedYet =>
      'à½‘à¼‹à½‘à½´à½„à¼‹à½‚à½¦à½¢à¼‹à½¦à¾’à¾±à½´à½¢à¼‹à½–à¾±à½¦à¼‹à½˜à½ºà½‘à¼';

  @override
  String get retry => 'à½¡à½„à¼‹à½–à½¦à¾à¾±à½¢à¼';

  @override
  String get syncing =>
      'à½˜à½‰à½˜à¼‹à½¦à¾¦à¾²à½ºà½£à¼‹à½–à¾±à½ºà½‘à¼‹à½–à½žà½²à½“à¼';

  @override
  String get syncFailed =>
      'à½˜à½‰à½˜à¼‹à½¦à¾¦à¾²à½ºà½£à¼‹à½˜à¼‹à½ à½‚à¾²à½´à½–à¼ à½£à½¼à¼‹à½à½¼à½ à½²à¼‹à½“à½„à¼‹à½‘à½¼à½“à¼‹à½¢à¾Ÿà½²à½„à¼‹à½”à¼‹à½‰à½¢à¼‹à½¡à½¼à½‘à¼';
}
