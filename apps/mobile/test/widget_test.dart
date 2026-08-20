import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/app.dart';
import 'package:mobile/features/calendar/data/calendar_database.dart';

void main() {
  testWidgets('today screen shows bilingual Barom Kagyu calendar content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BaromKagyuCalendarApp());

    expect(find.text('February 2021'), findsOneWidget);
    expect(find.text('22'), findsOneWidget);
    expect(find.text('Guru Rinpoche day'), findsOneWidget);
    expect(
      find.textContaining('Bad day for hanging prayer flags'),
      findsOneWidget,
    );
    expect(find.text('Select Day'), findsOneWidget);
    expect(find.text('Water - Wind'), findsOneWidget);
    expect(find.text('Negative Elemental Combination'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
    expect(find.text('Year'), findsOneWidget);
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Calendar'), findsOneWidget);
  });

  testWidgets(
    'month tab shows a seven column calendar grid with practice days',
    (WidgetTester tester) async {
      await tester.pumpWidget(const BaromKagyuCalendarApp());

      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Sun'), findsOneWidget);
      expect(find.byKey(const ValueKey('day-cell-22')), findsOneWidget);

      expect(find.text('Dakini day'), findsOneWidget);
      await tester.drag(
        find.byKey(const ValueKey('month-scroll')),
        const Offset(0, -700),
      );
      await tester.pumpAndSettle();
      expect(find.text('Dharma Protector day'), findsOneWidget);
    },
  );

  testWidgets('calendar UI remains usable with large text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: const BaromKagyuCalendarApp(),
      ),
    );

    expect(find.text('Guru Rinpoche day'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unsupported locales fall back to English navigation labels', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BaromKagyuCalendarApp(locale: Locale('vi')));

    expect(find.text('Today'), findsWidgets);
    expect(find.text('Calendar'), findsOneWidget);
  });

  test('locale resolution uses supported secondary platform locales', () {
    final locale = resolveBaromKagyuLocale(
      const [Locale('vi'), Locale('bo')],
      const [Locale('en'), Locale('bo')],
    );

    expect(locale, const Locale('bo'));
  });

  testWidgets('Tibetan locale localizes navigation labels', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BaromKagyuCalendarApp(locale: Locale('bo')));

    expect(find.text('དེ་རིང་།'), findsWidgets);
    expect(find.text('ལོ་ཐོ།'), findsOneWidget);
    expect(find.text('སྒྲུབ་པ།'), findsOneWidget);
    expect(find.text('དེ་ལས་མང་བ།'), findsOneWidget);
  });

  testWidgets('Tibetan locale localizes sync status labels', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BaromKagyuCalendarApp(locale: Locale('bo')));

    await tester.tap(find.text('དེ་ལས་མང་བ།'));
    await tester.pumpAndSettle();

    expect(find.text('མཉམ་སྦྲེལ་གནས་ཚུལ།'), findsOneWidget);
    expect(find.text('ད་དུང་གསར་སྒྱུར་བྱས་མེད།'), findsOneWidget);
    expect(find.text('ཡང་བསྐྱར།'), findsOneWidget);
  });

  testWidgets('all navigation destinations have matching screens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BaromKagyuCalendarApp());

    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();
    expect(find.text('Practice'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.text('More'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('more tab exposes notification category settings', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BaromKagyuCalendarApp());

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Sync status'), findsOneWidget);
    expect(find.text('Not updated yet'), findsOneWidget);
    expect(find.text('Daily practice'), findsOneWidget);
    expect(find.text('Holy days'), findsOneWidget);
  });

  testWidgets('sync retry updates the sync status timestamp', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BaromKagyuCalendarApp(
        syncCalendar: () async => DateTime(2026, 8, 17, 9, 30),
      ),
    );

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Last updated:'), findsOneWidget);
  });

  testWidgets('sync retry reloads published entries from the calendar store', (
    WidgetTester tester,
  ) async {
    var rows = <CalendarFeedRow>[];

    await tester.pumpWidget(
      BaromKagyuCalendarApp(
        calendarStore: () async => rows,
        syncCalendar: () async {
          rows = [
            CalendarFeedRow(
              id: 'published-entry',
              version: 2,
              gregorianDate: DateTime(2026, 8, 17),
              tibetanDateText: '10th lunar day',
              titleEn: 'Published from Supabase',
              titleBo: 'Published Tibetan title',
              descriptionEn: 'Loaded after a successful sync.',
              descriptionBo: '',
              status: 'published',
            ),
          ];
          return DateTime(2026, 8, 17, 9, 30);
        },
      ),
    );

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();

    expect(find.text('August 2026'), findsOneWidget);
    expect(find.text('Published from Supabase'), findsOneWidget);
  });

  testWidgets('failed sync keeps the existing sync status timestamp', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BaromKagyuCalendarApp(
        initialLastSyncedAt: DateTime(2026, 8, 17, 9, 30),
        syncCalendar: () async => throw const FormatException('offline'),
      ),
    );

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Last updated:'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Last updated:'), findsOneWidget);
    expect(
      find.text('Sync failed. Existing calendar content was kept.'),
      findsOneWidget,
    );
  });

  testWidgets('notification category settings toggle values', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BaromKagyuCalendarApp());

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    final dailyPracticeFinder = find.widgetWithText(
      CheckboxListTile,
      'Daily practice',
    );
    expect(tester.widget<CheckboxListTile>(dailyPracticeFinder).value, isTrue);

    await tester.tap(dailyPracticeFinder);
    await tester.pumpAndSettle();

    expect(tester.widget<CheckboxListTile>(dailyPracticeFinder).value, isFalse);
  });
}
