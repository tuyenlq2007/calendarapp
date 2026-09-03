import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/background/calendar_background_sync.dart';
import 'core/network/supabase_calendar_feed.dart';
import 'core/network/supabase_community_feed.dart';
import 'core/network/supabase_online_teaching_feed.dart';
import 'features/calendar/data/calendar_sync_service.dart';
import 'features/calendar/data/shared_preferences_calendar_store.dart';
import 'features/teachings/data/shared_preferences_teaching_store.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final store = SharedPreferencesCalendarStore(SharedPreferencesAsync());
  final teachingStore = SharedPreferencesTeachingStore(
    SharedPreferencesAsync(),
  );
  CalendarSyncService? syncService;
  SupabaseOnlineTeachingFeed? onlineTeachingFeed;
  SupabaseCommunityFeed? communityFeed;

  if (_supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: _supabaseUrl,
      publishableKey: _supabaseAnonKey,
    );
    syncService = CalendarSyncService(
      SupabaseCalendarFeed.fromClient(Supabase.instance.client),
      store,
    );
    onlineTeachingFeed = SupabaseOnlineTeachingFeed.fromClient(
      Supabase.instance.client,
    );
    communityFeed = SupabaseCommunityFeed.fromClient(Supabase.instance.client);
    await registerCalendarBackgroundSync(
      scheduler: const WorkmanagerCalendarBackgroundScheduler(),
      supabaseUrl: _supabaseUrl,
      supabaseAnonKey: _supabaseAnonKey,
    );
  }

  runApp(
    BaromKagyuCalendarApp(
      calendarStore: store.publishedEntries,
      teachingContentStore: teachingStore.publishedContent,
      onlineTeachingStore: onlineTeachingFeed?.publishedRows,
      communityStore: communityFeed?.publishedRows,
      initialLastSyncedAt: await store.lastSyncedAt(),
      syncCalendar: syncService == null
          ? null
          : () async {
              await syncService!.sync();
              final lastSyncedAt = DateTime.now();
              await store.setLastSyncedAt(lastSyncedAt);
              return lastSyncedAt;
            },
    ),
  );
}
