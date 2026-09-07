abstract interface class CalendarFeed {
  Future<CalendarChangePage> changesAfter(int version);
}

abstract interface class CalendarStore {
  Future<int> currentVersion();

  Future<void> transaction(Future<void> Function() action);

  Future<void> upsertOrWithdraw(CalendarFeedEntry entry);

  Future<void> setCurrentVersion(int version);
}

abstract interface class CalendarSnapshotStore implements CalendarStore {
  Future<void> replaceWithPublishedSnapshot(
    Iterable<CalendarFeedEntry> entries, {
    required int version,
  });
}

abstract interface class CalendarFeedEntry {
  String get id;

  int get version;

  void validate();
}

class CalendarChangePage {
  const CalendarChangePage({required this.entries});

  factory CalendarChangePage.fromJsonRows(Iterable<Map<String, Object?>> rows) {
    return CalendarChangePage(
      entries: [for (final row in rows) CalendarFeedRow.fromJson(row)],
    );
  }

  final List<CalendarFeedEntry> entries;
}

class CalendarFeedRow implements CalendarFeedEntry {
  const CalendarFeedRow({
    required this.id,
    required this.version,
    required this.gregorianDate,
    required this.tibetanDateText,
    required this.titleEn,
    required this.titleBo,
    required this.descriptionEn,
    required this.descriptionBo,
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
    this.isPracticeDay = false,
    this.practiceDayTitle,
    this.practiceDayDescription,
    this.practiceDayImageUrl,
    required this.status,
  });

  factory CalendarFeedRow.fromJson(Map<String, Object?> json) {
    return CalendarFeedRow(
      id: _string(json, 'id'),
      version: _integer(json, 'version'),
      gregorianDate: DateTime.parse(_string(json, 'gregorian_date')),
      tibetanDateText: _string(json, 'tibetan_date_text'),
      titleEn: _string(json, 'title_en'),
      titleBo: _string(json, 'title_bo'),
      descriptionEn: _string(json, 'description_en'),
      descriptionBo: _string(json, 'description_bo'),
      elementTibetanLine: _optionalString(json, 'element_tibetan_line'),
      elementPairEn: _optionalString(json, 'element_pair_en'),
      elementCombinationTitleEn: _optionalString(
        json,
        'element_combination_title_en',
      ),
      elementDescriptionEn: _optionalString(json, 'element_description_en'),
      dayNumberText: _optionalString(json, 'day_number_text'),
      dayElementAnimalEn: _optionalString(json, 'day_element_animal_en'),
      monthNumberText: _optionalString(json, 'month_number_text'),
      monthElementAnimalEn: _optionalString(json, 'month_element_animal_en'),
      yearNumberText: _optionalString(json, 'year_number_text'),
      yearElementAnimalEn: _optionalString(json, 'year_element_animal_en'),
      isPracticeDay: _optionalBoolean(json, 'is_practice_day'),
      practiceDayTitle: _optionalNullableString(json, 'practice_day_title'),
      practiceDayDescription: _optionalNullableString(
        json,
        'practice_day_description',
      ),
      practiceDayImageUrl: _optionalNullableString(
        json,
        'practice_day_image_url',
      ),
      status: _string(json, 'status'),
    );
  }

  @override
  final String id;

  @override
  final int version;

  final DateTime gregorianDate;
  final String tibetanDateText;
  final String titleEn;
  final String titleBo;
  final String descriptionEn;
  final String descriptionBo;
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
  final bool isPracticeDay;
  final String? practiceDayTitle;
  final String? practiceDayDescription;
  final String? practiceDayImageUrl;
  final String status;

  bool get isWithdrawn => status == 'archived';

  @override
  void validate() {
    if (id.trim().isEmpty) {
      throw const FormatException('calendar feed row id is required');
    }
    if (version <= 0) {
      throw const FormatException('calendar feed row version must be positive');
    }
    if (status != 'published' && status != 'archived') {
      throw FormatException(
        'calendar feed row has unsupported status: $status',
      );
    }
    if (status == 'published' &&
        (tibetanDateText.trim().isEmpty ||
            titleEn.trim().isEmpty ||
            titleBo.trim().isEmpty)) {
      throw const FormatException(
        'published calendar feed row must include bilingual titles and Tibetan date',
      );
    }
  }

  static String _string(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String) return value;
    throw FormatException('calendar feed row field $key must be a string');
  }

  static String _optionalString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return '';
    if (value is String) return value;
    throw FormatException('calendar feed row field $key must be a string');
  }

  static String? _optionalNullableString(
    Map<String, Object?> json,
    String key,
  ) {
    final value = json[key];
    if (value == null) return null;
    if (value is String) return value;
    throw FormatException('calendar feed row field $key must be a string');
  }

  static bool _optionalBoolean(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return false;
    if (value is bool) return value;
    throw FormatException('calendar feed row field $key must be a boolean');
  }

  static int _integer(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is num && value == value.toInt()) return value.toInt();
    throw FormatException('calendar feed row field $key must be an integer');
  }

  CalendarFeedRow copyWith({
    String? elementTibetanLine,
    String? elementPairEn,
    String? elementCombinationTitleEn,
    String? elementDescriptionEn,
    String? dayNumberText,
    String? dayElementAnimalEn,
    String? monthNumberText,
    String? monthElementAnimalEn,
    String? yearNumberText,
    String? yearElementAnimalEn,
    bool? isPracticeDay,
    String? practiceDayTitle,
    String? practiceDayDescription,
    String? practiceDayImageUrl,
  }) {
    return CalendarFeedRow(
      id: id,
      version: version,
      gregorianDate: gregorianDate,
      tibetanDateText: tibetanDateText,
      titleEn: titleEn,
      titleBo: titleBo,
      descriptionEn: descriptionEn,
      descriptionBo: descriptionBo,
      elementTibetanLine: elementTibetanLine ?? this.elementTibetanLine,
      elementPairEn: elementPairEn ?? this.elementPairEn,
      elementCombinationTitleEn:
          elementCombinationTitleEn ?? this.elementCombinationTitleEn,
      elementDescriptionEn: elementDescriptionEn ?? this.elementDescriptionEn,
      dayNumberText: dayNumberText ?? this.dayNumberText,
      dayElementAnimalEn: dayElementAnimalEn ?? this.dayElementAnimalEn,
      monthNumberText: monthNumberText ?? this.monthNumberText,
      monthElementAnimalEn: monthElementAnimalEn ?? this.monthElementAnimalEn,
      yearNumberText: yearNumberText ?? this.yearNumberText,
      yearElementAnimalEn: yearElementAnimalEn ?? this.yearElementAnimalEn,
      isPracticeDay: isPracticeDay ?? this.isPracticeDay,
      practiceDayTitle: practiceDayTitle ?? this.practiceDayTitle,
      practiceDayDescription:
          practiceDayDescription ?? this.practiceDayDescription,
      practiceDayImageUrl: practiceDayImageUrl ?? this.practiceDayImageUrl,
      status: status,
    );
  }
}
