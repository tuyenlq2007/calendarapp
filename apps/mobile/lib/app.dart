import 'package:flutter/material.dart';

import 'features/calendar/domain/calendar_entry.dart';
import 'features/calendar/presentation/month_screen.dart';
import 'features/today/presentation/today_screen.dart';

class BaromKagyuCalendarApp extends StatelessWidget {
  const BaromKagyuCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barom Kagyu Calendar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF4D6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B0E2F),
          primary: const Color(0xFF8B0E2F),
          secondary: const Color(0xFFE0A526),
          surface: const Color(0xFFFFF4D6),
          onSurface: const Color(0xFF3A1717),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.w700),
          titleLarge: TextStyle(fontWeight: FontWeight.w700),
          bodyMedium: TextStyle(height: 1.35),
        ),
      ),
      home: const CalendarHomeScreen(),
    );
  }
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
    final screens = [
      TodayScreen(entry: sampleCalendarEntries.today),
      MonthScreen(month: sampleCalendarEntries),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Month',
          ),
          NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(Icons.spa),
            label: 'Practice',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
