import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/app.dart';
import 'package:mobile/features/calendar/data/calendar_database.dart';
import 'package:mobile/features/teachings/data/online_teaching_database.dart';
import 'package:mobile/features/teachings/data/teaching_content_database.dart';

void main() {
  testWidgets('today screen shows bilingual Barom Kagyu calendar content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BaromKagyuCalendarApp());

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Scaffold &&
            widget.backgroundColor == const Color(0xFFF4D990),
        description: 'yellow parchment Today scaffold',
      ),
      findsOneWidget,
    );
    expect(find.text('February 2021'), findsOneWidget);
    expect(find.text('22'), findsOneWidget);
    expect(find.text('Guru Rinpoche day'), findsOneWidget);
    expect(
      find.textContaining('Bad day for hanging prayer flags'),
      findsOneWidget,
    );
    expect(find.textContaining('Gyalwang Drukpa'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/barom_kagyu_logo.png',
        description: 'Barom Kagyu logo asset image',
      ),
      findsOneWidget,
    );
    expect(find.text('Select Day'), findsNothing);
    expect(find.text('Water - Wind'), findsOneWidget);
    expect(find.text('Negative Elemental Combination'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
    expect(find.text('Year'), findsOneWidget);
    expect(find.text('Barom Kagyu'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
  });

  testWidgets('today screen renders the database-backed element Tibetan line', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BaromKagyuCalendarApp(
        currentDate: DateTime(2026, 8, 24),
        calendarStore: () async => [
          CalendarFeedRow(
            id: 'element-entry',
            version: 1,
            gregorianDate: DateTime(2026, 8, 24),
            tibetanDateText: '10th lunar day',
            titleEn: 'Element Practice',
            titleBo: 'དུས་ཆེན།',
            descriptionEn: 'Good day for practice.',
            descriptionBo: '',
            elementTibetanLine:
                'ས་ཆུ་འཕྲད་པ་བདེ་སྐྱིད། ས་ཆུ་སྦྱོར་བས་དགེ་བ་འཕེལ།',
            elementPairEn: 'Water - Water',
            elementCombinationTitleEn: 'Auspicious Element Combination',
            elementDescriptionEn: "This elemental combination strengthens and extends one's life.",
            status: 'published',
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('ས་ཆུ་འཕྲད་པ་བདེ་སྐྱིད། ས་ཆུ་སྦྱོར་བས་དགེ་བ་འཕེལ།'),
      findsOneWidget,
    );
    expect(find.text('Water - Water'), findsNWidgets(2));
    expect(find.text('Auspicious Element Combination'), findsOneWidget);
    expect(
      find.text(
        "This elemental combination strengthens and extends one's life.",
      ),
      findsOneWidget,
    );
    expect(find.text('Water - Wind'), findsNothing);
  });

  testWidgets(
    'today screen uses database-backed Tibetan date detail metadata',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        BaromKagyuCalendarApp(
          currentDate: DateTime(2026, 8, 24),
          calendarStore: () async => [
            CalendarFeedRow(
              id: 'metadata-entry',
              version: 1,
              gregorianDate: DateTime(2026, 8, 24),
              tibetanDateText: '10th lunar day',
              titleEn: 'Avoid business deal; Good day for fire puja',
              titleBo: 'Published Tibetan title',
              descriptionEn: 'Barom Kagyu quote',
              descriptionBo: '',
              elementPairEn: 'Water - Water',
              monthNumberText: '7',
              monthElementAnimalEn: 'Fire Dog',
              yearNumberText: '2153',
              yearElementAnimalEn: 'Fire Horse',
              status: 'published',
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Water - Water'), findsNWidgets(2));
      expect(find.text('Fire Dog'), findsOneWidget);
      expect(find.text('Fire Horse'), findsOneWidget);
      expect(
        find.text('We are the heirs of our own actions\n~ The Buddha ~'),
        findsNothing,
      );

      final quote = tester.widget<Text>(find.text('Barom Kagyu quote'));
      expect(quote.style?.color, const Color(0xFF087326));
      expect(quote.style?.fontStyle, FontStyle.italic);
    },
  );

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

  testWidgets('calendar month arrows move between adjacent months', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BaromKagyuCalendarApp(
        currentDate: DateTime(2026, 8, 22),
        calendarStore: () async => [
          CalendarFeedRow(
            id: 'august-entry',
            version: 1,
            gregorianDate: DateTime(2026, 8, 22),
            tibetanDateText: '10th lunar day',
            titleEn: 'August Cloud Practice',
            titleBo: 'August Tibetan title',
            descriptionEn: 'Loaded from Supabase.',
            descriptionBo: '',
            status: 'published',
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();

    expect(find.text('August 2026'), findsOneWidget);

    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();

    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text('No practice days for this month yet.'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();

    expect(find.text('August 2026'), findsOneWidget);
    expect(find.text('August Cloud Practice'), findsOneWidget);
  });

  testWidgets(
    'calendar month selector highlights selected and current months',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        BaromKagyuCalendarApp(
          currentDate: DateTime(2026, 8, 22),
          calendarStore: () async => [
            CalendarFeedRow(
              id: 'august-entry',
              version: 1,
              gregorianDate: DateTime(2026, 8, 22),
              tibetanDateText: '10th lunar day',
              titleEn: 'August Cloud Practice',
              titleBo: 'August Tibetan title',
              descriptionEn: 'Loaded from Supabase.',
              descriptionBo: '',
              status: 'published',
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('month-chip-current-8')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('month-chip-selected-8')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('month-chip-5')), findsOneWidget);
      expect(find.byKey(const ValueKey('month-chip-6')), findsOneWidget);
      expect(find.byKey(const ValueKey('month-chip-7')), findsOneWidget);
      expect(find.byKey(const ValueKey('month-chip-8')), findsOneWidget);
      expect(find.byKey(const ValueKey('month-chip-9')), findsOneWidget);
      expect(find.byKey(const ValueKey('month-chip-10')), findsOneWidget);
      expect(find.byKey(const ValueKey('month-chip-11')), findsNothing);
      expect(find.byKey(const ValueKey('month-chip-12')), findsNothing);
      expect(find.byType(Wrap), findsNothing);

      final firstChipCenter = tester.getCenter(
        find.byKey(const ValueKey('month-chip-5')),
      );
      for (final month in [6, 7, 8, 9, 10]) {
        expect(
          tester.getCenter(find.byKey(ValueKey('month-chip-$month'))).dy,
          closeTo(firstChipCenter.dy, 1),
        );
      }

      await tester.tap(find.text('Oct'));
      await tester.pumpAndSettle();

      expect(find.text('October 2026'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('month-chip-current-8')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('month-chip-selected-10')),
        findsOneWidget,
      );
    },
  );

  testWidgets('calendar header Today opens Today tab with current day', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BaromKagyuCalendarApp(
        currentDate: DateTime(2026, 8, 22),
        calendarStore: () async => [
          CalendarFeedRow(
            id: 'current-day-entry',
            version: 1,
            gregorianDate: DateTime(2026, 8, 22),
            tibetanDateText: '10th lunar day',
            titleEn: 'Current Cloud Practice',
            titleBo: 'Current Tibetan title',
            descriptionEn: 'Practice for the real current day.',
            descriptionBo: '',
            status: 'published',
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open today'));
    await tester.pumpAndSettle();

    expect(find.text('Current Cloud Practice'), findsOneWidget);
    expect(find.text('22'), findsWidgets);
    expect(find.text('Calendar'), findsOneWidget);
  });

  testWidgets('calendar day selection replaces and resets today content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BaromKagyuCalendarApp());

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const ValueKey('month-scroll')),
      const Offset(0, -220),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('day-cell-25')));
    await tester.pumpAndSettle();

    expect(find.text('Dakini day'), findsOneWidget);
    expect(find.text('Guru Rinpoche day'), findsNothing);
    expect(find.text('Day'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Today'));
    await tester.pumpAndSettle();

    expect(find.text('Guru Rinpoche day'), findsOneWidget);
    expect(find.text('Dakini day'), findsNothing);
    expect(find.text('Day'), findsNothing);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets(
    'selected day header uses selected month instead of today month',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        BaromKagyuCalendarApp(
          currentDate: DateTime(2026, 8, 22),
          calendarStore: () async => [
            CalendarFeedRow(
              id: 'july-entry',
              version: 1,
              gregorianDate: DateTime(2026, 7, 25),
              tibetanDateText: 'July lunar day',
              titleEn: 'July Selected Practice',
              titleBo: 'July Tibetan title',
              descriptionEn: 'Selected from another month.',
              descriptionBo: '',
              status: 'published',
            ),
            CalendarFeedRow(
              id: 'august-entry',
              version: 2,
              gregorianDate: DateTime(2026, 8, 22),
              tibetanDateText: 'August lunar day',
              titleEn: 'August Current Practice',
              titleBo: 'August Tibetan title',
              descriptionEn: 'Current day practice.',
              descriptionBo: '',
              status: 'published',
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('August 2026'), findsOneWidget);

      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('day-cell-25')));
      await tester.pumpAndSettle();

      expect(find.text('July Selected Practice'), findsOneWidget);
      expect(find.text('Day'), findsOneWidget);
      expect(find.text('July 2026'), findsOneWidget);
      expect(find.text('August 2026'), findsNothing);
    },
  );

  testWidgets('today header aligns month left and brand right', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BaromKagyuCalendarApp());

    final brandFinder = find.text('Barom Kagyu');
    final monthFinder = find.text('February 2021');
    final todayScaffoldFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Scaffold &&
          widget.backgroundColor == const Color(0xFFF4D990),
      description: 'yellow parchment Today scaffold',
    );

    final brandTopRight = tester.getTopRight(brandFinder);
    final monthTopLeft = tester.getTopLeft(monthFinder);
    final brandCenter = tester.getCenter(brandFinder);
    final monthCenter = tester.getCenter(monthFinder);
    final scaffoldTopRight = tester.getTopRight(todayScaffoldFinder);
    final brandText = tester.widget<Text>(brandFinder);
    final monthText = tester.widget<Text>(monthFinder);
    final brandFontSize = brandText.style!.fontSize!;
    final monthFontSize = monthText.style!.fontSize!;

    expect(monthTopLeft.dx, lessThan(24));
    expect(brandTopRight.dx, greaterThan(scaffoldTopRight.dx - 24));
    expect(monthCenter.dy, closeTo(brandCenter.dy, 1));
    expect(brandFontSize, lessThan(monthFontSize));
    expect(brandText.style?.fontStyle, isNot(FontStyle.italic));
  });

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

  testWidgets('selected weekday centers above the large day number', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BaromKagyuCalendarApp());

    final weekdayCenter = tester.getCenter(find.text('MONDAY')).dx;
    final dayCenter = tester.getCenter(find.text('22')).dx;

    expect(weekdayCenter, closeTo(dayCenter, 1));
  });

  testWidgets('date text is smaller and day bottom aligns with logo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BaromKagyuCalendarApp());

    final weekdayFinder = find.text('MONDAY');
    final dayFinder = find.text('22');
    final dayBottom = tester.getBottomLeft(dayFinder).dy;
    final logoFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName ==
              'assets/images/barom_kagyu_logo.png',
      description: 'Barom Kagyu logo asset image',
    );
    final logoBottom = tester.getBottomLeft(logoFinder).dy;
    final weekdayText = tester.widget<Text>(weekdayFinder);
    final dayText = tester.widget<Text>(dayFinder);
    final weekdayFontSize = weekdayText.style!.fontSize!;
    final dayFontSize = dayText.style!.fontSize!;

    expect(weekdayFontSize, 24);
    expect(dayFontSize, 140);
    expect(logoBottom, closeTo(dayBottom, 2));
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
    expect(find.text('ཆོས་ཁྲིད།'), findsOneWidget);
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

    await tester.tap(find.text('Teachings'));
    await tester.pumpAndSettle();
    expect(find.text('Teachings'), findsWidgets);
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
        currentDate: DateTime(2026, 8, 17),
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

  testWidgets('teachings tab bookmarks offline-eligible articles', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BaromKagyuCalendarApp(
        teachingContentStore: () async => [
          TeachingContentRow(
            id: 'refuge-practice',
            version: 1,
            slug: 'refuge-practice',
            type: 'article',
            category: 'Practice',
            titleEn: 'Refuge Practice',
            titleBo: 'སྐྱབས་འགྲོ།',
            summaryEn: 'A short teaching for daily practice.',
            summaryBo: 'ཉིན་རེའི་ཆོས་ཁྲིད།',
            bodyEn: 'Take refuge with clear motivation.',
            bodyBo: 'དགོངས་པ་གསལ་པོས་སྐྱབས་འགྲོ་བྱ།',
            youtubeUrl: null,
            imageUrl: null,
            offlineEligible: true,
            status: 'published',
          ),
          TeachingContentRow(
            id: 'lineage-video',
            version: 2,
            slug: 'lineage-video',
            type: 'video',
            category: 'Lineage',
            titleEn: 'Lineage Teaching Video',
            titleBo: 'བརྒྱུད་པའི་ཆོས་ཁྲིད།',
            summaryEn: 'A YouTube teaching for online viewing.',
            summaryBo: 'དྲ་ཐོག་གཟིགས་རྒྱུའི་ཆོས་ཁྲིད།',
            bodyEn: '',
            bodyBo: '',
            youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
            imageUrl: null,
            offlineEligible: false,
            status: 'published',
          ),
        ],
      ),
    );

    await tester.tap(find.text('Teachings'));
    await tester.pumpAndSettle();

    expect(find.text('Refuge Practice'), findsOneWidget);
    expect(find.text('Lineage Teaching Video'), findsOneWidget);
    expect(find.text('YouTube'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Save offline'));
    await tester.pumpAndSettle();

    expect(find.text('Saved library'), findsOneWidget);
    expect(find.text('Saved offline'), findsOneWidget);
  });

  testWidgets('teachings tab keeps sample content before sync data exists', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BaromKagyuCalendarApp(teachingContentStore: () async => []),
    );

    await tester.tap(find.text('Teachings'));
    await tester.pumpAndSettle();

    expect(find.text('Refuge Practice'), findsOneWidget);
    expect(find.text('Lineage Teaching Video'), findsOneWidget);
  });

  testWidgets('teachings tab keeps fallback content when online load fails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BaromKagyuCalendarApp(
        onlineTeachingStore: () async {
          throw const FormatException('online teachings table missing');
        },
      ),
    );

    await tester.tap(find.text('Teachings'));
    await tester.pumpAndSettle();

    expect(find.text('Bilingual teachings'), findsOneWidget);
    expect(find.text('Refuge Practice'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('teachings tab shows online teaching cards with status buttons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BaromKagyuCalendarApp(
        onlineTeachingStore: () async => [
          OnlineTeachingRow(
            id: 'long-life-prayer',
            title: 'Prayer for the Long Life of His Holiness',
            practice: 'Recite the Sutra of Boundless Life and Wisdom',
            startDate: DateTime(2026, 7, 6),
            endDate: DateTime(2026, 12, 31),
            status: OnlineTeachingStatus.ongoing,
            joinUrl: Uri.parse('https://us02web.zoom.us/j/9461447283'),
            displayOrder: 1,
            published: true,
          ),
          OnlineTeachingRow(
            id: 'medicine-buddha',
            title: 'Medicine Buddha Practice',
            practice: 'Daily Medicine Buddha mantra recitation and dedication',
            startDate: DateTime(2026, 9),
            endDate: DateTime(2026, 9, 30),
            status: OnlineTeachingStatus.upcoming,
            joinUrl: Uri.parse('https://us02web.zoom.us/j/9461447283'),
            displayOrder: 2,
            published: true,
          ),
          OnlineTeachingRow(
            id: 'guru-rinpoche-tsok',
            title: 'Guru Rinpoche Tsok Practice',
            practice:
                'Monthly Guru Rinpoche prayers, tsok, and aspiration practice',
            startDate: DateTime(2026, 6, 10),
            endDate: DateTime(2026, 8, 10),
            status: OnlineTeachingStatus.finished,
            joinUrl: Uri.parse('https://us02web.zoom.us/j/9461447283'),
            displayOrder: 3,
            published: true,
          ),
        ],
      ),
    );

    await tester.tap(find.text('Teachings'));
    await tester.pumpAndSettle();

    expect(find.text('Online Teachings'), findsOneWidget);
    expect(
      find.text('Prayer for the Long Life of His Holiness'),
      findsOneWidget,
    );
    expect(find.text('Practice:'), findsWidgets);
    expect(find.text('Ongoing'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Finished'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'JOIN NOW'), findsNWidgets(3));

    final buttons = tester.widgetList<FilledButton>(
      find.widgetWithText(FilledButton, 'JOIN NOW'),
    );

    expect(buttons.elementAt(0).onPressed, isNotNull);
    expect(buttons.elementAt(1).onPressed, isNull);
    expect(buttons.elementAt(2).onPressed, isNull);
  });
}
