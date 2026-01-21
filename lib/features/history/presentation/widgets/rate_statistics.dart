import 'package:flutter/material.dart';

import '../bloc/history_state.dart';

class RateStatistics extends StatelessWidget {
  final HistoryState state;

  const RateStatistics({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Current',
            value: _formatRate(state.latestRate),
            theme: theme,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Change',
            value: _formatPercentage(state.percentageChange),
            valueColor: _getChangeColor(state.percentageChange, theme),
            theme: theme,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Low',
            value: _formatRate(state.minRate),
            theme: theme,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'High',
            value: _formatRate(state.maxRate),
            theme: theme,
          ),
        ),
      ],
    );
  }

  String _formatRate(double? rate) {
    if (rate == null) return '-';
    if (rate < 0.01) return rate.toStringAsFixed(6);
    if (rate < 1) return rate.toStringAsFixed(4);
    return rate.toStringAsFixed(2);
  }

  String _formatPercentage(double? percentage) {
    if (percentage == null) return '-';
    final sign = percentage >= 0 ? '+' : '';
    return '$sign${percentage.toStringAsFixed(2)}%';
  }

  Color _getChangeColor(double? percentage, ThemeData theme) {
    if (percentage == null) return theme.colorScheme.onSurfaceVariant;
    if (percentage > 0) return Colors.green;
    if (percentage < 0) return Colors.red;
    return theme.colorScheme.onSurfaceVariant;
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final ThemeData theme;

  const _StatCard({
    required this.label,
    required this.value,
    this.valueColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
