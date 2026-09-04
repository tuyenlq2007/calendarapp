import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'calendar_database.dart';

class SharedPreferencesCalendarStore implements CalendarStore {
  SharedPreferencesCalendarStore(this.preferences);

  static const _versionKey = 'calendar.sync.version';
  static const _entriesKey = 'calendar.sync.entries';
  static const _lastSyncedAtKey = 'calendar.sync.last_synced_at';

  final SharedPreferencesAsync preferences;

  @override
  Future<int> currentVersion() async {
    return await preferences.getInt(_versionKey) ?? 0;
  }

  @override
  Future<void> setCurrentVersion(int version) async {
    await preferences.setInt(_versionKey, version);
  }

  @override
  Future<void> transaction(Future<void> Function() action) async {
    final versionBefore = await currentVersion();
    final entriesBefore = await _readEntries();
    try {
      await action();
    } catch (_) {
      await preferences.setInt(_versionKey, versionBefore);
      await _writeEntries(entriesBefore);
      rethrow;
    }
  }

  @override
  Future<void> upsertOrWithdraw(CalendarFeedEntry entry) async {
    final row = entry as CalendarFeedRow;
    final entries = await _readEntries();
    if (row.isWithdrawn) {
      entries.remove(row.id);
    } else {
      entries[row.id] = row;
    }
    await _writeEntries(entries);
  }

  Future<List<CalendarFeedRow>> publishedEntries() async {
    final entries = await _readEntries();
    final rows = entries.values.toList()
      ..sort(
        (left, right) => left.gregorianDate.compareTo(right.gregorianDate),
      );
    return rows;
  }

  Future<DateTime?> lastSyncedAt() async {
    final encoded = await preferences.getString(_lastSyncedAtKey);
    if (encoded == null) return null;
    return DateTime.tryParse(encoded);
  }

  Future<void> setLastSyncedAt(DateTime lastSyncedAt) async {
    await preferences.setString(
      _lastSyncedAtKey,
      lastSyncedAt.toIso8601String(),
    );
  }

  Future<Map<String, CalendarFeedRow>> _readEntries() async {
    final encodedRows =
        await preferences.getStringList(_entriesKey) ?? const [];
    final entries = <String, CalendarFeedRow>{};
    for (final encodedRow in encodedRows) {
      final row = CalendarFeedRow.fromJson(
        (jsonDecode(encodedRow) as Map<String, dynamic>)
            .cast<String, Object?>(),
      );
      entries[row.id] = row;
    }
    return entries;
  }

  Future<void> _writeEntries(Map<String, CalendarFeedRow> entries) async {
    await preferences.setStringList(_entriesKey, [
      for (final row in entries.values)
        jsonEncode({
          'id': row.id,
          'version': row.version,
          'gregorian_date': row.gregorianDate
              .toIso8601String()
              .split('T')
              .first,
          'tibetan_date_text': row.tibetanDateText,
          'title_en': row.titleEn,
          'title_bo': row.titleBo,
          'description_en': row.descriptionEn,
          'description_bo': row.descriptionBo,
          'element_tibetan_line': row.elementTibetanLine,
          'element_pair_en': row.elementPairEn,
          'element_combination_title_en': row.elementCombinationTitleEn,
          'element_description_en': row.elementDescriptionEn,
          'day_number_text': row.dayNumberText,
          'day_element_animal_en': row.dayElementAnimalEn,
          'month_number_text': row.monthNumberText,
          'month_element_animal_en': row.monthElementAnimalEn,
          'year_number_text': row.yearNumberText,
          'year_element_animal_en': row.yearElementAnimalEn,
          'status': row.status,
        }),
    ]);
  }
}
