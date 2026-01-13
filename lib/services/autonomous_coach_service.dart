import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:probahini/models/coach_profile.dart';
import 'package:probahini/models/coach_insight.dart';
import 'package:probahini/models/tip.dart';
import 'package:probahini/providers/tips_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AutonomousCoachService {
  static const String _profileKey = 'coach_profile';
  static const String _insightsKey = 'coach_insights';
  static const String _learningDataKey = 'coach_learning_data';

  final TipsProvider _tipsProvider;
  final Random _random = Random();

  AutonomousCoachService(this._tipsProvider);

  // Profile Management
  Future<CoachProfile?> getProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('${_profileKey}_$userId');

    if (profileJson != null) {
      return CoachProfile.fromJson(jsonDecode(profileJson));
    }
    return null;
  }

  Future<void> saveProfile(CoachProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_profileKey}_${profile.userId}',
      jsonEncode(profile.toJson()),
    );
  }

  Future<void> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    final profile = await getProfile(userId);
    if (profile != null) {
      final updatedProfile = profile.copyWith(
        updatedAt: DateTime.now(),
        learningData: {...profile.learningData, ...updates},
      );
      await saveProfile(updatedProfile);
    }
  }

  // Insights Management
  Future<List<CoachInsight>> getInsights(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final insightsJson = prefs.getString('${_insightsKey}_$userId');

    if (insightsJson != null) {
      final List<dynamic> insightsList = jsonDecode(insightsJson);
      return insightsList.map((json) => CoachInsight.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> saveInsights(String userId, List<CoachInsight> insights) async {
    final prefs = await SharedPreferences.getInstance();
    final insightsJson = jsonEncode(
      insights.map((insight) => insight.toJson()).toList(),
    );
    await prefs.setString('${_insightsKey}_$userId', insightsJson);
  }

  Future<void> addInsight(CoachInsight insight) async {
    final insights = await getInsights(insight.userId);
    insights.add(insight);
    await saveInsights(insight.userId, insights);
  }

  Future<void> markInsightAsRead(String userId, String insightId) async {
    final insights = await getInsights(userId);
    final index = insights.indexWhere((insight) => insight.id == insightId);
    if (index != -1) {
      insights[index] = insights[index].copyWith(isRead: true);
      await saveInsights(userId, insights);
    }
  }

  // Autonomous Coaching Logic
  Future<List<CoachInsight>> generateInsights(String userId) async {
    final profile = await getProfile(userId);
    if (profile == null || !profile.isAutonomousModeEnabled) {
      return [];
    }

    final insights = <CoachInsight>[];
    final now = DateTime.now();

    // Generate beginner insights for new users
    insights.addAll(await generateBeginnerInsights(userId, profile, now));

    // Generate cycle-based insights
    insights.addAll(await _generateCycleInsights(userId, profile, now));

    // Generate symptom-based insights
    insights.addAll(await _generateSymptomInsights(userId, profile, now));

    // Generate wellness insights
    insights.addAll(await _generateWellnessInsights(userId, profile, now));

    // Generate learning-based insights
    insights.addAll(await _generateLearningInsights(userId, profile, now));

    return insights;
  }

  Future<List<CoachInsight>> generateBeginnerInsights(
    String userId,
    CoachProfile profile,
    DateTime now,
  ) async {
    final insights = <CoachInsight>[];
    final learningData = profile.learningData;

    // Check if Q&A insights already exist to avoid duplicates
    final existingInsights = await getInsights(userId);
    final hasQAInsights = existingInsights.any((insight) => 
        insight.category == 'beginner_qa' || insight.metadata['is_qa'] == true);

    print(
      'Beginner insights check: existingInsights=${existingInsights.length}, hasQAInsights=$hasQAInsights',
    );

    // Skip if Q&A insights already exist
    if (hasQAInsights) return insights;

    try {
      // Load beginner Q&A data
      final qaData = await _loadBeginnerQAData();
      final questions = qaData['beginner_questions'] as List<dynamic>? ?? [];
      final tips = qaData['beginner_tips'] as List<dynamic>? ?? [];

      // Sort questions by ID (smallest first)
      questions.sort((a, b) => a['id'].compareTo(b['id']));
      
      // Generate ALL question-based insights first
      for (int i = 0; i < questions.length; i++) {
        final question = questions[i];
        final priority = question['priority'] == 'high' 
            ? InsightPriority.high 
            : question['priority'] == 'medium' 
                ? InsightPriority.medium 
                : InsightPriority.low;
        
        insights.add(
          CoachInsight(
            id: const Uuid().v4(),
            userId: userId,
            type: InsightType.question,
            priority: priority,
            title: 'Q: ${question['question']}',
            message: question['answer'],
            category: 'beginner_qa',
            scheduledFor: now.add(Duration(minutes: i * 5)), // Stagger by 5 minutes each
            createdAt: now,
            metadata: {
              'question_id': question['id'],
              'category': question['category'],
              'is_qa': true,
            },
          ),
        );
      }

      // Sort tips by ID (smallest first)
      tips.sort((a, b) => a['id'].compareTo(b['id']));
      
      // Add ALL beginner tips after questions
      for (int i = 0; i < tips.length; i++) {
        final tip = tips[i];
        insights.add(
          CoachInsight(
            id: const Uuid().v4(),
            userId: userId,
            type: InsightType.tip,
            priority: InsightPriority.medium,
            title: tip['title'],
            message: tip['content'],
            category: 'beginner_tips',
            scheduledFor: now.add(Duration(minutes: (questions.length + i) * 5)), // Continue staggering after questions
            createdAt: now,
            metadata: {
              'tip_id': tip['id'],
              'category': tip['category'],
            },
          ),
        );
      }

    } catch (e) {
      // If loading Q&A data fails, just return empty insights
      print('Error generating beginner insights: $e');
    }

    return insights;
  }

  Future<Map<String, dynamic>> _loadBeginnerQAData() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'lib/data/beginner_qa_data.json',
      );
      final data = jsonDecode(jsonString);
      final questions = data['beginner_questions'] as List<dynamic>? ?? [];
      final tips = data['beginner_tips'] as List<dynamic>? ?? [];
      print('Loaded Q&A data: ${questions.length} questions, ${tips.length} tips');
      if (questions.isNotEmpty) {
        print('Question IDs: ${questions.map((q) => q['id']).join(', ')}');
      }
      if (tips.isNotEmpty) {
        print('Tip IDs: ${tips.map((t) => t['id']).join(', ')}');
      }
      return data;
    } catch (e) {
      print('Error loading Q&A data: $e');
      return {'beginner_questions': [], 'beginner_tips': []};
    }
  }

  Future<List<CoachInsight>> _generateCycleInsights(
    String userId,
    CoachProfile profile,
    DateTime now,
  ) async {
    final insights = <CoachInsight>[];

    try {
      final lastPeriod = DateTime.parse(profile.lastPeriodDate);
      final cycleLength = int.parse(profile.cycleLength);
      final daysSinceLastPeriod = now.difference(lastPeriod).inDays;

      // Period prediction
      if (daysSinceLastPeriod >= cycleLength - 2 &&
          daysSinceLastPeriod <= cycleLength + 2) {
        insights.add(
          CoachInsight(
            id: const Uuid().v4(),
            userId: userId,
            type: InsightType.reminder,
            priority: InsightPriority.medium,
            title: 'Period Expected Soon',
            message:
                'Your period is expected in the next few days. Make sure you have your supplies ready!',
            category: 'cycle',
            scheduledFor: now,
            createdAt: now,
          ),
        );
      }

      // Mid-cycle insights
      if (daysSinceLastPeriod >= 12 && daysSinceLastPeriod <= 16) {
        insights.add(
          CoachInsight(
            id: const Uuid().v4(),
            userId: userId,
            type: InsightType.tip,
            priority: InsightPriority.low,
            title: 'Mid-Cycle Wellness',
            message:
                'You\'re in your mid-cycle phase. This is a great time for light exercise and maintaining a balanced diet.',
            category: 'cycle',
            scheduledFor: now,
            createdAt: now,
          ),
        );
      }
    } catch (e) {
      // Handle date parsing errors gracefully
    }

    return insights;
  }

  Future<List<CoachInsight>> _generateSymptomInsights(
    String userId,
    CoachProfile profile,
    DateTime now,
  ) async {
    final insights = <CoachInsight>[];

    // Generate insights based on common symptoms
    if (profile.symptoms.contains('cramps')) {
      insights.add(
        CoachInsight(
          id: const Uuid().v4(),
          userId: userId,
          type: InsightType.tip,
          priority: InsightPriority.medium,
          title: 'Cramp Relief Tips',
          message:
              'Try gentle stretching, warm compresses, or light massage to help with menstrual cramps.',
          category: 'symptoms',
          scheduledFor: now,
          createdAt: now,
        ),
      );
    }

    if (profile.symptoms.contains('mood_swings')) {
      insights.add(
        CoachInsight(
          id: const Uuid().v4(),
          userId: userId,
          type: InsightType.encouragement,
          priority: InsightPriority.low,
          title: 'Mood Support',
          message:
              'Remember that mood changes are normal during your cycle. Practice self-care and be gentle with yourself.',
          category: 'symptoms',
          scheduledFor: now,
          createdAt: now,
        ),
      );
    }

    return insights;
  }

  Future<List<CoachInsight>> _generateWellnessInsights(
    String userId,
    CoachProfile profile,
    DateTime now,
  ) async {
    final insights = <CoachInsight>[];

    // Get a random tip from the tips provider
    final tips = _tipsProvider.allTips;
    if (tips.isNotEmpty) {
      final randomTip = tips[_random.nextInt(tips.length)];

      insights.add(
        CoachInsight(
          id: const Uuid().v4(),
          userId: userId,
          type: InsightType.tip,
          priority: InsightPriority.low,
          title: 'Daily Wellness Tip',
          message: randomTip.contentEn,
          category: 'wellness',
          scheduledFor: now,
          createdAt: now,
        ),
      );
    }

    return insights;
  }

  Future<List<CoachInsight>> _generateLearningInsights(
    String userId,
    CoachProfile profile,
    DateTime now,
  ) async {
    final insights = <CoachInsight>[];
    final learningData = profile.learningData;

    // Check if user hasn't interacted with the app recently
    final lastInteraction = learningData['last_interaction'];
    if (lastInteraction != null) {
      final lastInteractionDate = DateTime.parse(lastInteraction);
      final daysSinceInteraction = now.difference(lastInteractionDate).inDays;

      if (daysSinceInteraction >= 3) {
        insights.add(
          CoachInsight(
            id: const Uuid().v4(),
            userId: userId,
            type: InsightType.encouragement,
            priority: InsightPriority.low,
            title: 'We Miss You!',
            message:
                'How are you feeling today? Your health journey is important to us.',
            category: 'engagement',
            scheduledFor: now,
            createdAt: now,
          ),
        );
      }
    }

    return insights;
  }

  // Learning and Adaptation
  Future<void> recordUserInteraction(
    String userId,
    String interactionType,
    Map<String, dynamic> data,
  ) async {
    final profile = await getProfile(userId);
    if (profile != null) {
      final learningData = Map<String, dynamic>.from(profile.learningData);
      learningData['last_interaction'] = DateTime.now().toIso8601String();
      learningData['interaction_count'] =
          (learningData['interaction_count'] ?? 0) + 1;

      // Track specific interaction types
      if (!learningData.containsKey('interactions')) {
        learningData['interactions'] = <String, int>{};
      }
      final interactions = Map<String, int>.from(learningData['interactions']);
      interactions[interactionType] = (interactions[interactionType] ?? 0) + 1;
      learningData['interactions'] = interactions;

      // Store additional data
      learningData['last_$interactionType'] = data;

      await updateProfile(userId, learningData);
    }
  }

  Future<void> recordInsightFeedback(
    String userId,
    String insightId,
    bool wasHelpful,
  ) async {
    final insights = await getInsights(userId);
    final index = insights.indexWhere((insight) => insight.id == insightId);

    if (index != -1) {
      insights[index] = insights[index].copyWith(
        isActedUpon: true,
        metadata: {
          ...insights[index].metadata,
          'feedback': wasHelpful,
          'feedback_date': DateTime.now().toIso8601String(),
        },
      );
      await saveInsights(userId, insights);

      // Update learning data
      await recordUserInteraction(userId, 'insight_feedback', {
        'insight_id': insightId,
        'was_helpful': wasHelpful,
        'insight_type': insights[index].type.toString(),
      });
    }
  }

  // Smart Scheduling
  Future<List<CoachInsight>> getScheduledInsights(String userId) async {
    final insights = await getInsights(userId);
    final now = DateTime.now();

    return insights.where((insight) {
      return !insight.isRead &&
          insight.scheduledFor.isBefore(now.add(const Duration(hours: 1))) &&
          insight.scheduledFor.isAfter(now.subtract(const Duration(hours: 1)));
    }).toList();
  }

  // Analytics and Insights
  Future<Map<String, dynamic>> getCoachingAnalytics(String userId) async {
    final profile = await getProfile(userId);
    final insights = await getInsights(userId);

    if (profile == null) return {};

    final totalInsights = insights.length;
    final readInsights = insights.where((i) => i.isRead).length;
    final actedUponInsights = insights.where((i) => i.isActedUpon).length;

    final typeCounts = <String, int>{};
    for (final insight in insights) {
      final type = insight.type.toString().split('.').last;
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }

    return {
      'total_insights': totalInsights,
      'read_insights': readInsights,
      'acted_upon_insights': actedUponInsights,
      'engagement_rate': totalInsights > 0
          ? (readInsights / totalInsights) * 100
          : 0,
      'action_rate': readInsights > 0
          ? (actedUponInsights / readInsights) * 100
          : 0,
      'type_distribution': typeCounts,
      'autonomous_mode_enabled': profile.isAutonomousModeEnabled,
      'profile_completeness': _calculateProfileCompleteness(profile),
    };
  }

  double _calculateProfileCompleteness(CoachProfile profile) {
    int completedFields = 0;
    int totalFields =
        6; // name, age, cycleLength, lastPeriodDate, symptoms, preferences

    if (profile.name.isNotEmpty) completedFields++;
    if (profile.age > 0) completedFields++;
    if (profile.cycleLength.isNotEmpty) completedFields++;
    if (profile.lastPeriodDate.isNotEmpty) completedFields++;
    if (profile.symptoms.isNotEmpty) completedFields++;
    if (profile.preferences.isNotEmpty) completedFields++;

    return (completedFields / totalFields) * 100;
  }
}
