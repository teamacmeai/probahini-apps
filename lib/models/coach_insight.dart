enum InsightType {
  reminder,
  tip,
  warning,
  encouragement,
  question,
  analysis,
}

enum InsightPriority {
  low,
  medium,
  high,
  urgent,
}

class CoachInsight {
  final String id;
  final String userId;
  final InsightType type;
  final InsightPriority priority;
  final String title;
  final String message;
  final String? actionText;
  final String? actionUrl;
  final Map<String, dynamic> metadata;
  final DateTime scheduledFor;
  final DateTime createdAt;
  final bool isRead;
  final bool isActedUpon;
  final String? category;

  CoachInsight({
    required this.id,
    required this.userId,
    required this.type,
    required this.priority,
    required this.title,
    required this.message,
    this.actionText,
    this.actionUrl,
    this.metadata = const {},
    required this.scheduledFor,
    required this.createdAt,
    this.isRead = false,
    this.isActedUpon = false,
    this.category,
  });

  factory CoachInsight.fromJson(Map<String, dynamic> json) {
    return CoachInsight(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      type: InsightType.values.firstWhere(
        (e) => e.toString() == 'InsightType.${json['type']}',
        orElse: () => InsightType.tip,
      ),
      priority: InsightPriority.values.firstWhere(
        (e) => e.toString() == 'InsightPriority.${json['priority']}',
        orElse: () => InsightPriority.medium,
      ),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      actionText: json['action_text'],
      actionUrl: json['action_url'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      scheduledFor: DateTime.parse(json['scheduled_for'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      isRead: json['is_read'] ?? false,
      isActedUpon: json['is_acted_upon'] ?? false,
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'title': title,
      'message': message,
      'action_text': actionText,
      'action_url': actionUrl,
      'metadata': metadata,
      'scheduled_for': scheduledFor.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'is_acted_upon': isActedUpon,
      'category': category,
    };
  }

  CoachInsight copyWith({
    String? id,
    String? userId,
    InsightType? type,
    InsightPriority? priority,
    String? title,
    String? message,
    String? actionText,
    String? actionUrl,
    Map<String, dynamic>? metadata,
    DateTime? scheduledFor,
    DateTime? createdAt,
    bool? isRead,
    bool? isActedUpon,
    String? category,
  }) {
    return CoachInsight(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      message: message ?? this.message,
      actionText: actionText ?? this.actionText,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isActedUpon: isActedUpon ?? this.isActedUpon,
      category: category ?? this.category,
    );
  }
}

