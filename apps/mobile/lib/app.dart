import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/calendar/domain/calendar_entry.dart';
import 'features/calendar/presentation/month_screen.dart';
import 'features/today/presentation/today_screen.dart';
import 'l10n/app_localizations.dart';

class BaromKagyuCalendarApp extends StatelessWidget {
  const BaromKagyuCalendarApp({super.key, this.locale});

  final Locale? locale;

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
      home: const CalendarHomeScreen(),
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
  const CalendarHomeScreen({super.key});

  @override
  State<CalendarHomeScreen> createState() => _CalendarHomeScreenState();
}

class _CalendarHomeScreenState extends State<CalendarHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final screens = [
      TodayScreen(entry: sampleCalendarEntries.today),
      MonthScreen(month: sampleCalendarEntries),
      _SectionScreen(title: localizations.practice),
      _SectionScreen(title: localizations.more),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
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
            icon: const Icon(Icons.spa_outlined),
            selectedIcon: const Icon(Icons.spa),
            label: localizations.practice,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz),
            label: localizations.more,
          ),
        ],
      ),
    );
  }
}

class _SectionScreen extends StatelessWidget {
  const _SectionScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
