import 'package:currency_converter/features/converter/data/models/currency.dart';
import 'package:currency_converter/features/converter/presentation/bloc/currencies_converter_bloc.dart';
import 'package:currency_converter/features/converter/presentation/bloc/currencies_converter_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrencyListItem extends StatelessWidget {
  const CurrencyListItem({
    super.key,
    required this.currency,
    required this.isSelected,
    this.isEditing = false,
    this.selectedCurrency,
    this.onReplace,
  });

  final Currency currency;
  final bool isSelected;
  final bool isEditing;
  final Currency? selectedCurrency;
  final VoidCallback? onReplace;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          // If already selected, start editing
          context.read<CurrenciesConverterBloc>().add(const StartEditingRate());
        } else {
          // Otherwise, select this currency
          context.read<CurrenciesConverterBloc>().add(SelectCurrency(currency));
        }
      },
      child: Container(
        padding: const EdgeInsets.only(left: 16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: _showConversionText ? 70 : 64,
        decoration: BoxDecoration(
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Image.network(currency.flagUrl, height: 30, width: 30),
            const SizedBox(width: 8),
            Text(
              currency.id,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (isSelected && onReplace != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onReplace,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.swap_horiz,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
            const Spacer(),
            _buildRateColumn(context),
            //Vertical Divider
            Container(
              width: 2,
              height: _showConversionText ? 70 : 64,
              margin: const EdgeInsets.only(left: 8),
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.4),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 2.0),
              child: Icon(
                Icons.more_vert,
                size: 24,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _showConversionText =>
      !isSelected &&
      selectedCurrency != null &&
      selectedCurrency!.id != currency.id;

  Widget _buildRateColumn(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRateDisplay(context),
        if (_showConversionText) ...[
          Text(
            _buildConversionText(),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  String _buildConversionText() {
    if (selectedCurrency == null || selectedCurrency!.rate == 0) {
      return '';
    }
    final conversionRate = currency.rate / selectedCurrency!.rate;
    return '1 ${selectedCurrency!.id} = ${_formatRate(conversionRate)} ${currency.id}';
  }

  Widget _buildRateDisplay(BuildContext context) {
    final rateText = _formatRate(currency.rate);

    if (isEditing && isSelected) {
      // Show editing indicator
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              rateText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.edit,
              size: 14,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ],
        ),
      );
    }

    return Text(
      rateText,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  String _formatRate(num rate) {
    // Format rate to reasonable precision
    if (rate == rate.truncate()) {
      return rate.truncate().toString();
    }
    // Limit decimal places to 6
    final formatted = rate.toDouble().toStringAsFixed(6);
    // Remove trailing zeros
    return formatted
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}
