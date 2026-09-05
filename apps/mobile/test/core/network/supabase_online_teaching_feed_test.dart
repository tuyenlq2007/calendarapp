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
        'image_url': 'https://azfsdtbmxzqomwsepjfx.supabase.co/storage/v1/object/public/images/Tara.JPG',
        'display_order': 1,
        'published': true,
      },
    ]);

    expect(page.rows, hasLength(1));
    expect(page.rows.single.title, 'Prayer for the Long Life of His Holiness');
    expect(
      page.rows.single.imageUrl,
      'https://azfsdtbmxzqomwsepjfx.supabase.co/storage/v1/object/public/images/Tara.JPG',
    );
    expect(
      page.rows.single.statusAt(DateTime(2026, 8, 24)),
      OnlineTeachingStatus.ongoing,
    );
    expect(page.rows.single.formattedDateRange, '06/07 - 31/12/2026');
    expect(
      page.rows.single.formattedLocalDateTimeRange,
      'Jul 06 12:00 AM - Dec 31 11:59 PM',
    );
  });

  test('online teaching rows prefer datetime fields for derived status', () {
    final row = OnlineTeachingRow.fromJson({
      'id': 'datetime-row',
      'title': 'Datetime Row',
      'practice': 'Practice',
      'start_datetime': '2026-08-24T09:00:00Z',
      'end_datetime': '2026-08-24T11:00:00Z',
      'status': 'finished',
      'join_url': 'https://us02web.zoom.us/j/9461447283',
      'display_order': 1,
      'published': true,
    });

    expect(
      row.statusAt(DateTime.utc(2026, 8, 24, 10)),
      OnlineTeachingStatus.ongoing,
    );
    expect(
      row.formattedLocalDateTimeRange,
      '${_localDateTimeLabel(row.startDate)} - ${_localDateTimeLabel(row.endDate)}',
    );
  });

  test('legacy end_date remains ongoing through the end date', () {
    final row = OnlineTeachingRow.fromJson({
      'id': 'legacy-row',
      'title': 'Legacy Row',
      'practice': 'Practice',
      'start_date': '2026-07-06',
      'end_date': '2026-12-31',
      'status': 'finished',
      'join_url': 'https://us02web.zoom.us/j/9461447283',
      'display_order': 1,
      'published': true,
    });

    expect(
      row.statusAt(DateTime(2026, 12, 31, 12)),
      OnlineTeachingStatus.ongoing,
    );
    expect(row.statusAt(DateTime(2027, 1, 1)), OnlineTeachingStatus.finished);
    expect(row.formattedDateRange, '06/07 - 31/12/2026');
    expect(
      row.formattedLocalDateTimeRange,
      'Jul 06 12:00 AM - Dec 31 11:59 PM',
    );
  });

  test('derived status changes at exact start and end datetimes', () {
    final row = OnlineTeachingRow.fromJson({
      'id': 'boundary-row',
      'title': 'Boundary Row',
      'practice': 'Practice',
      'start_datetime': '2026-08-24T09:00:00Z',
      'end_datetime': '2026-08-24T11:00:00Z',
      'join_url': 'https://us02web.zoom.us/j/9461447283',
      'display_order': 1,
      'published': true,
    });

    expect(
      row.statusAt(DateTime.utc(2026, 8, 24, 8, 59, 59)),
      OnlineTeachingStatus.upcoming,
    );
    expect(
      row.statusAt(DateTime.utc(2026, 8, 24, 9)),
      OnlineTeachingStatus.ongoing,
    );
    expect(
      row.statusAt(DateTime.utc(2026, 8, 24, 11)),
      OnlineTeachingStatus.finished,
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

    expect(
      rows.single.statusAt(DateTime(2026, 8, 24)),
      OnlineTeachingStatus.upcoming,
    );
  });
}

String _localDateTimeLabel(DateTime dateTime) {
  final local = dateTime.toLocal();
  return '${_monthAbbreviation(local.month)} ${_twoDigits(local.day)} '
      '${_hour12(local.hour)}:${_twoDigits(local.minute)} ${_period(local.hour)}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

int _hour12(int hour) {
  final normalized = hour % 12;
  return normalized == 0 ? 12 : normalized;
}

String _period(int hour) => hour < 12 ? 'AM' : 'PM';

String _monthAbbreviation(int month) {
  return const [
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
  ][month - 1];
}
