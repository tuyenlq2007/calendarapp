import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/network/supabase_online_teaching_feed.dart';
import 'package:mobile/features/teachings/data/online_teaching_database.dart';

void main() {
  test('online teaching page parses published rows', () {
    final page = OnlineTeachingPage.fromJsonRows([
      {
        'id': 'long-life-prayer',
        'title': 'Prayer for the Long Life of His Holiness',
        'practice': 'Recite the Sutra of Boundless Life and Wisdom',
        'start_date': '2026-07-06',
        'end_date': '2026-12-31',
        'status': 'ongoing',
        'join_url': 'https://us02web.zoom.us/j/9461447283?pwd=ck01U3B1ZERFd1R1d0FNOERGNzJoQT09',
        'display_order': 1,
        'published': true,
      },
    ]);

    expect(page.rows, hasLength(1));
    expect(page.rows.single.title, 'Prayer for the Long Life of His Holiness');
    expect(page.rows.single.status, OnlineTeachingStatus.ongoing);
    expect(page.rows.single.formattedDateRange, '06/07 - 31/12/2026');
  });

  test('online teaching rows reject unsupported statuses', () {
    expect(
      () => OnlineTeachingRow.fromJson({
        'id': 'bad-status',
        'title': 'Bad Status',
        'practice': 'Practice',
        'start_date': '2026-07-06',
        'end_date': '2026-12-31',
        'status': 'paused',
        'join_url': 'https://us02web.zoom.us/j/9461447283',
        'display_order': 1,
        'published': true,
      }),
      throwsFormatException,
    );
  });

  test('supabase online teaching feed loads rows from loader', () async {
    final feed = SupabaseOnlineTeachingFeed(
      () async => [
        {
          'id': 'medicine-buddha',
          'title': 'Medicine Buddha Practice',
          'practice': 'Daily Medicine Buddha mantra recitation and dedication',
          'start_date': '2026-09-01',
          'end_date': '2026-09-30',
          'status': 'upcoming',
          'join_url': 'https://us02web.zoom.us/j/9461447283',
          'display_order': 2,
          'published': true,
        },
      ],
    );

    final rows = await feed.publishedRows();

    expect(rows.single.status, OnlineTeachingStatus.upcoming);
  });
}
