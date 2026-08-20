import '../data/calendar_database.dart';

class CalendarEntry {
  const CalendarEntry({
    required this.day,
    required this.weekday,
    required this.tibetanDateText,
    required this.titleEn,
    required this.titleBo,
    required this.descriptionEn,
    required this.lunarDay,
    this.isHighlighted = false,
    this.isDharmicDay = false,
  });

  final int day;
  final String weekday;
  final String tibetanDateText;
  final String titleEn;
  final String titleBo;
  final String descriptionEn;
  final int lunarDay;
  final bool isHighlighted;
  final bool isDharmicDay;
}

class CalendarMonth {
  const CalendarMonth({
    required this.title,
    required this.today,
    required this.entries,
    required this.daysInMonth,
    required this.firstWeekdayOffset,
  });

  final String title;
  final CalendarEntry today;
  final List<CalendarEntry> entries;
  final int daysInMonth;
  final int firstWeekdayOffset;

  CalendarEntry? entryForDay(int day) {
    for (final entry in entries) {
      if (entry.day == day) return entry;
    }
    return null;
  }
}

CalendarEntry calendarEntryFromFeedRow(CalendarFeedRow row) {
  return CalendarEntry(
    day: row.gregorianDate.day,
    weekday: row.gregorianDate.weekdayName,
    tibetanDateText: row.tibetanDateText,
    titleEn: row.titleEn,
    titleBo: row.titleBo,
    descriptionEn: row.descriptionEn,
    lunarDay: row.gregorianDate.day,
    isDharmicDay: true,
  );
}

CalendarMonth calendarMonthFromFeedRows(List<CalendarFeedRow> rows) {
  final activeRows = rows.where((row) => !row.isWithdrawn).toList();
  if (activeRows.isEmpty) return sampleCalendarEntries;

  final entries = [for (final row in activeRows) calendarEntryFromFeedRow(row)];
  final firstDate = activeRows.first.gregorianDate;

  return CalendarMonth(
    title: '${firstDate.monthName} ${firstDate.year}',
    today: entries.first,
    entries: entries,
    daysInMonth: DateTime(firstDate.year, firstDate.month + 1, 0).day,
    firstWeekdayOffset: DateTime(firstDate.year, firstDate.month).weekday - 1,
  );
}

extension on DateTime {
  String get weekdayName {
    return switch (weekday) {
      DateTime.monday => 'Monday',
      DateTime.tuesday => 'Tuesday',
      DateTime.wednesday => 'Wednesday',
      DateTime.thursday => 'Thursday',
      DateTime.friday => 'Friday',
      DateTime.saturday => 'Saturday',
      DateTime.sunday => 'Sunday',
      _ => '',
    };
  }

  String get monthName {
    return switch (month) {
      DateTime.january => 'January',
      DateTime.february => 'February',
      DateTime.march => 'March',
      DateTime.april => 'April',
      DateTime.may => 'May',
      DateTime.june => 'June',
      DateTime.july => 'July',
      DateTime.august => 'August',
      DateTime.september => 'September',
      DateTime.october => 'October',
      DateTime.november => 'November',
      DateTime.december => 'December',
      _ => '',
    };
  }
}

const sampleCalendarEntries = CalendarMonth(
  title: 'February 2021',
  daysInMonth: 28,
  firstWeekdayOffset: 0,
  today: CalendarEntry(
    day: 22,
    weekday: 'Monday',
    tibetanDateText: 'བོད་ཟླ ༡༠ ཚེས ༡༠',
    titleEn: 'Guru Rinpoche day',
    titleBo: 'གུ་རུ་རིན་པོ་ཆེའི་དུས་ཆེན།',
    descriptionEn: 'Bad day for hanging prayer flags. Birthday of Guru Padmasambhava manifestations.',
    lunarDay: 10,
    isHighlighted: true,
    isDharmicDay: true,
  ),
  entries: [
    CalendarEntry(
      day: 3,
      weekday: 'Wednesday',
      tibetanDateText: 'བོད་ཟླ ༡༢ ཚེས ༡',
      titleEn: 'Chotrul Duchen start',
      titleBo: 'ཆོ་འཕྲུལ་དུས་ཆེན།',
      descriptionEn: 'Start of the great days of miracles.',
      lunarDay: 1,
      isDharmicDay: true,
    ),
    CalendarEntry(
      day: 12,
      weekday: 'Friday',
      tibetanDateText: 'བོད་ཟླ ༡༢ ཚེས ༡',
      titleEn: 'Losar - Lunar New Year',
      titleBo: 'ལོ་གསར།',
      descriptionEn: 'Tibetan lunar new year.',
      lunarDay: 1,
      isDharmicDay: true,
    ),
    CalendarEntry(
      day: 19,
      weekday: 'Friday',
      tibetanDateText: 'བོད་ཟླ ༡ ཚེས ༨',
      titleEn: 'Medicine Buddha day',
      titleBo: 'སྨན་བླའི་དུས་ཆེན།',
      descriptionEn: 'Practice day for Medicine Buddha.',
      lunarDay: 8,
      isDharmicDay: true,
    ),
    CalendarEntry(
      day: 22,
      weekday: 'Monday',
      tibetanDateText: 'བོད་ཟླ ༡༠ ཚེས ༡༠',
      titleEn: 'Guru Rinpoche day',
      titleBo: 'གུ་རུ་རིན་པོ་ཆེའི་དུས་ཆེན།',
      descriptionEn: 'Bad day for hanging prayer flags. Birthday of Guru Padmasambhava manifestations.',
      lunarDay: 10,
      isHighlighted: true,
      isDharmicDay: true,
    ),
    CalendarEntry(
      day: 25,
      weekday: 'Thursday',
      tibetanDateText: 'བོད་ཟླ ༡ ཚེས ༢༥',
      titleEn: 'Dakini day',
      titleBo: 'མཁའ་འགྲོ་མའི་དུས་ཆེན།',
      descriptionEn: 'Tsok and Dakini practice day.',
      lunarDay: 25,
      isDharmicDay: true,
    ),
    CalendarEntry(
      day: 29,
      weekday: 'Sunday',
      tibetanDateText: 'བོད་ཟླ ༡ ཚེས ༢༩',
      titleEn: 'Dharma Protector day',
      titleBo: 'ཆོས་སྐྱོང་གི་ཉིན།',
      descriptionEn: 'Dharma Protector practice day.',
      lunarDay: 29,
      isDharmicDay: true,
    ),
  ],
);
