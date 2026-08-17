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
  String lastUpdated(String date) {
    return 'ཐ་མའི་གསར་སྒྱུར། $date';
  }
}
