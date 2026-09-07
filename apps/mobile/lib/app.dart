import 'dart:async';

import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/calendar/data/calendar_database.dart';
import 'features/calendar/domain/calendar_entry.dart';
import 'features/calendar/presentation/month_screen.dart';
import 'features/community/data/community_database.dart';
import 'features/community/presentation/community_screen.dart';
import 'features/reminders/domain/reminder_category.dart';
import 'features/settings/presentation/notification_settings_screen.dart';
import 'features/teachings/data/online_teaching_database.dart';
import 'features/teachings/data/teaching_content_database.dart';
import 'features/teachings/presentation/teachings_screen.dart';
import 'features/today/presentation/today_screen.dart';
import 'l10n/app_localizations.dart';

class BaromKagyuCalendarApp extends StatelessWidget {
  const BaromKagyuCalendarApp({
    super.key,
    this.locale,
    this.currentDate,
    this.calendarStore,
    this.syncCalendar,
    this.initialLastSyncedAt,
    this.teachingContentStore,
    this.onlineTeachingStore,
    this.communityStore,
    this.autoSyncInterval = const Duration(hours: 1),
  });

  final Locale? locale;
  final DateTime? currentDate;
  final Future<List<CalendarFeedRow>> Function()? calendarStore;
  final Future<DateTime> Function()? syncCalendar;
  final DateTime? initialLastSyncedAt;
  final Future<List<TeachingContentRow>> Function()? teachingContentStore;
  final Future<List<OnlineTeachingRow>> Function()? onlineTeachingStore;
  final Future<List<CommunityEntryRow>> Function()? communityStore;
  final Duration? autoSyncInterval;

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
        onlineTeachingStore: onlineTeachingStore,
        communityStore: communityStore,
        autoSyncInterval: autoSyncInterval,
        currentDate: currentDate,
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
    this.onlineTeachingStore,
    this.communityStore,
    this.autoSyncInterval = const Duration(hours: 1),
    this.currentDate,
  });

  final Future<List<CalendarFeedRow>> Function()? calendarStore;
  final Future<DateTime> Function()? syncCalendar;
  final DateTime? initialLastSyncedAt;
  final Future<List<TeachingContentRow>> Function()? teachingContentStore;
  final Future<List<OnlineTeachingRow>> Function()? onlineTeachingStore;
  final Future<List<CommunityEntryRow>> Function()? communityStore;
  final Duration? autoSyncInterval;
  final DateTime? currentDate;

  @override
  State<CalendarHomeScreen> createState() => _CalendarHomeScreenState();
}

class _CalendarHomeScreenState extends State<CalendarHomeScreen>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  Set<ReminderCategory> _enabledReminderCategories = const {
    ReminderCategory.dailyPractice,
    ReminderCategory.holyDays,
  };
  DateTime? _lastSyncedAt;
  bool _isSyncing = false;
  DateTime _selectedMonth = DateTime(
    sampleCalendarEntries.year,
    sampleCalendarEntries.month,
  );
  List<CalendarFeedRow> _calendarRows = const [];
  DateTime? _selectedDate;
  CalendarEntry? _selectedCalendarEntry;
  List<TeachingContentRow> _teachingContent = const [];
  List<OnlineTeachingRow> _onlineTeachings = const [];
  List<CommunityEntryRow> _communityEntries = const [];
  Set<String> _savedTeachingIds = const {};
  Timer? _autoSyncTimer;
  DateTime? _lastAutoSyncAttemptAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lastSyncedAt = widget.initialLastSyncedAt;
    _loadStoredCalendar();
    _loadStoredTeachings();
    _loadOnlineTeachings();
    _loadCommunityEntries();
    _startAutoSyncTimer();
    unawaited(_syncAndRefresh());
  }

  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _maybeAutoSync();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final calendarMonth = _visibleCalendarMonth();
    final currentDate = _currentDateForDisplay();
    final todayDisplayDate = _selectedDate ?? currentDate;
    final isViewingSelectedDay = _isViewingSelectedDay(currentDate);
    final screens = [
      TodayScreen(
        monthTitle:
            '${_monthName(todayDisplayDate.month)} ${todayDisplayDate.year}',
        displayDate: todayDisplayDate,
        entry: _selectedDate == null
            ? _currentDayEntry()
            : _selectedCalendarEntry,
        showTodayButton: isViewingSelectedDay,
        onTodaySelected: _selectToday,
        onPreviousDaySelected: _selectPreviousDay,
        onNextDaySelected: _selectNextDay,
      ),
      MonthScreen(
        month: calendarMonth,
        selectedMonth: _selectedMonth,
        currentMonth: DateTime(currentDate.year, currentDate.month),
        activeDate: _activeDate(),
        onEntrySelected: _selectCalendarEntry,
        onPreviousMonth: _selectPreviousMonth,
        onNextMonth: _selectNextMonth,
        onMonthSelected: _selectMonth,
        onTodaySelected: _selectToday,
      ),
      TeachingsScreen(
        items: _teachingContent,
        onlineTeachings: _onlineTeachings,
        savedIds: _savedTeachingIds,
        currentDate: widget.currentDate,
        isActive: _selectedIndex == 2,
        onToggleSaved: _toggleSavedTeaching,
      ),
      CommunityScreen(items: _communityEntries),
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
            onDestinationSelected: _selectDestination,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.today_outlined),
                selectedIcon: const Icon(Icons.today),
                label: isViewingSelectedDay ? 'Day' : localizations.today,
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
                icon: const Icon(Icons.groups_outlined),
                selectedIcon: const Icon(Icons.groups),
                label: localizations.community,
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
    await _syncAndRefresh(showFailureSnackBar: true);
  }

  void _startAutoSyncTimer() {
    final interval = widget.autoSyncInterval;
    if (widget.syncCalendar == null ||
        interval == null ||
        interval <= Duration.zero) {
      return;
    }

    _autoSyncTimer = Timer.periodic(
      interval,
      (_) => _maybeAutoSync(force: true),
    );
  }

  void _maybeAutoSync({bool force = false}) {
    final interval = widget.autoSyncInterval;
    if (widget.syncCalendar == null ||
        interval == null ||
        interval <= Duration.zero ||
        _isSyncing) {
      return;
    }

    final now = DateTime.now();
    final lastAttempt = _lastAutoSyncAttemptAt;
    if (!force &&
        lastAttempt != null &&
        now.difference(lastAttempt) < interval) {
      return;
    }

    _lastAutoSyncAttemptAt = now;
    unawaited(_syncAndRefresh());
  }

  Future<void> _syncAndRefresh({bool showFailureSnackBar = false}) async {
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
      await _loadStoredTeachings();
      await _loadOnlineTeachings();
      await _loadCommunityEntries();
    } catch (error, stackTrace) {
      debugPrint('Calendar sync failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() => _isSyncing = false);
      if (showFailureSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).syncFailed)),
        );
      }
    }
  }

  Future<void> _loadStoredCalendar() async {
    final calendarStore = widget.calendarStore;
    if (calendarStore == null) return;

    final rows = await calendarStore();
    if (!mounted) return;
    setState(() {
      _calendarRows = rows;
      if (rows.isNotEmpty) {
        final firstDate = rows.first.gregorianDate;
        _selectedMonth = DateTime(firstDate.year, firstDate.month);
      }
      _selectedDate = null;
      _selectedCalendarEntry = null;
    });
  }

  Future<void> _loadStoredTeachings() async {
    final teachingContentStore = widget.teachingContentStore;
    if (teachingContentStore == null) return;

    final rows = await teachingContentStore();
    if (!mounted) return;
    setState(() {
      _teachingContent = rows;
    });
  }

  Future<void> _loadOnlineTeachings() async {
    final onlineTeachingStore = widget.onlineTeachingStore;
    if (onlineTeachingStore == null) return;

    try {
      final rows = await onlineTeachingStore();
      if (!mounted) return;
      setState(() {
        _onlineTeachings = rows;
      });
    } catch (error, stackTrace) {
      debugPrint('Online teachings sync failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
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
      _selectedDate = DateTime(
        _selectedMonth.year,
        _selectedMonth.month,
        entry.day,
      );
      _selectedCalendarEntry = entry;
      _selectedIndex = 0;
    });
  }

  bool _isViewingSelectedDay(DateTime currentDate) {
    final selectedDate = _selectedDate;
    if (selectedDate == null) return false;

    return !_isSameDate(selectedDate, currentDate);
  }

  DateTime _currentDate() {
    final now = widget.currentDate ?? DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _currentDateForDisplay() {
    if (widget.currentDate == null && _shouldUseSampleCalendar) {
      return DateTime(
        sampleCalendarEntries.year,
        sampleCalendarEntries.month,
        sampleCalendarEntries.today.day,
      );
    }

    return _currentDate();
  }

  CalendarEntry? _currentDayEntry() {
    final currentDate = _currentDateForDisplay();
    return _entryForDate(currentDate);
  }

  Future<void> _loadCommunityEntries() async {
    final communityStore = widget.communityStore;
    if (communityStore == null) return;

    try {
      final rows = await communityStore();
      if (!mounted) return;
      setState(() {
        _communityEntries = rows;
      });
    } catch (error, stackTrace) {
      debugPrint('Community sync failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _communityEntries = const [];
      });
    }
  }

  CalendarEntry? _entryForDate(DateTime currentDate) {
    for (final row in _calendarRows) {
      final date = row.gregorianDate;
      if (!row.isWithdrawn &&
          date.year == currentDate.year &&
          date.month == currentDate.month &&
          date.day == currentDate.day) {
        return calendarEntryFromFeedRow(row);
      }
    }

    if (_shouldUseSampleCalendar &&
        currentDate.year == sampleCalendarEntries.year &&
        currentDate.month == sampleCalendarEntries.month &&
        currentDate.day == sampleCalendarEntries.today.day) {
      return sampleCalendarEntries.today;
    }

    return null;
  }

  CalendarMonth _visibleCalendarMonth() {
    if (_shouldUseSampleCalendar) {
      if (_selectedMonth.year == sampleCalendarEntries.year &&
          _selectedMonth.month == sampleCalendarEntries.month) {
        return sampleCalendarEntries;
      }

      return calendarMonthFromFeedRowsForMonth(const [], _selectedMonth);
    }

    return calendarMonthFromFeedRowsForMonth(_calendarRows, _selectedMonth);
  }

  bool get _shouldUseSampleCalendar {
    return widget.calendarStore == null && _calendarRows.isEmpty;
  }

  void _selectPreviousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      _selectedDate = null;
      _selectedCalendarEntry = null;
    });
  }

  void _selectNextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      _selectedDate = null;
      _selectedCalendarEntry = null;
    });
  }

  void _selectMonth(DateTime month) {
    setState(() {
      _selectedMonth = DateTime(month.year, month.month);
      _selectedDate = null;
      _selectedCalendarEntry = null;
    });
  }

  void _selectToday() {
    final currentDate = _currentDateForDisplay();
    setState(() {
      _selectedMonth = DateTime(currentDate.year, currentDate.month);
      _selectedDate = null;
      _selectedCalendarEntry = null;
      _selectedIndex = 0;
    });
  }

  void _selectPreviousDay() {
    _selectRelativeDay(-1);
  }

  void _selectNextDay() {
    _selectRelativeDay(1);
  }

  void _selectRelativeDay(int dayOffset) {
    final baseDate = _selectedDate ?? _currentDateForDisplay();
    final nextDate = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day + dayOffset,
    );
    setState(() {
      _selectedDate = nextDate;
      _selectedMonth = DateTime(nextDate.year, nextDate.month);
      _selectedCalendarEntry = _entryForDate(nextDate);
      _selectedIndex = 0;
    });
  }

  void _selectDestination(int index) {
    setState(() {
      if (index == 1) {
        final activeDate = _activeDate();
        _selectedMonth = DateTime(activeDate.year, activeDate.month);
      }
      _selectedIndex = index;
    });
  }

  DateTime _activeDate() {
    return _selectedDate ?? _currentDate();
  }

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  String _monthName(int month) {
    return switch (month) {
      DateTime.january => 'January',
      DateTime.february => 'February',
      DateTime.march => 'March',
      DateTime.april => 'April',
      DateTime.may => 'May',
      DateTime.june => 'June',
      DateTime.july => 'July',
      DateTime.august => 'August',
      DateTime.september => 'September',
      DateTime.october => 'October',
      DateTime.november => 'November',
      DateTime.december => 'December',
      _ => '',
    };
  }
}
