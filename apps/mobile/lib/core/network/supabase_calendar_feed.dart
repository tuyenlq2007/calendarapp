import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/calendar/data/calendar_database.dart';

class NetworkException implements Exception {
  const NetworkException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() {
    if (cause == null) return 'NetworkException($message)';
    return 'NetworkException($message, cause: $cause)';
  }
}

class SupabaseCalendarFeed implements CalendarFeed {
  SupabaseCalendarFeed(
    this._loadRows, {
    this.retryDelay = const Duration(milliseconds: 500),
    this.maxAttempts = 5,
  });

  factory SupabaseCalendarFeed.fromClient(SupabaseClient client) {
    return SupabaseCalendarFeed(
      (version) => client.rpc<List<dynamic>>(
        'calendar_changes',
        params: {'after_version': version},
      ),
    );
  }

  final Future<List<dynamic>> Function(int version) _loadRows;
  final Duration retryDelay;
  final int maxAttempts;

  @override
  Future<CalendarChangePage> changesAfter(int version) async {
    Object? lastError;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
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
        lastError = error;
        if (attempt == maxAttempts - 1) break;
        if (retryDelay > Duration.zero) {
          await Future<void>.delayed(retryDelay * (attempt + 1));
        }
      }
    }

    throw NetworkException('Unable to load calendar changes', lastError);
  }
}
