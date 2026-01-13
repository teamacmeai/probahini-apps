import 'package:flutter/material.dart';
import 'package:probahini/models/coach_insight.dart';

class CoachInsightCard extends StatelessWidget {
  final CoachInsight insight;
  final VoidCallback? onMarkAsRead;
  final Function(bool)? onFeedback;

  const CoachInsightCard({
    super.key,
    required this.insight,
    this.onMarkAsRead,
    this.onFeedback,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: insight.isRead ? 2 : 4,
      child: InkWell(
        onTap: () {
          if (!insight.isRead && onMarkAsRead != null) {
            onMarkAsRead!();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 12),
              _buildContent(theme),
              if (insight.actionText != null) ...[
                const SizedBox(height: 12),
                _buildActionButton(theme),
              ],
              if (!insight.isRead) ...[
                const SizedBox(height: 12),
                _buildFeedbackButtons(theme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        _buildTypeIcon(theme),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                insight.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: insight.isRead ? theme.textTheme.titleMedium?.color?.withOpacity(0.7) : null,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildPriorityChip(theme),
                  const SizedBox(width: 8),
                  _buildTypeChip(theme),
                  if (insight.category != null) ...[
                    const SizedBox(width: 8),
                    _buildCategoryChip(theme),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (!insight.isRead)
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  Widget _buildTypeIcon(ThemeData theme) {
    IconData iconData;
    Color iconColor;

    switch (insight.type) {
      case InsightType.reminder:
        iconData = Icons.schedule;
        iconColor = Colors.orange;
        break;
      case InsightType.tip:
        iconData = Icons.lightbulb;
        iconColor = Colors.amber;
        break;
      case InsightType.warning:
        iconData = Icons.warning;
        iconColor = Colors.red;
        break;
      case InsightType.encouragement:
        iconData = Icons.favorite;
        iconColor = Colors.pink;
        break;
      case InsightType.question:
        iconData = Icons.help;
        iconColor = Colors.blue;
        break;
      case InsightType.analysis:
        iconData = Icons.analytics;
        iconColor = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  Widget _buildPriorityChip(ThemeData theme) {
    Color chipColor;
    String label;

    switch (insight.priority) {
      case InsightPriority.low:
        chipColor = Colors.green;
        label = 'Low';
        break;
      case InsightPriority.medium:
        chipColor = Colors.orange;
        label = 'Medium';
        break;
      case InsightPriority.high:
        chipColor = Colors.red;
        label = 'High';
        break;
      case InsightPriority.urgent:
        chipColor = Colors.red.shade800;
        label = 'Urgent';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: chipColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTypeChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
      ),
      child: Text(
        insight.type.toString().split('.').last.toUpperCase(),
        style: TextStyle(
          color: theme.primaryColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.3)),
      ),
      child: Text(
        insight.category!.toUpperCase(),
        style: TextStyle(
          color: theme.colorScheme.secondary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Text(
      insight.message,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: insight.isRead ? theme.textTheme.bodyMedium?.color?.withOpacity(0.7) : null,
        height: 1.4,
      ),
    );
  }

  Widget _buildActionButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // Handle action button press
          if (insight.actionUrl != null) {
            // Open URL or navigate
          }
        },
        icon: const Icon(Icons.open_in_new, size: 16),
        label: Text(insight.actionText!),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.primaryColor,
          side: BorderSide(color: theme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildFeedbackButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              onFeedback?.call(true);
            },
            icon: const Icon(Icons.thumb_up, size: 16),
            label: const Text('Helpful'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: BorderSide(color: Colors.green),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              onFeedback?.call(false);
            },
            icon: const Icon(Icons.thumb_down, size: 16),
            label: const Text('Not Helpful'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}

