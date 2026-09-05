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
    this.imageUrl = '',
    // Compatibility for old callers while status migrates to a derived value.
    OnlineTeachingStatus? status,
    required this.joinUrl,
    required this.displayOrder,
    required this.published,
  });

  factory OnlineTeachingRow.fromJson(Map<String, Object?> json) {
    return OnlineTeachingRow(
      id: _string(json, 'id'),
      title: _string(json, 'title'),
      practice: _string(json, 'practice'),
      startDate: _dateTime(json, 'start_datetime', fallbackKey: 'start_date'),
      endDate: _dateTime(
        json,
        'end_datetime',
        fallbackKey: 'end_date',
        legacyDateEndOfDay: true,
      ),
      imageUrl: _optionalString(json, 'image_url'),
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
  final String imageUrl;
  final Uri joinUrl;
  final int displayOrder;
  final bool published;

  OnlineTeachingStatus statusAt(DateTime now) {
    if (now.isBefore(startDate)) return OnlineTeachingStatus.upcoming;
    if (!now.isBefore(endDate)) return OnlineTeachingStatus.finished;
    return OnlineTeachingStatus.ongoing;
  }

  OnlineTeachingStatus get status => statusAt(DateTime.now());

  String get formattedDateRange {
    return '${_formatDayMonth(startDate)} - ${_formatDate(endDate)}';
  }

  String get formattedLocalDateTimeRange {
    return '${_formatLocalDateTime(startDate)} - '
        '${_formatLocalDateTime(endDate)}';
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
    if (imageUrl.trim().isNotEmpty) {
      final parsedImageUrl = Uri.tryParse(imageUrl);
      if (parsedImageUrl == null ||
          !parsedImageUrl.hasScheme ||
          parsedImageUrl.host.isEmpty) {
        throw const FormatException('online teaching image URL is invalid');
      }
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

  static String _formatLocalDateTime(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = _monthAbbreviation(local.month);
    final hour = _formatHour12(local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour < 12 ? 'AM' : 'PM';
    return '$month $day $hour:$minute $period';
  }

  static int _formatHour12(int hour) {
    final normalized = hour % 12;
    return normalized == 0 ? 12 : normalized;
  }

  static String _monthAbbreviation(int month) {
    return const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][month - 1];
  }

  static DateTime _dateTime(
    Map<String, Object?> json,
    String key, {
    required String fallbackKey,
    bool legacyDateEndOfDay = false,
  }) {
    final preferredValue = json[key];
    if (preferredValue is String) return DateTime.parse(preferredValue);

    final value = json[fallbackKey];
    if (value is String) {
      final parsed = DateTime.parse(value);
      if (legacyDateEndOfDay &&
          RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
        return DateTime(parsed.year, parsed.month, parsed.day, 23, 59, 59, 999);
      }
      return parsed;
    }

    throw FormatException(
      'online teaching field $key or $fallbackKey must be a string',
    );
  }

  static String _string(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String) return value;
    throw FormatException('online teaching field $key must be a string');
  }

  static String _optionalString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return '';
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
