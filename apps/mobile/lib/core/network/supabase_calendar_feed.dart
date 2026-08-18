import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/calendar/data/calendar_database.dart';

class NetworkException implements Exception {
  const NetworkException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'NetworkException($message)';
}

class SupabaseCalendarFeed implements CalendarFeed {
  SupabaseCalendarFeed(this._loadRows);

  factory SupabaseCalendarFeed.fromClient(SupabaseClient client) {
    return SupabaseCalendarFeed(
      (version) => client.rpc<List<dynamic>>(
        'calendar_changes',
        params: {'after_version': version},
      ),
    );
  }

  final Future<List<dynamic>> Function(int version) _loadRows;

  @override
  Future<CalendarChangePage> changesAfter(int version) async {
    try {
      final rows = await _loadRows(version);

      return CalendarChangePage.fromJsonRows(
        rows.map((row) {
          if (row is Map<String, dynamic>) return row;
          if (row is Map<String, Object?>) return row;
          throw const FormatException(
            'calendar_changes returned a non-object row',
          );
        }),
      );
    } on FormatException {
      rethrow;
    } catch (error) {
      throw NetworkException('Unable to load calendar changes', error);
    }
  }
}
