class MenopauseTip {
  final String id;
  final String titleEn;
  final String titleBn;
  final String contentEn;
  final String contentBn;
  final String category;
  final DateTime createdAt;

  MenopauseTip({
    required this.id,
    required this.titleEn,
    required this.titleBn,
    required this.contentEn,
    required this.contentBn,
    required this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleEn': titleEn,
      'titleBn': titleBn,
      'contentEn': contentEn,
      'contentBn': contentBn,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MenopauseTip.fromJson(Map<String, dynamic> json) {
    return MenopauseTip(
      id: json['id'],
      titleEn: json['titleEn'],
      titleBn: json['titleBn'],
      contentEn: json['contentEn'],
      contentBn: json['contentBn'],
      category: json['category'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String getTitle(String language) {
    return language == 'bn' ? titleBn : titleEn;
  }

  String getContent(String language) {
    return language == 'bn' ? contentBn : contentEn;
  }
}
