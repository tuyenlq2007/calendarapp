import 'package:flutter/material.dart';

import '../data/teaching_content_database.dart';

class TeachingsScreen extends StatelessWidget {
  const TeachingsScreen({
    super.key,
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

    return Scaffold(
      appBar: AppBar(title: const Text('Teachings')),
      body: ListView(
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
      ),
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
