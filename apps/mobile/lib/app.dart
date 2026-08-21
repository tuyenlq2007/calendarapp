import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/calendar/data/calendar_database.dart';
import 'features/calendar/domain/calendar_entry.dart';
import 'features/calendar/presentation/month_screen.dart';
import 'features/reminders/domain/reminder_category.dart';
import 'features/settings/presentation/notification_settings_screen.dart';
import 'features/teachings/data/teaching_content_database.dart';
import 'features/teachings/presentation/teachings_screen.dart';
import 'features/today/presentation/today_screen.dart';
import 'l10n/app_localizations.dart';

class BaromKagyuCalendarApp extends StatelessWidget {
  const BaromKagyuCalendarApp({
    super.key,
    this.locale,
    this.calendarStore,
    this.syncCalendar,
    this.initialLastSyncedAt,
    this.teachingContentStore,
  });

  final Locale? locale;
  final Future<List<CalendarFeedRow>> Function()? calendarStore;
  final Future<DateTime> Function()? syncCalendar;
  final DateTime? initialLastSyncedAt;
  final Future<List<TeachingContentRow>> Function()? teachingContentStore;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barom Kagyu Calendar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: resolveBaromKagyuLocale,
      home: CalendarHomeScreen(
        calendarStore: calendarStore,
        syncCalendar: syncCalendar,
        initialLastSyncedAt: initialLastSyncedAt,
        teachingContentStore: teachingContentStore,
      ),
    );
  }
}

Locale resolveBaromKagyuLocale(
  List<Locale>? preferredLocales,
  Iterable<Locale> supportedLocales,
) {
  for (final preferredLocale in preferredLocales ?? const <Locale>[]) {
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == preferredLocale.languageCode) {
        return supportedLocale;
      }
    }
  }

  return const Locale('en');
}

class CalendarHomeScreen extends StatefulWidget {
  const CalendarHomeScreen({
    super.key,
    this.calendarStore,
    this.syncCalendar,
    this.initialLastSyncedAt,
    this.teachingContentStore,
  });

  final Future<List<CalendarFeedRow>> Function()? calendarStore;
  final Future<DateTime> Function()? syncCalendar;
  final DateTime? initialLastSyncedAt;
  final Future<List<TeachingContentRow>> Function()? teachingContentStore;

  @override
  State<CalendarHomeScreen> createState() => _CalendarHomeScreenState();
}

class _CalendarHomeScreenState extends State<CalendarHomeScreen> {
  int _selectedIndex = 0;
  Set<ReminderCategory> _enabledReminderCategories = const {
    ReminderCategory.dailyPractice,
    ReminderCategory.holyDays,
  };
  DateTime? _lastSyncedAt;
  bool _isSyncing = false;
  CalendarMonth _calendarMonth = sampleCalendarEntries;
  CalendarEntry? _selectedCalendarEntry;
  List<TeachingContentRow> _teachingContent = sampleTeachingContent;
  Set<String> _savedTeachingIds = const {};

  @override
  void initState() {
    super.initState();
    _lastSyncedAt = widget.initialLastSyncedAt;
    _loadStoredCalendar();
    _loadStoredTeachings();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final screens = [
      TodayScreen(
        monthTitle: _calendarMonth.title,
        entry: _selectedCalendarEntry ?? _calendarMonth.today,
      ),
      MonthScreen(month: _calendarMonth, onEntrySelected: _selectCalendarEntry),
      TeachingsScreen(
        items: _teachingContent,
        savedIds: _savedTeachingIds,
        onToggleSaved: _toggleSavedTeaching,
      ),
      NotificationSettingsScreen(
        enabled: _enabledReminderCategories,
        lastSyncedAt: _lastSyncedAt,
        isSyncing: _isSyncing,
        onRetrySync: widget.syncCalendar == null ? null : _retrySync,
        onChanged: (categories) {
          setState(() => _enabledReminderCategories = categories);
        },
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFF570005),
          border: Border(top: BorderSide(color: Color(0xFFAD2027))),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            height: 72,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                if (index == 0) {
                  _selectedCalendarEntry = null;
                }
                _selectedIndex = index;
              });
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.today_outlined),
                selectedIcon: const Icon(Icons.today),
                label: localizations.today,
              ),
              NavigationDestination(
                icon: const Icon(Icons.calendar_month_outlined),
                selectedIcon: const Icon(Icons.calendar_month),
                label: localizations.calendar,
              ),
              NavigationDestination(
                icon: const Icon(Icons.menu_book_outlined),
                selectedIcon: const Icon(Icons.menu_book),
                label: localizations.teachings,
              ),
              NavigationDestination(
                icon: const Icon(Icons.more_horiz),
                label: localizations.more,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _retrySync() async {
    final syncCalendar = widget.syncCalendar;
    if (syncCalendar == null || _isSyncing) return;

    setState(() => _isSyncing = true);
    try {
      final lastSyncedAt = await syncCalendar();
      if (!mounted) return;
      setState(() {
        _lastSyncedAt = lastSyncedAt;
        _isSyncing = false;
      });
      await _loadStoredCalendar();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).syncFailed)),
      );
    }
  }

  Future<void> _loadStoredCalendar() async {
    final calendarStore = widget.calendarStore;
    if (calendarStore == null) return;

    final rows = await calendarStore();
    if (!mounted) return;
    setState(() {
      _calendarMonth = calendarMonthFromFeedRows(rows);
      _selectedCalendarEntry = null;
    });
  }

  Future<void> _loadStoredTeachings() async {
    final teachingContentStore = widget.teachingContentStore;
    if (teachingContentStore == null) return;

    final rows = await teachingContentStore();
    if (!mounted) return;
    if (rows.isEmpty) return;
    setState(() {
      _teachingContent = rows;
    });
  }

  void _toggleSavedTeaching(String id) {
    setState(() {
      final savedIds = Set<String>.of(_savedTeachingIds);
      if (!savedIds.add(id)) {
        savedIds.remove(id);
      }
      _savedTeachingIds = savedIds;
    });
  }

  void _selectCalendarEntry(CalendarEntry entry) {
    setState(() {
      _selectedCalendarEntry = entry;
      _selectedIndex = 0;
    });
  }
}
