import 'package:flutter/material.dart';

import '../../domain/entities/conversion_result.dart';

class ConversionResultCard extends StatelessWidget {
  final ConversionResult result;

  const ConversionResultCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Converted Amount',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${_formatNumber(result.convertedAmount)} ${result.toCurrency}',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.swap_horiz,
                    size: 16,
                    color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '1 ${result.fromCurrency} = ${_formatRate(result.rate)} ${result.toCurrency}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(double value) {
    if (value == value.truncateToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  String _formatRate(double rate) {
    if (rate < 0.01) {
      return rate.toStringAsFixed(6);
    } else if (rate < 1) {
      return rate.toStringAsFixed(4);
    } else {
      return rate.toStringAsFixed(2);
    }
  }
}
