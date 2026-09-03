import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/community/data/community_database.dart';

class SupabaseCommunityFeed {
  SupabaseCommunityFeed(this._loadRows);

  factory SupabaseCommunityFeed.fromClient(SupabaseClient client) {
    return SupabaseCommunityFeed(
      () => client
          .from('community_entries')
          .select()
          .eq('published', true)
          .order('display_order', ascending: true)
          .order('starts_at', ascending: true, nullsFirst: false),
    );
  }

  final Future<List<dynamic>> Function() _loadRows;

  Future<List<CommunityEntryRow>> publishedRows() async {
    final rows = await _loadRows();

    return CommunityPage.fromJsonRows(
      rows.map((row) {
        if (row is Map<String, dynamic>) return row;
        if (row is Map<String, Object?>) return row;
        throw const FormatException(
          'community_entries returned a non-object row',
        );
      }),
    ).rows;
  }
}
