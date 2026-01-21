import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../currencies/domain/entities/currency.dart';

class CurrencySelector extends StatelessWidget {
  final Currency? selectedCurrency;
  final String label;
  final VoidCallback onTap;

  const CurrencySelector({
    super.key,
    this.selectedCurrency,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildFlag(),
            const SizedBox(width: 12),
            Expanded(
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
                  Text(
                    selectedCurrency?.id ?? 'Select currency',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (selectedCurrency != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      selectedCurrency!.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlag() {
    if (selectedCurrency == null) {
      return Container(
        width: 48,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.currency_exchange, color: Colors.grey),
      );
    }

    final flagUrl = selectedCurrency!.flagUrl;
    if (flagUrl.isEmpty) {
      return Container(
        width: 48,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            selectedCurrency!.id.substring(0, 2),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: CachedNetworkImage(
        imageUrl: flagUrl,
        width: 48,
        height: 36,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 48,
          height: 36,
          color: Colors.grey[300],
        ),
        errorWidget: (context, url, error) => Container(
          width: 48,
          height: 36,
          color: Colors.grey[300],
          child: Center(
            child: Text(
              selectedCurrency!.id.substring(0, 2),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
