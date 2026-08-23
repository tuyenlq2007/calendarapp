import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/online_teaching_database.dart';
import '../data/teaching_content_database.dart';

const _teachingRed = Color(0xFF9B141B);
const _joinRed = Color(0xFFE60000);
const _cardBorder = Color(0xFFEADCAE);

class TeachingsScreen extends StatelessWidget {
  const TeachingsScreen({
    super.key,
    required this.items,
    required this.onlineTeachings,
    required this.savedIds,
    required this.onToggleSaved,
  });

  final List<TeachingContentRow> items;
  final List<OnlineTeachingRow> onlineTeachings;
  final Set<String> savedIds;
  final ValueChanged<String> onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teachings')),
      body: onlineTeachings.isNotEmpty
          ? _OnlineTeachingList(items: onlineTeachings)
          : _BilingualTeachingList(
              items: items,
              savedIds: savedIds,
              onToggleSaved: onToggleSaved,
            ),
    );
  }
}

class _OnlineTeachingList extends StatelessWidget {
  const _OnlineTeachingList({required this.items});

  final List<OnlineTeachingRow> items;

  @override
  Widget build(BuildContext context) {
    final sortedItems = [...items]
      ..sort((left, right) {
        final orderComparison = left.displayOrder.compareTo(right.displayOrder);
        if (orderComparison != 0) return orderComparison;
        return left.startDate.compareTo(right.startDate);
      });

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Online Teachings',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _teachingRed,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 16),
          for (final item in sortedItems) _OnlineTeachingCard(item: item),
        ],
      ),
    );
  }
}

class _OnlineTeachingCard extends StatelessWidget {
  const _OnlineTeachingCard({required this.item});

  final OnlineTeachingRow item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: _cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: _teachingRed,
                fontWeight: FontWeight.w900,
                height: 1.18,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 22),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  'Practice:',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: _teachingRed,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                Text(
                  item.practice,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.formattedDateRange,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: const Color(0xFFD40000),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _StatusPill(status: item.status),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: 260,
                child: FilledButton(
                  onPressed: item.status.canJoin
                      ? () => launchUrl(
                          item.joinUrl,
                          mode: LaunchMode.externalApplication,
                        )
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: _joinRed,
                    disabledBackgroundColor: const Color(0xFFA9A9A9),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const StadiumBorder(),
                    textStyle: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  child: const Text('JOIN NOW'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final OnlineTeachingStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = switch (status) {
      OnlineTeachingStatus.ongoing => (
        foreground: const Color(0xFF079321),
        background: const Color(0xFFE9FAEB),
        border: const Color(0xFF71DF7B),
      ),
      OnlineTeachingStatus.upcoming => (
        foreground: const Color(0xFF2459A6),
        background: const Color(0xFFEAF2FF),
        border: const Color(0xFF9ABDF5),
      ),
      OnlineTeachingStatus.finished => (
        foreground: const Color(0xFF666666),
        background: const Color(0xFFEEEEEE),
        border: const Color(0xFFCFCFCF),
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          status.label,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: colors.foreground,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _BilingualTeachingList extends StatelessWidget {
  const _BilingualTeachingList({
    required this.items,
    required this.savedIds,
    required this.onToggleSaved,
  });

  final List<TeachingContentRow> items;
  final Set<String> savedIds;
  final ValueChanged<String> onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final savedItems = [
      for (final item in items)
        if (savedIds.contains(item.id)) item,
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text('Saved library', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (savedItems.isEmpty)
          const Text('No teachings saved offline yet.')
        else
          for (final item in savedItems)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.offline_pin),
              title: Text(item.titleEn),
              subtitle: Text(item.category),
            ),
        const SizedBox(height: 20),
        Text(
          'Bilingual teachings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        for (final item in items)
          _TeachingCard(
            item: item,
            isSaved: savedIds.contains(item.id),
            onToggleSaved: onToggleSaved,
          ),
      ],
    );
  }
}

class _TeachingCard extends StatelessWidget {
  const _TeachingCard({
    required this.item,
    required this.isSaved,
    required this.onToggleSaved,
  });

  final TeachingContentRow item;
  final bool isSaved;
  final ValueChanged<String> onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(item.category)),
                if (item.isVideo) const Chip(label: Text('YouTube')),
                if (item.offlineEligible)
                  const Chip(label: Text('Offline eligible')),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.titleEn, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(item.titleBo),
            const SizedBox(height: 8),
            Text(item.summaryEn),
            const SizedBox(height: 12),
            if (item.offlineEligible)
              OutlinedButton.icon(
                onPressed: () => onToggleSaved(item.id),
                icon: Icon(isSaved ? Icons.offline_pin : Icons.download),
                label: Text(isSaved ? 'Saved offline' : 'Save offline'),
              )
            else
              const Row(
                children: [
                  Icon(Icons.wifi, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Video playback requires connectivity.'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
