import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/app.dart';

void main() {
  testWidgets('today screen shows bilingual Barom Kagyu calendar content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BaromKagyuCalendarApp());

    expect(find.text('February 2021'), findsOneWidget);
    expect(find.text('22'), findsOneWidget);
    expect(find.text('Guru Rinpoche day'), findsOneWidget);
    expect(find.text('བོད་ཟླ ༡༠ ཚེས ༡༠'), findsOneWidget);
    expect(find.textContaining('Bad day for hanging prayer flags'), findsOneWidget);
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Calendar'), findsOneWidget);
  });

  testWidgets('month tab shows a seven column calendar grid with practice days', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BaromKagyuCalendarApp());

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();

    expect(find.text('Mon'), findsOneWidget);
    expect(find.text('Sun'), findsOneWidget);
    expect(find.byKey(const ValueKey('day-cell-22')), findsOneWidget);

    expect(find.text('Dakini day'), findsOneWidget);
    await tester.drag(find.byKey(const ValueKey('month-scroll')), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Dharma Protector day'), findsOneWidget);
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
}
