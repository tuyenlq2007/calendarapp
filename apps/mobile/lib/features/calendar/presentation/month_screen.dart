import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/calendar_entry.dart';

class MonthScreen extends StatelessWidget {
  const MonthScreen({
    super.key,
    required this.month,
    required this.selectedMonth,
    required this.currentMonth,
    required this.activeDate,
    this.onEntrySelected,
    this.onPreviousMonth,
    this.onNextMonth,
    this.onMonthSelected,
    this.onTodaySelected,
  });

  final CalendarMonth month;
  final DateTime selectedMonth;
  final DateTime currentMonth;
  final DateTime activeDate;
  final ValueChanged<CalendarEntry>? onEntrySelected;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final ValueChanged<DateTime>? onMonthSelected;
  final VoidCallback? onTodaySelected;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final practiceEntries = [
      for (final entry in month.entries)
        if (entry.isPracticeDay) entry,
    ]..sort((left, right) => left.day.compareTo(right.day));

    return CustomScrollView(
      key: const ValueKey('month-scroll'),
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: const Color(0xFF9B0F2E),
          foregroundColor: Colors.white,
          title: Text(month.title),
          actions: [
            IconButton(
              tooltip: 'Previous month',
              onPressed: onPreviousMonth,
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              tooltip: 'Next month',
              onPressed: onNextMonth,
              icon: const Icon(Icons.chevron_right),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Tooltip(
                message: 'Open today',
                child: TextButton(
                  onPressed: onTodaySelected,
                  child: Text(
                    localizations.today,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _MonthSelector(
                selectedMonth: selectedMonth,
                currentMonth: currentMonth,
                onMonthSelected: onMonthSelected,
              ),
              const SizedBox(height: 12),
              if (practiceEntries.isEmpty) ...[
                const Text('No practice days for this month yet.'),
                const SizedBox(height: 12),
              ],
              const _WeekdayHeader(),
              const SizedBox(height: 8),
              _MonthGrid(
                month: month,
                activeDate: activeDate,
                onEntrySelected: onEntrySelected,
              ),
              const SizedBox(height: 16),
              _EventList(
                entries: practiceEntries,
                onEntrySelected: onEntrySelected,
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.selectedMonth,
    required this.currentMonth,
    required this.onMonthSelected,
  });

  final DateTime selectedMonth;
  final DateTime currentMonth;
  final ValueChanged<DateTime>? onMonthSelected;

  static const _labels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final visibleMonths = [
      for (var offset = -3; offset < 3; offset++)
        DateTime(selectedMonth.year, selectedMonth.month + offset),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final visibleMonth in visibleMonths) ...[
            _MonthChip(
              visibleMonth: visibleMonth,
              label: _labels[visibleMonth.month - 1],
              selectedMonth: selectedMonth,
              currentMonth: currentMonth,
              onMonthSelected: onMonthSelected,
            ),
            if (visibleMonth != visibleMonths.last) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _MonthChip extends StatelessWidget {
  const _MonthChip({
    required this.visibleMonth,
    required this.label,
    required this.selectedMonth,
    required this.currentMonth,
    required this.onMonthSelected,
  });

  final DateTime visibleMonth;
  final String label;
  final DateTime selectedMonth;
  final DateTime currentMonth;
  final ValueChanged<DateTime>? onMonthSelected;

  @override
  Widget build(BuildContext context) {
    final month = visibleMonth.month;
    final isSelected =
        selectedMonth.year == visibleMonth.year &&
        selectedMonth.month == visibleMonth.month;
    final isCurrent =
        currentMonth.year == visibleMonth.year &&
        currentMonth.month == visibleMonth.month;
    final chip = ChoiceChip(
      key: ValueKey('month-chip-$month'),
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF9B0F2E),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF3A1717),
        fontWeight: isCurrent || isSelected ? FontWeight.w800 : FontWeight.w600,
      ),
      side: BorderSide(
        color: isCurrent ? const Color(0xFF9B0F2E) : const Color(0xFFE0C16F),
        width: isCurrent ? 2 : 1,
      ),
      onSelected: (_) => onMonthSelected?.call(visibleMonth),
    );

    Widget keyedChip = KeyedSubtree(
      key: isSelected
          ? ValueKey('month-chip-selected-$month')
          : ValueKey('month-chip-unselected-$month'),
      child: chip,
    );

    if (!isCurrent) return keyedChip;

    return KeyedSubtree(
      key: ValueKey('month-chip-current-$month'),
      child: keyedChip,
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
  const _MonthGrid({
    required this.month,
    required this.activeDate,
    required this.onEntrySelected,
  });

  final CalendarMonth month;
  final DateTime activeDate;
  final ValueChanged<CalendarEntry>? onEntrySelected;

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
        final isActive =
            activeDate.year == month.year &&
            activeDate.month == month.month &&
            activeDate.day == day;
        final cell = CalendarDayCell(
          key: ValueKey('day-cell-$day'),
          day: day,
          entry: entry,
          isActive: isActive,
          onTap: entry == null ? null : () => onEntrySelected?.call(entry),
        );
        if (!isActive) return cell;

        return KeyedSubtree(key: ValueKey('day-cell-active-$day'), child: cell);
      },
    );
  }
}

class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.day,
    required this.entry,
    required this.isActive,
    this.onTap,
  });

  final int day;
  final CalendarEntry? entry;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final background = isActive
        ? const Color(0xFF9B0F2E)
        : (entry?.isPracticeDay ?? false)
        ? const Color(0xFFFFE7A5)
        : Colors.white;
    final foreground = isActive ? Colors.white : const Color(0xFF3A1717);

    return Semantics(
      button: onTap != null,
      label: 'Day $day${entry == null ? '' : ', ${entry!.titleEn}'}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
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
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  const _EventList({required this.entries, required this.onEntrySelected});

  final List<CalendarEntry> entries;
  final ValueChanged<CalendarEntry>? onEntrySelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Practice days',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: const Color(0xFF8B0E2F)),
        ),
        const SizedBox(height: 8),
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              onTap: () => onEntrySelected?.call(entry),
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
              title: Text(
                entry.practiceDayTitle?.trim().isNotEmpty ?? false
                    ? entry.practiceDayTitle!.trim()
                    : 'Practice day',
              ),
              subtitle: entry.practiceDayDescription?.trim().isNotEmpty ?? false
                  ? Text(entry.practiceDayDescription!.trim())
                  : null,
            ),
          ),
      ],
    );
  }
}
