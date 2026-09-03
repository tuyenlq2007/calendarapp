import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/background/calendar_background_sync.dart';

void main() {
  test(
    'configured Supabase registers hourly network background sync',
    () async {
      final scheduler = _RecordingBackgroundSyncScheduler();

      final registered = await registerCalendarBackgroundSync(
        scheduler: scheduler,
        supabaseUrl: 'https://example.supabase.co',
        supabaseAnonKey: 'public-key',
      );

      expect(registered, isTrue);
      expect(scheduler.initialized, isTrue);
      expect(scheduler.uniqueName, 'barom_kagyu_calendar_background_sync');
      expect(scheduler.taskName, 'barom_kagyu_calendar_sync');
      expect(scheduler.frequency, const Duration(hours: 1));
      expect(scheduler.requiresNetwork, isTrue);
      expect(scheduler.inputData, {
        'supabaseUrl': 'https://example.supabase.co',
        'supabaseAnonKey': 'public-key',
      });
    },
  );

  test('missing Supabase config skips background sync registration', () async {
    final scheduler = _RecordingBackgroundSyncScheduler();

    final registered = await registerCalendarBackgroundSync(
      scheduler: scheduler,
      supabaseUrl: '',
      supabaseAnonKey: 'public-key',
    );

    expect(registered, isFalse);
    expect(scheduler.initialized, isFalse);
    expect(scheduler.uniqueName, isNull);
  });

  test(
    'background task runner syncs when input contains Supabase config',
    () async {
      String? syncedUrl;
      String? syncedKey;

      final synced = await runCalendarBackgroundSync(
        {
          'supabaseUrl': 'https://example.supabase.co',
          'supabaseAnonKey': 'public-key',
        },
        syncRunner:
            ({
              required String supabaseUrl,
              required String supabaseAnonKey,
            }) async {
              syncedUrl = supabaseUrl;
              syncedKey = supabaseAnonKey;
            },
      );

      expect(synced, isTrue);
      expect(syncedUrl, 'https://example.supabase.co');
      expect(syncedKey, 'public-key');
    },
  );

  test(
    'background task runner skips sync when input is missing config',
    () async {
      var syncCalls = 0;

      final synced = await runCalendarBackgroundSync(
        {'supabaseUrl': 'https://example.supabase.co'},
        syncRunner:
            ({
              required String supabaseUrl,
              required String supabaseAnonKey,
            }) async {
              syncCalls++;
            },
      );

      expect(synced, isFalse);
      expect(syncCalls, 0);
    },
  );
}

class _RecordingBackgroundSyncScheduler implements CalendarBackgroundScheduler {
  bool initialized = false;
  String? uniqueName;
  String? taskName;
  Duration? frequency;
  Map<String, dynamic>? inputData;
  bool? requiresNetwork;

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<void> registerPeriodicTask({
    required String uniqueName,
    required String taskName,
    required Duration frequency,
    required Map<String, dynamic> inputData,
    required bool requiresNetwork,
  }) async {
    this.uniqueName = uniqueName;
    this.taskName = taskName;
    this.frequency = frequency;
    this.inputData = inputData;
    this.requiresNetwork = requiresNetwork;
  }
}
