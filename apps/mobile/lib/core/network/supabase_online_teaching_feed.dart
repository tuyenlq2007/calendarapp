import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/teachings/data/online_teaching_database.dart';

class SupabaseOnlineTeachingFeed {
  SupabaseOnlineTeachingFeed(this._loadRows);

  factory SupabaseOnlineTeachingFeed.fromClient(SupabaseClient client) {
    return SupabaseOnlineTeachingFeed(
      () => client
          .from('online_teachings')
          .select()
          .eq('published', true)
          .order('display_order', ascending: true),
    );
  }

  final Future<List<dynamic>> Function() _loadRows;

  Future<List<OnlineTeachingRow>> publishedRows() async {
    final rows = await _loadRows();

    return OnlineTeachingPage.fromJsonRows(
      rows.map((row) {
        if (row is Map<String, dynamic>) return row;
        if (row is Map<String, Object?>) return row;
        throw const FormatException(
          'online_teachings returned a non-object row',
        );
      }),
    ).rows;
  }
}
