class TeachingContentRow {
  const TeachingContentRow({
    required this.id,
    required this.version,
    required this.slug,
    required this.type,
    required this.category,
    required this.titleEn,
    required this.titleBo,
    required this.summaryEn,
    required this.summaryBo,
    required this.bodyEn,
    required this.bodyBo,
    required this.youtubeUrl,
    required this.imageUrl,
    required this.offlineEligible,
    required this.status,
  });

  factory TeachingContentRow.fromJson(Map<String, Object?> json) {
    return TeachingContentRow(
      id: _string(json, 'id'),
      version: _integer(json, 'version'),
      slug: _string(json, 'slug'),
      type: _string(json, 'type'),
      category: _string(json, 'category'),
      titleEn: _string(json, 'title_en'),
      titleBo: _string(json, 'title_bo'),
      summaryEn: _string(json, 'summary_en'),
      summaryBo: _string(json, 'summary_bo'),
      bodyEn: _string(json, 'body_en'),
      bodyBo: _string(json, 'body_bo'),
      youtubeUrl: _nullableString(json, 'youtube_url'),
      imageUrl: _nullableString(json, 'image_url'),
      offlineEligible: _boolean(json, 'offline_eligible'),
      status: _string(json, 'status'),
    )..validate();
  }

  final String id;
  final int version;
  final String slug;
  final String type;
  final String category;
  final String titleEn;
  final String titleBo;
  final String summaryEn;
  final String summaryBo;
  final String bodyEn;
  final String bodyBo;
  final String? youtubeUrl;
  final String? imageUrl;
  final bool offlineEligible;
  final String status;

  bool get isWithdrawn => status == 'archived';
  bool get isVideo => type == 'video';

  void validate() {
    if (id.trim().isEmpty) {
      throw const FormatException('teaching content id is required');
    }
    if (version <= 0) {
      throw const FormatException('teaching content version must be positive');
    }
    if (type != 'article' && type != 'video') {
      throw FormatException('teaching content has unsupported type: $type');
    }
    if (status != 'published' && status != 'archived') {
      throw FormatException('teaching content has unsupported status: $status');
    }
    if (status == 'published' &&
        (slug.trim().isEmpty ||
            category.trim().isEmpty ||
            titleEn.trim().isEmpty ||
            titleBo.trim().isEmpty)) {
      throw const FormatException(
        'published teaching content must include bilingual titles',
      );
    }
    if (status == 'published' && isVideo && !_isYoutubeUrl(youtubeUrl)) {
      throw const FormatException('video content requires a YouTube URL');
    }
    if (status == 'published' &&
        type == 'article' &&
        offlineEligible &&
        (bodyEn.trim().isEmpty || bodyBo.trim().isEmpty)) {
      throw const FormatException(
        'offline teaching articles require bilingual body content',
      );
    }
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'version': version,
      'slug': slug,
      'type': type,
      'category': category,
      'title_en': titleEn,
      'title_bo': titleBo,
      'summary_en': summaryEn,
      'summary_bo': summaryBo,
      'body_en': bodyEn,
      'body_bo': bodyBo,
      'youtube_url': youtubeUrl,
      'image_url': imageUrl,
      'offline_eligible': offlineEligible,
      'status': status,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is TeachingContentRow &&
        other.id == id &&
        other.version == version &&
        other.slug == slug &&
        other.type == type &&
        other.category == category &&
        other.titleEn == titleEn &&
        other.titleBo == titleBo &&
        other.summaryEn == summaryEn &&
        other.summaryBo == summaryBo &&
        other.bodyEn == bodyEn &&
        other.bodyBo == bodyBo &&
        other.youtubeUrl == youtubeUrl &&
        other.imageUrl == imageUrl &&
        other.offlineEligible == offlineEligible &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    slug,
    type,
    category,
    titleEn,
    titleBo,
    summaryEn,
    summaryBo,
    bodyEn,
    bodyBo,
    youtubeUrl,
    imageUrl,
    offlineEligible,
    status,
  );

  static String _string(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String) return value;
    throw FormatException('teaching content field $key must be a string');
  }

  static String? _nullableString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null || value is String) return value as String?;
    throw FormatException('teaching content field $key must be a string');
  }

  static int _integer(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is num && value == value.toInt()) return value.toInt();
    throw FormatException('teaching content field $key must be an integer');
  }

  static bool _boolean(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is bool) return value;
    throw FormatException('teaching content field $key must be a boolean');
  }

  static bool _isYoutubeUrl(String? value) {
    if (value == null) return false;
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) return false;
    return uri.host == 'youtu.be' ||
        uri.host == 'youtube.com' ||
        uri.host == 'www.youtube.com';
  }
}

const sampleTeachingContent = [
  TeachingContentRow(
    id: 'refuge-practice',
    version: 1,
    slug: 'refuge-practice',
    type: 'article',
    category: 'Practice',
    titleEn: 'Refuge Practice',
    titleBo: 'སྐྱབས་འགྲོ།',
    summaryEn: 'A short teaching for daily Barom Kagyu practice.',
    summaryBo: 'ཉིན་རེའི་སྒྲུབ་པའི་ཆོས་ཁྲིད།',
    bodyEn: 'Take refuge with clear motivation.',
    bodyBo: 'དགོངས་པ་གསལ་པོས་སྐྱབས་འགྲོ་བྱ།',
    youtubeUrl: null,
    imageUrl: null,
    offlineEligible: true,
    status: 'published',
  ),
  TeachingContentRow(
    id: 'lineage-video',
    version: 2,
    slug: 'lineage-video',
    type: 'video',
    category: 'Lineage',
    titleEn: 'Lineage Teaching Video',
    titleBo: 'བརྒྱུད་པའི་ཆོས་ཁྲིད།',
    summaryEn: 'A YouTube-linked teaching for online viewing.',
    summaryBo: 'དྲ་ཐོག་གཟིགས་རྒྱུའི་ཆོས་ཁྲིད།',
    bodyEn: '',
    bodyBo: '',
    youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    imageUrl: null,
    offlineEligible: false,
    status: 'published',
  ),
];
