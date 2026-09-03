enum CommunityEntryType {
  news,
  event,
  monastery,
  contact;

  factory CommunityEntryType.fromJson(String value) {
    return switch (value) {
      'news' => CommunityEntryType.news,
      'event' => CommunityEntryType.event,
      'monastery' => CommunityEntryType.monastery,
      'contact' => CommunityEntryType.contact,
      _ => throw FormatException(
        'community entry has unsupported type: $value',
      ),
    };
  }

  String get sectionTitle {
    return switch (this) {
      CommunityEntryType.news => 'Latest News',
      CommunityEntryType.event => 'Community Events',
      CommunityEntryType.monastery => 'Monastery Information',
      CommunityEntryType.contact => 'Contact',
    };
  }
}

class CommunityEntryRow {
  const CommunityEntryRow({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
    required this.detail,
    required this.startsAt,
    required this.location,
    required this.contact,
    required this.displayOrder,
    required this.published,
  });

  factory CommunityEntryRow.fromJson(Map<String, Object?> json) {
    return CommunityEntryRow(
      id: _string(json, 'id'),
      type: CommunityEntryType.fromJson(_string(json, 'type')),
      title: _string(json, 'title'),
      summary: _string(json, 'summary'),
      detail: _nullableString(json, 'detail') ?? '',
      startsAt: _nullableDateTime(json, 'starts_at'),
      location: _nullableString(json, 'location'),
      contact: _nullableString(json, 'contact'),
      displayOrder: _integer(json, 'display_order'),
      published: _boolean(json, 'published'),
    )..validate();
  }

  final String id;
  final CommunityEntryType type;
  final String title;
  final String summary;
  final String detail;
  final DateTime? startsAt;
  final String? location;
  final String? contact;
  final int displayOrder;
  final bool published;

  String? get formattedStart {
    final value = startsAt;
    if (value == null) return null;
    final local = value.toLocal();
    return '${_twoDigits(local.day)}/${_twoDigits(local.month)}/${local.year} '
        '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
  }

  void validate() {
    if (id.trim().isEmpty) {
      throw const FormatException('community entry id is required');
    }
    if (title.trim().isEmpty) {
      throw const FormatException('community entry title is required');
    }
    if (summary.trim().isEmpty) {
      throw const FormatException('community entry summary is required');
    }
  }

  static String _string(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String) return value;
    throw FormatException('community entry field $key must be a string');
  }

  static String? _nullableString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is String) return value;
    throw FormatException('community entry field $key must be a string');
  }

  static DateTime? _nullableDateTime(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is String) return DateTime.parse(value);
    throw FormatException('community entry field $key must be a string');
  }

  static int _integer(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is num && value == value.toInt()) return value.toInt();
    throw FormatException('community entry field $key must be an integer');
  }

  static bool _boolean(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is bool) return value;
    throw FormatException('community entry field $key must be a boolean');
  }
}

class CommunityPage {
  const CommunityPage({required this.rows});

  factory CommunityPage.fromJsonRows(Iterable<Map<String, Object?>> rows) {
    return CommunityPage(
      rows: [for (final row in rows) CommunityEntryRow.fromJson(row)],
    );
  }

  final List<CommunityEntryRow> rows;
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
