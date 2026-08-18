abstract interface class CalendarFeed {
  Future<CalendarChangePage> changesAfter(int version);
}

abstract interface class CalendarStore {
  Future<int> currentVersion();

  Future<void> transaction(Future<void> Function() action);

  Future<void> upsertOrWithdraw(CalendarFeedEntry entry);

  Future<void> setCurrentVersion(int version);
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
  final String status;

  bool get isWithdrawn => status == 'archived';

  @override
  void validate() {
    if (id.trim().isEmpty) {
      throw const FormatException('calendar feed row id is required');
    }
    if (version < 0) {
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

  static int _integer(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    throw FormatException('calendar feed row field $key must be an integer');
  }
}
