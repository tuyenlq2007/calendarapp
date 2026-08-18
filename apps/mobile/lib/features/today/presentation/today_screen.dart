import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../calendar/domain/calendar_entry.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.monthTitle, required this.entry});

  final String monthTitle;
  final CalendarEntry entry;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return CustomScrollView(
      key: const ValueKey('today-scroll'),
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: const Color(0xFF9B0F2E),
          foregroundColor: Colors.white,
          title: Text(monthTitle),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: Text(localizations.today)),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _TodayHeader(entry: entry),
              const SizedBox(height: 16),
              _PracticeImageCard(entry: entry),
              const SizedBox(height: 16),
              _DetailCard(entry: entry),
              const SizedBox(height: 16),
              const _OfferingSummary(),
            ]),
          ),
        ),
      ],
    );
  }
}

class _TodayHeader extends StatelessWidget {
  const _TodayHeader({required this.entry});

  final CalendarEntry entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE4C987)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.weekday.toUpperCase(),
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${entry.day}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: const Color(0xFF193C66),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    entry.tibetanDateText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF8B0E2F),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const _SacredSymbol(),
          ],
        ),
      ),
    );
  }
}

class _SacredSymbol extends StatelessWidget {
  const _SacredSymbol();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 118,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE7A5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD0A241), width: 2),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.spa, color: Color(0xFF0E6E63), size: 40),
          SizedBox(height: 8),
          Text(
            'BK',
            style: TextStyle(
              color: Color(0xFF9B0F2E),
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeImageCard extends StatelessWidget {
  const _PracticeImageCard({required this.entry});

  final CalendarEntry entry;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF8B0E2F),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.titleEn,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              entry.titleBo,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFFFFD46B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.entry});

  final CalendarEntry entry;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A3A1717),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.descriptionEn,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 14),
            const Text(
              'Anniversary of Guru Padmasambhava, one of Guru Padmasambhava manifestations.',
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferingSummary extends StatelessWidget {
  const _OfferingSummary();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _OfferingItem(label: 'Water', value: '0')),
        Expanded(child: _OfferingItem(label: 'Wood Dragon', value: '10')),
        Expanded(child: _OfferingItem(label: 'Iron Ox', value: '2148')),
      ],
    );
  }
}

class _OfferingItem extends StatelessWidget {
  const _OfferingItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFF9B0F2E),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center),
      ],
    );
  }
}
