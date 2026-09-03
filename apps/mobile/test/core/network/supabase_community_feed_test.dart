import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/network/supabase_community_feed.dart';
import 'package:mobile/features/community/data/community_database.dart';

void main() {
  test('community page parses published news event and contact rows', () {
    final page = CommunityPage.fromJsonRows([
      {
        'id': 'news-row',
        'type': 'news',
        'title': 'Losar community gathering',
        'summary': 'New year prayers and shared dedication.',
        'detail': 'Everyone is welcome.',
        'starts_at': null,
        'location': null,
        'contact': null,
        'display_order': 1,
        'published': true,
      },
      {
        'id': 'event-row',
        'type': 'event',
        'title': 'Weekly meditation practice',
        'summary': 'Sundays at 9:00 AM.',
        'detail': '',
        'starts_at': '2026-09-06T09:00:00Z',
        'location': 'Main shrine room',
        'contact': null,
        'display_order': 2,
        'published': true,
      },
      {
        'id': 'contact-row',
        'type': 'contact',
        'title': 'Contact',
        'summary': 'contact@baromkagyu.org',
        'detail': '',
        'starts_at': null,
        'location': null,
        'contact': 'contact@baromkagyu.org',
        'display_order': 3,
        'published': true,
      },
    ]);

    expect(page.rows, hasLength(3));
    expect(page.rows.first.type, CommunityEntryType.news);
    expect(
      page.rows[1].formattedStart,
      _localDateTimeLabel(DateTime.utc(2026, 9, 6, 9)),
    );
    expect(page.rows.last.contact, 'contact@baromkagyu.org');
  });

  test('community rows require supported type and published flag', () {
    expect(
      () => CommunityEntryRow.fromJson({
        'id': 'bad-type',
        'type': 'announcement',
        'title': 'Announcement',
        'summary': 'Summary',
        'detail': '',
        'starts_at': null,
        'location': null,
        'contact': null,
        'display_order': 1,
        'published': true,
      }),
      throwsFormatException,
    );

    expect(
      () => CommunityEntryRow.fromJson({
        'id': 'bad-published',
        'type': 'news',
        'title': 'News',
        'summary': 'Summary',
        'detail': '',
        'starts_at': null,
        'location': null,
        'contact': null,
        'display_order': 1,
        'published': 'true',
      }),
      throwsFormatException,
    );
  });

  test('supabase community feed loads rows from loader', () async {
    final feed = SupabaseCommunityFeed(
      () async => [
        {
          'id': 'monastery-row',
          'type': 'monastery',
          'title': 'Barom Kagyu monastery',
          'summary': 'Lineage practice center.',
          'detail': '',
          'starts_at': null,
          'location': 'Dharma Center',
          'contact': null,
          'display_order': 1,
          'published': true,
        },
      ],
    );

    final rows = await feed.publishedRows();

    expect(rows.single.type, CommunityEntryType.monastery);
    expect(rows.single.title, 'Barom Kagyu monastery');
  });
}

String _localDateTimeLabel(DateTime dateTime) {
  final local = dateTime.toLocal();
  return '${_twoDigits(local.day)}/${_twoDigits(local.month)}/${local.year} '
      '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
