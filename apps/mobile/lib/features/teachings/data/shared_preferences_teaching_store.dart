import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'teaching_content_database.dart';

class SharedPreferencesTeachingStore {
  SharedPreferencesTeachingStore(this.preferences);

  static const _entriesKey = 'teachings.content.entries';
  static const _savedIdsKey = 'teachings.content.saved_ids';

  final SharedPreferencesAsync preferences;

  Future<void> upsertOrWithdraw(TeachingContentRow row) async {
    final entries = await _readEntries();
    final savedIds = await savedContentIds();
    if (row.isWithdrawn) {
      entries.remove(row.id);
      savedIds.remove(row.id);
      await preferences.setStringList(_savedIdsKey, savedIds.toList()..sort());
    } else {
      entries[row.id] = row;
    }
    await _writeEntries(entries);
  }

  Future<List<TeachingContentRow>> publishedContent() async {
    final entries = await _readEntries();
    final rows = entries.values.toList()
      ..sort((left, right) => left.titleEn.compareTo(right.titleEn));
    return rows;
  }

  Future<List<TeachingContentRow>> savedContent() async {
    final entries = await _readEntries();
    final savedIds = await savedContentIds();
    final rows = [
      for (final row in entries.values)
        if (savedIds.contains(row.id)) row,
    ]..sort((left, right) => left.titleEn.compareTo(right.titleEn));
    return rows;
  }

  Future<Set<String>> savedContentIds() async {
    return (await preferences.getStringList(_savedIdsKey) ?? const []).toSet();
  }

  Future<Set<String>> toggleSaved(String id) async {
    final savedIds = await savedContentIds();
    if (!savedIds.add(id)) {
      savedIds.remove(id);
    }
    await preferences.setStringList(_savedIdsKey, savedIds.toList()..sort());
    return savedIds;
  }

  Future<Map<String, TeachingContentRow>> _readEntries() async {
    final encodedRows =
        await preferences.getStringList(_entriesKey) ?? const [];
    final entries = <String, TeachingContentRow>{};
    for (final encodedRow in encodedRows) {
      final row = TeachingContentRow.fromJson(
        (jsonDecode(encodedRow) as Map<String, dynamic>)
            .cast<String, Object?>(),
      );
      entries[row.id] = row;
    }
    return entries;
  }

  Future<void> _writeEntries(Map<String, TeachingContentRow> entries) async {
    await preferences.setStringList(_entriesKey, [
      for (final row in entries.values) jsonEncode(row.toJson()),
    ]);
  }
}
