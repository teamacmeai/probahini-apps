import 'package:flutter/material.dart';

class CoachAnalyticsCard extends StatelessWidget {
  final Map<String, dynamic> analytics;

  const CoachAnalyticsCard({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Coaching Analytics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              'Total Insights',
              '${analytics['total_insights'] ?? 0}',
              Icons.lightbulb_outline,
              theme,
            ),
            _buildMetricRow(
              'Read Insights',
              '${analytics['read_insights'] ?? 0}',
              Icons.visibility,
              theme,
            ),
            _buildMetricRow(
              'Acted Upon',
              '${analytics['acted_upon_insights'] ?? 0}',
              Icons.check_circle_outline,
              theme,
            ),
            const SizedBox(height: 16),
            _buildProgressBar(
              'Engagement Rate',
              (_parseDouble(analytics['engagement_rate']) ?? 0.0) / 100,
              theme,
            ),
            const SizedBox(height: 8),
            _buildProgressBar(
              'Action Rate',
              (_parseDouble(analytics['action_rate']) ?? 0.0) / 100,
              theme,
            ),
            const SizedBox(height: 16),
            _buildProfileCompleteness(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.primaryColor.withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
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

  Widget _buildProgressBar(
    String label,
    double progress,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(
            _getProgressColor(progress, theme),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCompleteness(ThemeData theme) {
    final completeness = _parseDouble(analytics['profile_completeness']) ?? 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile Completeness',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${completeness.toStringAsFixed(0)}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getProgressColor(completeness / 100, theme),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: completeness / 100,
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(
            _getProgressColor(completeness / 100, theme),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getCompletenessMessage(completeness),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress, ThemeData theme) {
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.6) return Colors.orange;
    if (progress >= 0.4) return Colors.amber;
    return Colors.red;
  }

  String _getCompletenessMessage(double completeness) {
    if (completeness >= 100) return 'Profile is complete!';
    if (completeness >= 80) return 'Almost there! Just a few more details needed.';
    if (completeness >= 60) return 'Good progress! Complete your profile for better insights.';
    if (completeness >= 40) return 'Halfway there! More details will improve coaching.';
    return 'Complete your profile to get personalized insights.';
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

