import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/currency.dart';
import '../bloc/converter_state.dart';
import '../bloc/currencies_converter_bloc.dart';
import '../bloc/currencies_converter_event.dart';
import 'currency_list_item.dart';

class CurrenciesList extends StatelessWidget {
  const CurrenciesList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrenciesConverterBloc, CurrenciesConverterState>(
      buildWhen: (previous, current) =>
          previous.displayedCurrencies != current.displayedCurrencies ||
          previous.selectedCurrency != current.selectedCurrency ||
          previous.isEditingRate != current.isEditingRate,
      builder: (context, state) {
        final currencies = state.displayedCurrencies;

        if (currencies.isEmpty) {
          return const SizedBox.shrink();
        }

        return ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: currencies.length,
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            context.read<CurrenciesConverterBloc>().add(
              ReorderCurrencies(oldIndex: oldIndex, newIndex: newIndex),
            );
          },
          itemBuilder: (context, index) {
            final currency = currencies[index];
            return _DismissibleCurrencyItem(
              key: ValueKey(currency.id),
              currency: currency,
              isSelected: state.selectedCurrency?.id == currency.id,
              isEditing: state.isEditingRate,
              selectedCurrency: state.selectedCurrency,
            );
          },
        );
      },
    );
  }
}

class _DismissibleCurrencyItem extends StatelessWidget {
  const _DismissibleCurrencyItem({
    super.key,
    required this.currency,
    required this.isSelected,
    required this.isEditing,
    this.selectedCurrency,
  });

  final Currency currency;
  final bool isSelected;
  final bool isEditing;
  final Currency? selectedCurrency;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('dismissible_${currency.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) {
        context.read<CurrenciesConverterBloc>().add(
          RemoveCurrencyFromDisplayed(currency),
        );
      },
      child: CurrencyListItem(
        currency: currency,
        isSelected: isSelected,
        isEditing: isEditing,
        selectedCurrency: selectedCurrency,
      ),
    );
  }
}
