import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../data/community_database.dart';

const _communityRed = Color(0xFF8B0E2F);
const _communityGold = Color(0xFFF6D985);
const _communityCard = Color(0xFFFFF8E8);
const _communityBorder = Color(0xFFE4C86D);

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key, required this.items});

  final List<CommunityEntryRow> items;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.community)),
      body: SingleChildScrollView(
        key: const ValueKey('community-scroll'),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (items.isEmpty)
              const _EmptyCommunityState()
            else
              for (final section in CommunityEntryType.values)
                ..._sectionWidgets(context, section),
          ],
        ),
      ),
    );
  }

  List<Widget> _sectionWidgets(BuildContext context, CommunityEntryType type) {
    final sectionItems =
        [
          for (final item in items)
            if (item.type == type) item,
        ]..sort((left, right) {
          final orderComparison = left.displayOrder.compareTo(
            right.displayOrder,
          );
          if (orderComparison != 0) return orderComparison;
          return left.title.compareTo(right.title);
        });

    if (sectionItems.isEmpty) return const [];

    return [
      _SectionHeading(title: type.sectionTitle),
      const SizedBox(height: 12),
      for (final item in sectionItems) _CommunityCard(item: item),
      const SizedBox(height: 20),
    ];
  }
}

class _CommunityCard extends StatelessWidget {
  const _CommunityCard({required this.item});

  final CommunityEntryRow item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final websiteUrl = _websiteUri(item.websiteUrl);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: _communityCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: _communityBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: websiteUrl == null
              ? null
              : () =>
                    launchUrl(websiteUrl, mode: LaunchMode.externalApplication),
          borderRadius: BorderRadius.circular(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _communityGold,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    _iconFor(item.type),
                    color: _communityRed,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: _communityRed,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(item.summary),
                    if (item.formattedStart != null) ...[
                      const SizedBox(height: 8),
                      _MetadataLine(
                        icon: Icons.schedule,
                        label: item.formattedStart!,
                      ),
                    ],
                    if (_hasText(item.location)) ...[
                      const SizedBox(height: 8),
                      _MetadataLine(
                        icon: Icons.location_on_outlined,
                        label: item.location!,
                      ),
                    ],
                    if (_hasText(item.address)) ...[
                      const SizedBox(height: 8),
                      _MetadataLine(
                        icon: Icons.map_outlined,
                        label: item.address!,
                      ),
                    ],
                    if (_hasText(item.phone)) ...[
                      const SizedBox(height: 8),
                      _MetadataLine(
                        icon: Icons.phone_outlined,
                        label: item.phone!,
                      ),
                    ],
                    if (_hasText(item.contact)) ...[
                      const SizedBox(height: 8),
                      _MetadataLine(
                        icon: Icons.email_outlined,
                        label: item.contact!,
                      ),
                    ],
                    if (_hasText(item.email) && item.email != item.contact) ...[
                      const SizedBox(height: 8),
                      _MetadataLine(
                        icon: Icons.alternate_email,
                        label: item.email!,
                      ),
                    ],
                    if (websiteUrl != null) ...[
                      const SizedBox(height: 8),
                      _MetadataLine(
                        icon: Icons.open_in_new,
                        label: _displayWebsite(websiteUrl),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(CommunityEntryType type) {
    return switch (type) {
      CommunityEntryType.news => Icons.campaign_outlined,
      CommunityEntryType.event => Icons.event_outlined,
      CommunityEntryType.monastery => Icons.temple_buddhist_outlined,
      CommunityEntryType.contact => Icons.email_outlined,
    };
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

  Uri? _websiteUri(String? value) {
    if (!_hasText(value)) return null;
    final uri = Uri.tryParse(value!.trim());
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }
    return uri;
  }

  String _displayWebsite(Uri uri) {
    final path = uri.path == '/' ? '' : uri.path;
    return '${uri.host}$path';
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: _communityRed,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );
  }
}

class _MetadataLine extends StatelessWidget {
  const _MetadataLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _communityRed, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
      ],
    );
  }
}

class _EmptyCommunityState extends StatelessWidget {
  const _EmptyCommunityState();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _communityCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: _communityBorder),
      ),
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Text('No community updates yet.'),
      ),
    );
  }
}
