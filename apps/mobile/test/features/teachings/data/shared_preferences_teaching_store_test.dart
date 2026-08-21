import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/teachings/data/shared_preferences_teaching_store.dart';
import 'package:mobile/features/teachings/data/teaching_content_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('stores published teaching content and saved library ids', () async {
    final store = SharedPreferencesTeachingStore(SharedPreferencesAsync());
    final article = TeachingContentRow(
      id: 'refuge-practice',
      version: 1,
      slug: 'refuge-practice',
      type: 'article',
      category: 'Practice',
      titleEn: 'Refuge Practice',
      titleBo: 'སྐྱབས་འགྲོ།',
      summaryEn: 'A short teaching for daily practice.',
      summaryBo: 'ཉིན་རེའི་ཆོས་ཁྲིད།',
      bodyEn: 'Take refuge with clear motivation.',
      bodyBo: 'དགོངས་པ་གསལ་པོས་སྐྱབས་འགྲོ་བྱ།',
      youtubeUrl: null,
      imageUrl: null,
      offlineEligible: true,
      status: 'published',
    );

    await store.upsertOrWithdraw(article);
    await store.toggleSaved(article.id);

    expect(await store.publishedContent(), [article]);
    expect(await store.savedContent(), [article]);
  });

  test('withdrawn content leaves the offline library', () async {
    final store = SharedPreferencesTeachingStore(SharedPreferencesAsync());
    final article = TeachingContentRow.fromJson({
      'id': 'withdrawn-teaching',
      'version': 1,
      'slug': 'withdrawn-teaching',
      'type': 'article',
      'category': 'Practice',
      'title_en': 'Withdrawn teaching',
      'title_bo': 'སྐྱབས་འགྲོ།',
      'summary_en': 'Summary',
      'summary_bo': 'བསྡུས་དོན།',
      'body_en': 'Body',
      'body_bo': 'ནང་དོན།',
      'youtube_url': null,
      'image_url': null,
      'offline_eligible': true,
      'status': 'published',
    });
    final archived = TeachingContentRow.fromJson({
      'id': 'withdrawn-teaching',
      'version': 2,
      'slug': 'withdrawn-teaching',
      'type': 'article',
      'category': 'Practice',
      'title_en': 'Withdrawn teaching',
      'title_bo': 'སྐྱབས་འགྲོ།',
      'summary_en': 'Summary',
      'summary_bo': 'བསྡུས་དོན།',
      'body_en': '',
      'body_bo': '',
      'youtube_url': null,
      'image_url': null,
      'offline_eligible': true,
      'status': 'archived',
    });

    await store.upsertOrWithdraw(article);
    await store.toggleSaved(article.id);
    await store.upsertOrWithdraw(archived);

    expect(await store.publishedContent(), isEmpty);
    expect(await store.savedContent(), isEmpty);
  });
}
