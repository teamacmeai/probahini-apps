import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:probahini/providers/autonomous_coach_provider.dart';
import 'package:probahini/models/coach_insight.dart';
import 'package:probahini/widgets/coach_insight_card.dart';
import 'package:probahini/widgets/coach_profile_setup.dart';
import 'package:probahini/widgets/coach_analytics_card.dart';
import '../utils/app_localizations.dart';

class AutonomousCoachPage extends StatefulWidget {
  final String userId;

  const AutonomousCoachPage({super.key, required this.userId});

  @override
  _AutonomousCoachPageState createState() => _AutonomousCoachPageState();
}

class _AutonomousCoachPageState extends State<AutonomousCoachPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AutonomousCoachProvider>().initializeCoach(widget.userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('autonomous_coach')),
        actions: [
          Consumer<AutonomousCoachProvider>(
            builder: (context, coachProvider, child) {
              return Switch(
                value: coachProvider.isAutonomousModeEnabled,
                onChanged: (value) {
                  coachProvider.toggleAutonomousMode();
                },
                activeColor: theme.primaryColor,
              );
            },
          ),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.lightbulb_outline),
              text: localizations.translate('insights'),
            ),
            Tab(
              icon: const Icon(Icons.person_outline),
              text: localizations.translate('profile'),
            ),
            Tab(
              icon: const Icon(Icons.analytics_outlined),
              text: localizations.translate('analytics'),
            ),
          ],
        ),
      ),
      body: Consumer<AutonomousCoachProvider>(
        builder: (context, coachProvider, child) {
          if (coachProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (coachProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    coachProvider.error!,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      coachProvider.clearError();
                      coachProvider.initializeCoach(widget.userId);
                    },
                    child: Text(localizations.translate('retry')),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildInsightsTab(coachProvider, localizations, theme),
              _buildProfileTab(coachProvider, localizations, theme),
              _buildAnalyticsTab(coachProvider, localizations, theme),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<AutonomousCoachProvider>(
        builder: (context, coachProvider, child) {
          if (!coachProvider.isAutonomousModeEnabled) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton(
            onPressed: () {
              coachProvider.generateInsights();
            },
            child: const Icon(Icons.refresh),
            tooltip: localizations.translate('generate_insights'),
          );
        },
      ),
    );
  }

  Widget _buildInsightsTab(
    AutonomousCoachProvider coachProvider,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    final insights = coachProvider.insights;
    final unreadInsights = coachProvider.getUnreadInsights();

    if (insights.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 64,
              color: theme.primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.translate('no_insights_yet'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              localizations.translate('enable_autonomous_mode'),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                coachProvider.regenerateQAInsights();
              },
              icon: const Icon(Icons.help_outline),
              label: const Text('Load All Q&A Content'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => coachProvider.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: insights.length,
        itemBuilder: (context, index) {
          final insight = insights[index];
          return CoachInsightCard(
            insight: insight,
            onMarkAsRead: () => coachProvider.markInsightAsRead(insight.id),
            onFeedback: (wasHelpful) =>
                coachProvider.recordInsightFeedback(insight.id, wasHelpful),
          );
        },
      ),
    );
  }

  Widget _buildProfileTab(
    AutonomousCoachProvider coachProvider,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: CoachProfileSetup(
        profile: coachProvider.profile,
        onUpdate: (updates) => coachProvider.updateProfile(updates),
      ),
    );
  }

  Widget _buildAnalyticsTab(
    AutonomousCoachProvider coachProvider,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    final analytics = coachProvider.analytics;

    if (analytics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: theme.primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.translate('no_analytics_yet'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              localizations.translate('use_app_more'),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CoachAnalyticsCard(analytics: analytics),
          const SizedBox(height: 16),
          _buildInsightTypeDistribution(analytics, theme),
          const SizedBox(height: 16),
          _buildEngagementMetrics(analytics, theme),
        ],
      ),
    );
  }

  Widget _buildInsightTypeDistribution(
    Map<String, dynamic> analytics,
    ThemeData theme,
  ) {
    final typeDistribution =
        analytics['type_distribution'] as Map<String, dynamic>?;

    if (typeDistribution == null || typeDistribution.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insight Types',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...typeDistribution.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key.replaceAll('_', ' ').toUpperCase()),
                    Text(
                      '${entry.value}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementMetrics(
    Map<String, dynamic> analytics,
    ThemeData theme,
  ) {
    final engagementRate = _parseDouble(analytics['engagement_rate']) ?? 0.0;
    final actionRate = _parseDouble(analytics['action_rate']) ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Engagement Metrics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              'Engagement Rate',
              '${engagementRate.toStringAsFixed(1)}%',
              theme,
            ),
            _buildMetricRow(
              'Action Rate',
              '${actionRate.toStringAsFixed(1)}%',
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to safely parse a value to double, handling both int and double types
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
