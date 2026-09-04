import '../data/calendar_database.dart';

class CalendarEntry {
  const CalendarEntry({
    required this.day,
    required this.weekday,
    required this.tibetanDateText,
    required this.titleEn,
    required this.titleBo,
    required this.descriptionEn,
    this.elementTibetanLine = '',
    this.elementPairEn = '',
    this.elementCombinationTitleEn = '',
    this.elementDescriptionEn = '',
    this.dayNumberText = '',
    this.dayElementAnimalEn = '',
    this.monthNumberText = '',
    this.monthElementAnimalEn = '',
    this.yearNumberText = '',
    this.yearElementAnimalEn = '',
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
  final String elementTibetanLine;
  final String elementPairEn;
  final String elementCombinationTitleEn;
  final String elementDescriptionEn;
  final String dayNumberText;
  final String dayElementAnimalEn;
  final String monthNumberText;
  final String monthElementAnimalEn;
  final String yearNumberText;
  final String yearElementAnimalEn;
  final int lunarDay;
  final bool isHighlighted;
  final bool isDharmicDay;
}

class CalendarMonth {
  const CalendarMonth({
    required this.title,
    required this.year,
    required this.month,
    required this.today,
    required this.entries,
    required this.daysInMonth,
    required this.firstWeekdayOffset,
  });

  final String title;
  final int year;
  final int month;
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
    elementTibetanLine: row.elementTibetanLine,
    elementPairEn: row.elementPairEn,
    elementCombinationTitleEn: row.elementCombinationTitleEn,
    elementDescriptionEn: row.elementDescriptionEn,
    dayNumberText: row.dayNumberText,
    dayElementAnimalEn: row.dayElementAnimalEn,
    monthNumberText: row.monthNumberText,
    monthElementAnimalEn: row.monthElementAnimalEn,
    yearNumberText: row.yearNumberText,
    yearElementAnimalEn: row.yearElementAnimalEn,
    lunarDay: row.gregorianDate.day,
    isDharmicDay: true,
  );
}

CalendarMonth calendarMonthFromFeedRows(List<CalendarFeedRow> rows) {
  final activeRows = rows.where((row) => !row.isWithdrawn).toList();
  if (activeRows.isEmpty) return sampleCalendarEntries;

  final firstDate = activeRows.first.gregorianDate;
  return calendarMonthFromFeedRowsForMonth(rows, firstDate);
}

CalendarMonth calendarMonthFromFeedRowsForMonth(
  List<CalendarFeedRow> rows,
  DateTime visibleMonth,
) {
  final monthStart = DateTime(visibleMonth.year, visibleMonth.month);
  final activeRows = rows.where((row) {
    final date = row.gregorianDate;
    return !row.isWithdrawn &&
        date.year == monthStart.year &&
        date.month == monthStart.month;
  }).toList();

  final entries = [for (final row in activeRows) calendarEntryFromFeedRow(row)];
  final daysInMonth = DateTime(monthStart.year, monthStart.month + 1, 0).day;

  return CalendarMonth(
    title: '${monthStart.monthName} ${monthStart.year}',
    year: monthStart.year,
    month: monthStart.month,
    today:
        entries.firstOrNull ??
        CalendarEntry(
          day: 1,
          weekday: monthStart.weekdayName,
          tibetanDateText: '',
          titleEn: 'No practice day selected',
          titleBo: '',
          descriptionEn: 'No practice days for this month yet.',
          lunarDay: 1,
        ),
    entries: entries,
    daysInMonth: daysInMonth,
    firstWeekdayOffset: monthStart.weekday - 1,
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
  year: 2021,
  month: 2,
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
