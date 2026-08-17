import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/calendar_entry.dart';

class MonthScreen extends StatelessWidget {
  const MonthScreen({super.key, required this.month});

  final CalendarMonth month;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return CustomScrollView(
      key: const ValueKey('month-scroll'),
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: const Color(0xFF9B0F2E),
          foregroundColor: Colors.white,
          title: Text(month.title),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: Text(localizations.today)),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const _WeekdayHeader(),
              const SizedBox(height: 8),
              _MonthGrid(month: month),
              const SizedBox(height: 16),
              _EventList(entries: month.entries),
            ]),
          ),
        ),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      children: [
        for (final day in days)
          Expanded(
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: day == 'Sun'
                    ? const Color(0xFF9B0F2E)
                    : const Color(0xFF5E463D),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.month});

  final CalendarMonth month;

  @override
  Widget build(BuildContext context) {
    final totalCells = month.firstWeekdayOffset + month.daysInMonth;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        if (index < month.firstWeekdayOffset) {
          return const SizedBox.shrink();
        }

        final day = index - month.firstWeekdayOffset + 1;
        final entry = month.entryForDay(day);
        return CalendarDayCell(
          key: ValueKey('day-cell-$day'),
          day: day,
          entry: entry,
          isToday: day == month.today.day,
        );
      },
    );
  }
}

class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.day,
    required this.entry,
    required this.isToday,
  });

  final int day;
  final CalendarEntry? entry;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final background = isToday
        ? const Color(0xFF9B0F2E)
        : entry != null
        ? const Color(0xFFFFE7A5)
        : Colors.white;
    final foreground = isToday ? Colors.white : const Color(0xFF3A1717);

    return Semantics(
      label: 'Day $day${entry == null ? '' : ', ${entry!.titleEn}'}',
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE0C16F)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$day',
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            if (entry != null)
              Expanded(
                child: Text(
                  entry!.titleEn,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  const _EventList({required this.entries});

  final List<CalendarEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Practice days',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF8B0E2F),
          ),
        ),
        const SizedBox(height: 8),
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFFE4C987)),
              ),
              leading: CircleAvatar(
                backgroundColor: entry.isHighlighted
                    ? const Color(0xFF9B0F2E)
                    : const Color(0xFFE0A526),
                foregroundColor: Colors.white,
                child: Text('${entry.day}'),
              ),
              title: Text(entry.titleEn),
              subtitle: Text(entry.tibetanDateText),
            ),
          ),
      ],
    );
  }
}
