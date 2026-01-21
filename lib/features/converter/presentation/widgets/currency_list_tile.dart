import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/models/currency.dart';

class CurrencyListTile extends StatelessWidget {
  final Currency currency;
  final VoidCallback? onTap;
  final bool selected;

  const CurrencyListTile({
    super.key,
    required this.currency,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      selected: selected,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(
        alpha: 0.3,
      ),
      leading: _buildFlag(),
      title: Text(
        currency.name,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        currency.id,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: currency.symbol != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                currency.symbol!,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildFlag() {
    final flagUrl = currency.flagUrl;

    if (flagUrl.isEmpty) {
      return _buildFallbackFlag();
    }

    if (flagUrl.toLowerCase().endsWith('.svg')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SvgPicture.network(
          flagUrl,
          width: 40,
          height: 30,
          fit: BoxFit.cover,
          placeholderBuilder: (BuildContext context) => _buildPlaceholder(),
          // SvgPicture.network doesn't have a direct errorWidget equivalent that is as easy to use inline like CachedNetworkImage for fallbacks without a dedicated loader,
          // but we can wrap it or accept that if it fails it might show nothing or throw.
          // For robustness, we could wrap in a builder, but keeping it simple for now as requested.
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: CachedNetworkImage(
        imageUrl: flagUrl,
        width: 40,
        height: 30,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildFallbackFlag(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 40,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildFallbackFlag() {
    return Container(
      width: 40,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          currency.id.length >= 2 ? currency.id.substring(0, 2) : currency.id,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}
