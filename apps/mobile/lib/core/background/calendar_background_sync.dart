import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/calendar/data/calendar_sync_service.dart';
import '../../features/calendar/data/shared_preferences_calendar_store.dart';
import '../network/supabase_calendar_feed.dart';

const calendarBackgroundSyncUniqueName = 'barom_kagyu_calendar_background_sync';
const calendarBackgroundSyncTaskName = 'barom_kagyu_calendar_sync';
const calendarBackgroundSyncFrequency = Duration(hours: 1);
const calendarBackgroundSyncSupabaseUrlKey = 'supabaseUrl';
const calendarBackgroundSyncSupabaseAnonKey = 'supabaseAnonKey';

typedef CalendarBackgroundSyncRunner = Future<void> Function({
  required String supabaseUrl,
  required String supabaseAnonKey,
});

abstract class CalendarBackgroundScheduler {
  Future<void> initialize();

  Future<void> registerPeriodicTask({
    required String uniqueName,
    required String taskName,
    required Duration frequency,
    required Map<String, dynamic> inputData,
    required bool requiresNetwork,
  });
}

class WorkmanagerCalendarBackgroundScheduler
    implements CalendarBackgroundScheduler {
  const WorkmanagerCalendarBackgroundScheduler();

  @override
  Future<void> initialize() {
    return Workmanager().initialize(calendarBackgroundTaskDispatcher);
  }

  @override
  Future<void> registerPeriodicTask({
    required String uniqueName,
    required String taskName,
    required Duration frequency,
    required Map<String, dynamic> inputData,
    required bool requiresNetwork,
  }) {
    return Workmanager().registerPeriodicTask(
      uniqueName,
      taskName,
      frequency: frequency,
      inputData: inputData,
      constraints: Constraints(
        networkType: requiresNetwork ? NetworkType.connected : null,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
  }
}

Future<bool> registerCalendarBackgroundSync({
  required CalendarBackgroundScheduler scheduler,
  required String supabaseUrl,
  required String supabaseAnonKey,
  Duration frequency = calendarBackgroundSyncFrequency,
}) async {
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    return false;
  }

  await scheduler.initialize();
  await scheduler.registerPeriodicTask(
    uniqueName: calendarBackgroundSyncUniqueName,
    taskName: calendarBackgroundSyncTaskName,
    frequency: frequency,
    inputData: {
      calendarBackgroundSyncSupabaseUrlKey: supabaseUrl,
      calendarBackgroundSyncSupabaseAnonKey: supabaseAnonKey,
    },
    requiresNetwork: true,
  );

  return true;
}

Future<bool> runCalendarBackgroundSync(
  Map<String, dynamic>? inputData, {
  CalendarBackgroundSyncRunner syncRunner = syncCalendarFromSupabase,
}) async {
  final supabaseUrl = inputData?[calendarBackgroundSyncSupabaseUrlKey];
  final supabaseAnonKey = inputData?[calendarBackgroundSyncSupabaseAnonKey];
  if (supabaseUrl is! String ||
      supabaseAnonKey is! String ||
      supabaseUrl.isEmpty ||
      supabaseAnonKey.isEmpty) {
    return false;
  }

  await syncRunner(supabaseUrl: supabaseUrl, supabaseAnonKey: supabaseAnonKey);
  return true;
}

@pragma('vm:entry-point')
void calendarBackgroundTaskDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != calendarBackgroundSyncTaskName &&
        taskName != Workmanager.iOSBackgroundTask) {
      return true;
    }

    return runCalendarBackgroundSync(inputData);
  });
}

Future<void> syncCalendarFromSupabase({
  required String supabaseUrl,
  required String supabaseAnonKey,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);

  final store = SharedPreferencesCalendarStore(SharedPreferencesAsync());
  final syncService = CalendarSyncService(
    SupabaseCalendarFeed.fromClient(Supabase.instance.client),
    store,
  );
  await syncService.sync();
  await store.setLastSyncedAt(DateTime.now());
}
