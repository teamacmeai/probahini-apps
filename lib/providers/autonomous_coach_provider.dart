import 'package:flutter/material.dart';
import 'package:probahini/models/coach_profile.dart';
import 'package:probahini/models/coach_insight.dart';
import 'package:probahini/services/autonomous_coach_service.dart';
import 'package:probahini/providers/tips_provider.dart';

class AutonomousCoachProvider extends ChangeNotifier {
  final AutonomousCoachService _coachService;
  final TipsProvider _tipsProvider;

  CoachProfile? _profile;
  List<CoachInsight> _insights = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _analytics = {};

  AutonomousCoachProvider(this._tipsProvider) : _coachService = AutonomousCoachService(_tipsProvider);

  // Getters
  CoachProfile? get profile => _profile;
  List<CoachInsight> get insights => _insights;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get analytics => _analytics;
  bool get isAutonomousModeEnabled => _profile?.isAutonomousModeEnabled ?? false;

  // Initialize the coach for a user
  Future<void> initializeCoach(String userId) async {
    _setLoading(true);
    try {
      _profile = await _coachService.getProfile(userId);
      final isNewUser = _profile == null;
      
      if (_profile == null) {
        // Create a new profile if none exists
        _profile = CoachProfile(
          userId: userId,
          name: '',
          age: 0,
          cycleLength: '28',
          lastPeriodDate: '',
          symptoms: [],
          preferences: [],
          healthGoals: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _coachService.saveProfile(_profile!);
      }
      
      await _loadInsights(userId);
      
      // Generate beginner insights for all users (will skip if already exist)
      await generateBeginnerInsights();
      
      await _loadAnalytics(userId);
      _setError(null);
    } catch (e) {
      _setError('Failed to initialize coach: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update profile
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (_profile == null) return;

    _setLoading(true);
    try {
      final updatedProfile = _profile!.copyWith(
        updatedAt: DateTime.now(),
        learningData: {..._profile!.learningData, ...updates},
      );
      
      await _coachService.saveProfile(updatedProfile);
      _profile = updatedProfile;
      notifyListeners();
      _setError(null);
    } catch (e) {
      _setError('Failed to update profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Enable/disable autonomous mode
  Future<void> toggleAutonomousMode() async {
    if (_profile == null) return;

    _setLoading(true);
    try {
      final updatedProfile = _profile!.copyWith(
        isAutonomousModeEnabled: !_profile!.isAutonomousModeEnabled,
        updatedAt: DateTime.now(),
      );
      
      await _coachService.saveProfile(updatedProfile);
      _profile = updatedProfile;
      
      if (updatedProfile.isAutonomousModeEnabled) {
        await _generateNewInsights();
      }
      
      notifyListeners();
      _setError(null);
    } catch (e) {
      _setError('Failed to toggle autonomous mode: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Generate new insights
  Future<void> generateInsights() async {
    if (_profile == null) return;

    _setLoading(true);
    try {
      await _generateNewInsights();
      _setError(null);
    } catch (e) {
      _setError('Failed to generate insights: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Generate beginner insights for new users
  Future<void> generateBeginnerInsights() async {
    if (_profile == null) return;

    _setLoading(true);
    try {
      final now = DateTime.now();
      final beginnerInsights = await _coachService.generateBeginnerInsights(_profile!.userId, _profile!, now);
      
      for (final insight in beginnerInsights) {
        await _coachService.addInsight(insight);
      }
      
      await _loadInsights(_profile!.userId);
      _setError(null);
    } catch (e) {
      _setError('Failed to generate beginner insights: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Regenerate all Q&A insights (clears existing ones first)
  Future<void> regenerateQAInsights() async {
    if (_profile == null) return;

    _setLoading(true);
    try {
      // Clear existing Q&A insights
      final existingInsights = await _coachService.getInsights(_profile!.userId);
      final nonQAInsights = existingInsights.where((insight) => 
          insight.category != 'beginner_qa' && insight.metadata['is_qa'] != true).toList();
      
      await _coachService.saveInsights(_profile!.userId, nonQAInsights);
      
      // Generate fresh Q&A insights
      final now = DateTime.now();
      final beginnerInsights = await _coachService.generateBeginnerInsights(_profile!.userId, _profile!, now);
      
      for (final insight in beginnerInsights) {
        await _coachService.addInsight(insight);
      }
      
      await _loadInsights(_profile!.userId);
      _setError(null);
    } catch (e) {
      _setError('Failed to regenerate Q&A insights: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _generateNewInsights() async {
    if (_profile == null) return;

    final newInsights = await _coachService.generateInsights(_profile!.userId);
    for (final insight in newInsights) {
      await _coachService.addInsight(insight);
    }
    
    await _loadInsights(_profile!.userId);
  }

  // Load insights
  Future<void> _loadInsights(String userId) async {
    _insights = await _coachService.getInsights(userId);
    // Sort to display beginner_questions first, then beginner_tips, then others by scheduled time
    _insights.sort((a, b) {
      // First, prioritize by category
      if (a.category == 'beginner_qa' && b.category != 'beginner_qa') return -1;
      if (a.category != 'beginner_qa' && b.category == 'beginner_qa') return 1;
      if (a.category == 'beginner_tips' && b.category != 'beginner_tips' && b.category != 'beginner_qa') return -1;
      if (a.category != 'beginner_tips' && b.category == 'beginner_tips' && a.category != 'beginner_qa') return 1;
      
      // If same category, sort by scheduled time (earliest first for Q&A, latest first for others)
      if (a.category == 'beginner_qa' || a.category == 'beginner_tips') {
        return a.scheduledFor.compareTo(b.scheduledFor);
      } else {
        return b.scheduledFor.compareTo(a.scheduledFor);
      }
    });
    notifyListeners();
  }

  // Load analytics
  Future<void> _loadAnalytics(String userId) async {
    _analytics = await _coachService.getCoachingAnalytics(userId);
    notifyListeners();
  }

  // Mark insight as read
  Future<void> markInsightAsRead(String insightId) async {
    if (_profile == null) return;

    try {
      await _coachService.markInsightAsRead(_profile!.userId, insightId);
      await _loadInsights(_profile!.userId);
      _setError(null);
    } catch (e) {
      _setError('Failed to mark insight as read: $e');
    }
  }

  // Record user interaction
  Future<void> recordInteraction(String interactionType, Map<String, dynamic> data) async {
    if (_profile == null) return;

    try {
      await _coachService.recordUserInteraction(_profile!.userId, interactionType, data);
      await _loadAnalytics(_profile!.userId);
      _setError(null);
    } catch (e) {
      _setError('Failed to record interaction: $e');
    }
  }

  // Record insight feedback
  Future<void> recordInsightFeedback(String insightId, bool wasHelpful) async {
    if (_profile == null) return;

    try {
      await _coachService.recordInsightFeedback(_profile!.userId, insightId, wasHelpful);
      await _loadInsights(_profile!.userId);
      await _loadAnalytics(_profile!.userId);
      _setError(null);
    } catch (e) {
      _setError('Failed to record feedback: $e');
    }
  }

  // Get insights by type
  List<CoachInsight> getInsightsByType(InsightType type) {
    return _insights.where((insight) => insight.type == type).toList();
  }

  // Get insights by priority
  List<CoachInsight> getInsightsByPriority(InsightPriority priority) {
    return _insights.where((insight) => insight.priority == priority).toList();
  }

  // Get unread insights
  List<CoachInsight> getUnreadInsights() {
    return _insights.where((insight) => !insight.isRead).toList();
  }

  // Get scheduled insights (for notifications)
  Future<List<CoachInsight>> getScheduledInsights() async {
    if (_profile == null) return [];
    return await _coachService.getScheduledInsights(_profile!.userId);
  }

  // Update profile fields
  Future<void> updateProfileField(String field, dynamic value) async {
    if (_profile == null) return;

    final updates = <String, dynamic>{};
    
    switch (field) {
      case 'name':
        updates['name'] = value;
        break;
      case 'age':
        updates['age'] = value;
        break;
      case 'cycleLength':
        updates['cycleLength'] = value;
        break;
      case 'lastPeriodDate':
        updates['lastPeriodDate'] = value;
        break;
      case 'symptoms':
        updates['symptoms'] = value;
        break;
      case 'preferences':
        updates['preferences'] = value;
        break;
      case 'healthGoals':
        updates['healthGoals'] = value;
        break;
    }

    await updateProfile(updates);
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _setError(null);
  }

  // Refresh all data
  Future<void> refresh() async {
    if (_profile == null) return;
    
    await _loadInsights(_profile!.userId);
    await _loadAnalytics(_profile!.userId);
  }
}

