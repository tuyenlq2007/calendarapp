import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/network/supabase_calendar_feed.dart';
import 'features/calendar/data/calendar_sync_service.dart';
import 'features/calendar/data/shared_preferences_calendar_store.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final store = SharedPreferencesCalendarStore(SharedPreferencesAsync());
  CalendarSyncService? syncService;

  if (_supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: _supabaseUrl,
      publishableKey: _supabaseAnonKey,
    );
    syncService = CalendarSyncService(
      SupabaseCalendarFeed.fromClient(Supabase.instance.client),
      store,
    );
  }

  runApp(
    BaromKagyuCalendarApp(
      calendarStore: store.publishedEntries,
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
