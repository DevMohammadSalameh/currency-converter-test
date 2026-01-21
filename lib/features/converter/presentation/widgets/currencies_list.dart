import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          previous.selectedCurrency != current.selectedCurrency,
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
            // Adjust newIndex when moving down
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            context.read<CurrenciesConverterBloc>().add(
              ReorderCurrencies(oldIndex: oldIndex, newIndex: newIndex),
            );
          },
          itemBuilder: (context, index) {
            final currency = currencies[index];
            return CurrencyListItem(
              key: ValueKey(currency.id),
              currency: currency,
              isSelected: state.selectedCurrency == currency,
            );
          },
        );
      },
    );
  }
}
