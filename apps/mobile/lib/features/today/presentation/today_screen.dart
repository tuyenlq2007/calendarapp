import 'package:flutter/material.dart';

import '../../calendar/domain/calendar_entry.dart';

const _pageRed = Color(0xFF610005);
const _panelRed = Color(0xFF790006);
const _panelDarkRed = Color(0xFF570005);
const _borderRed = Color(0xFFAD2027);
const _gold = Color(0xFFF6D985);
const _white = Color(0xFFFFFDF8);

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.monthTitle, required this.entry});

  final String monthTitle;
  final CalendarEntry entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageRed,
      body: SafeArea(
        child: SingleChildScrollView(
          key: const ValueKey('today-scroll'),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
          child: Column(
            children: [
              _TopHeader(monthTitle: monthTitle),
              const SizedBox(height: 18),
              _SelectedDayPanel(entry: entry),
              const SizedBox(height: 10),
              const _ElementPanel(),
              const SizedBox(height: 10),
              _TibetanDateDetails(entry: entry),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({required this.monthTitle});

  final String monthTitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 8,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Select Day',
              maxLines: 1,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: _gold,
                fontFamily: 'serif',
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w800,
                height: .95,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Flexible(
          flex: 9,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              monthTitle,
              maxLines: 1,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: _gold,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectedDayPanel extends StatelessWidget {
  const _SelectedDayPanel({required this.entry});

  final CalendarEntry entry;

  @override
  Widget build(BuildContext context) {
    return _ReferencePanel(
      padding: const EdgeInsets.fromLTRB(18, 26, 18, 22),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _DateStack(entry: entry)),
              const SizedBox(width: 10),
              const _SacredSymbol(),
            ],
          ),
          const SizedBox(height: 34),
          Text(
            entry.tibetanDateText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: _white,
              fontWeight: FontWeight.w700,
              height: 1.16,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            entry.titleEn,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _white,
              fontWeight: FontWeight.w900,
              height: 1.12,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            entry.descriptionEn,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _white,
              fontWeight: FontWeight.w800,
              height: 1.14,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'We are the heirs of our own actions\n~ The Buddha ~',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: _white,
              fontStyle: FontStyle.italic,
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateStack extends StatelessWidget {
  const _DateStack({required this.entry});

  final CalendarEntry entry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.weekday.toUpperCase(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: _white,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 14),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            '${entry.day}',
            style: const TextStyle(
              color: _white,
              fontSize: 150,
              fontWeight: FontWeight.w900,
              height: .78,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _SacredSymbol extends StatelessWidget {
  const _SacredSymbol();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 134,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFE63C45),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
                bottom: Radius.circular(14),
              ),
              boxShadow: [
                BoxShadow(color: Color(0x66000000), offset: Offset(0, 4)),
              ],
            ),
            child: const Icon(Icons.auto_awesome, color: _gold, size: 20),
          ),
          const SizedBox(height: 8),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF0BD4D),
              border: Border.all(color: const Color(0xFF6F1013), width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 14,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.filter_vintage,
              color: Color(0xFF0E8577),
              size: 62,
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -2),
            child: Container(
              width: 124,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFE94778),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: const Color(0xFFFF84A8), width: 3),
              ),
              child: const Icon(
                Icons.local_florist,
                color: Color(0xFFFFD7E4),
                size: 38,
              ),
            ),
          ),
          Container(
            width: 132,
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE58B),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Color(0xFFC69027), offset: Offset(0, 5)),
              ],
            ),
            child: const Text(
              'OM AH HUNG',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFB32123),
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ElementPanel extends StatelessWidget {
  const _ElementPanel();

  @override
  Widget build(BuildContext context) {
    return _ReferencePanel(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
      child: Column(
        children: [
          Text(
            'Water - Wind',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _white,
              fontWeight: FontWeight.w800,
              height: 1.12,
              letterSpacing: 0,
            ),
          ),
          Text(
            'Negative Elemental Combination',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _white,
              fontWeight: FontWeight.w800,
              height: 1.12,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "This negative elemental combination will cause disharmony among one's loved ones",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: _white,
              fontWeight: FontWeight.w500,
              height: 1.16,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _TibetanDateDetails extends StatelessWidget {
  const _TibetanDateDetails({required this.entry});

  final CalendarEntry entry;

  @override
  Widget build(BuildContext context) {
    return _ReferencePanel(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _MetaCell(
                label: 'Date',
                value: '${entry.lunarDay}',
                subtitle: entry.tibetanDateText,
              ),
            ),
            const _MetaDivider(),
            const Expanded(
              child: _MetaCell(
                label: 'Month',
                value: '7',
                subtitle: 'Fire Dog',
              ),
            ),
            const _MetaDivider(),
            const Expanded(
              child: _MetaCell(
                label: 'Year',
                value: '2153',
                subtitle: 'Fire Horse',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaCell extends StatelessWidget {
  const _MetaCell({
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          color: _panelDarkRed,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: _gold,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 12, 6, 14),
          child: Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: _white,
                    fontWeight: FontWeight.w900,
                    height: .9,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: _white,
                  fontWeight: FontWeight.w600,
                  height: 1.08,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaDivider extends StatelessWidget {
  const _MetaDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, color: _borderRed);
  }
}

class _ReferencePanel extends StatelessWidget {
  const _ReferencePanel({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _panelRed,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderRed),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
