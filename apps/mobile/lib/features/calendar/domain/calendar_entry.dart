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
    descriptionEn:
        'Bad day for hanging prayer flags. Birthday of the present Gyalwang Drukpa and Guru Padmasambhava manifestations.',
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
      descriptionEn:
          'Bad day for hanging prayer flags. Birthday of the present Gyalwang Drukpa and Guru Padmasambhava manifestations.',
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
