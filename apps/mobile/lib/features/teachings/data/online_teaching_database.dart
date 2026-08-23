enum OnlineTeachingStatus {
  upcoming,
  ongoing,
  finished;

  factory OnlineTeachingStatus.fromJson(String value) {
    return switch (value) {
      'upcoming' => OnlineTeachingStatus.upcoming,
      'ongoing' => OnlineTeachingStatus.ongoing,
      'finished' => OnlineTeachingStatus.finished,
      _ => throw FormatException(
        'online teaching has unsupported status: $value',
      ),
    };
  }

  String get label {
    return switch (this) {
      OnlineTeachingStatus.upcoming => 'Upcoming',
      OnlineTeachingStatus.ongoing => 'Ongoing',
      OnlineTeachingStatus.finished => 'Finished',
    };
  }

  bool get canJoin => this == OnlineTeachingStatus.ongoing;
}

class OnlineTeachingRow {
  const OnlineTeachingRow({
    required this.id,
    required this.title,
    required this.practice,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.joinUrl,
    required this.displayOrder,
    required this.published,
  });

  factory OnlineTeachingRow.fromJson(Map<String, Object?> json) {
    return OnlineTeachingRow(
      id: _string(json, 'id'),
      title: _string(json, 'title'),
      practice: _string(json, 'practice'),
      startDate: DateTime.parse(_string(json, 'start_date')),
      endDate: DateTime.parse(_string(json, 'end_date')),
      status: OnlineTeachingStatus.fromJson(_string(json, 'status')),
      joinUrl: Uri.parse(_string(json, 'join_url')),
      displayOrder: _integer(json, 'display_order'),
      published: _boolean(json, 'published'),
    )..validate();
  }

  final String id;
  final String title;
  final String practice;
  final DateTime startDate;
  final DateTime endDate;
  final OnlineTeachingStatus status;
  final Uri joinUrl;
  final int displayOrder;
  final bool published;

  String get formattedDateRange {
    return '${_formatDayMonth(startDate)} - ${_formatDate(endDate)}';
  }

  void validate() {
    if (id.trim().isEmpty) {
      throw const FormatException('online teaching id is required');
    }
    if (title.trim().isEmpty) {
      throw const FormatException('online teaching title is required');
    }
    if (practice.trim().isEmpty) {
      throw const FormatException('online teaching practice is required');
    }
    if (!joinUrl.hasScheme || joinUrl.host.isEmpty) {
      throw const FormatException('online teaching join URL is invalid');
    }
  }

  static String _formatDayMonth(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  static String _string(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String) return value;
    throw FormatException('online teaching field $key must be a string');
  }

  static int _integer(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is num && value == value.toInt()) return value.toInt();
    throw FormatException('online teaching field $key must be an integer');
  }

  static bool _boolean(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is bool) return value;
    throw FormatException('online teaching field $key must be a boolean');
  }
}

class OnlineTeachingPage {
  const OnlineTeachingPage({required this.rows});

  factory OnlineTeachingPage.fromJsonRows(Iterable<Map<String, Object?>> rows) {
    return OnlineTeachingPage(
      rows: [for (final row in rows) OnlineTeachingRow.fromJson(row)],
    );
  }

  final List<OnlineTeachingRow> rows;
}
