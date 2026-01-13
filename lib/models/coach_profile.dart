class CoachProfile {
  final String userId;
  final String name;
  final int age;
  final String cycleLength;
  final String lastPeriodDate;
  final List<String> symptoms;
  final List<String> preferences;
  final Map<String, dynamic> healthGoals;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isAutonomousModeEnabled;
  final Map<String, dynamic> learningData;

  CoachProfile({
    required this.userId,
    required this.name,
    required this.age,
    required this.cycleLength,
    required this.lastPeriodDate,
    required this.symptoms,
    required this.preferences,
    required this.healthGoals,
    required this.createdAt,
    required this.updatedAt,
    this.isAutonomousModeEnabled = false,
    this.learningData = const {},
  });

  factory CoachProfile.fromJson(Map<String, dynamic> json) {
    return CoachProfile(
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      cycleLength: json['cycle_length'] ?? '28',
      lastPeriodDate: json['last_period_date'] ?? '',
      symptoms: List<String>.from(json['symptoms'] ?? []),
      preferences: List<String>.from(json['preferences'] ?? []),
      healthGoals: Map<String, dynamic>.from(json['health_goals'] ?? {}),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      isAutonomousModeEnabled: json['is_autonomous_mode_enabled'] ?? false,
      learningData: Map<String, dynamic>.from(json['learning_data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'age': age,
      'cycle_length': cycleLength,
      'last_period_date': lastPeriodDate,
      'symptoms': symptoms,
      'preferences': preferences,
      'health_goals': healthGoals,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_autonomous_mode_enabled': isAutonomousModeEnabled,
      'learning_data': learningData,
    };
  }

  CoachProfile copyWith({
    String? userId,
    String? name,
    int? age,
    String? cycleLength,
    String? lastPeriodDate,
    List<String>? symptoms,
    List<String>? preferences,
    Map<String, dynamic>? healthGoals,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isAutonomousModeEnabled,
    Map<String, dynamic>? learningData,
  }) {
    return CoachProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      age: age ?? this.age,
      cycleLength: cycleLength ?? this.cycleLength,
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      symptoms: symptoms ?? this.symptoms,
      preferences: preferences ?? this.preferences,
      healthGoals: healthGoals ?? this.healthGoals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isAutonomousModeEnabled: isAutonomousModeEnabled ?? this.isAutonomousModeEnabled,
      learningData: learningData ?? this.learningData,
    );
  }
}

