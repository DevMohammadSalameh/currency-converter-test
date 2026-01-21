import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/gradient_scaffold.dart';
import '../../data/models/currency.dart';
import '../bloc/converter_state.dart';
import '../bloc/currencies_converter_bloc.dart';
import '../bloc/currencies_converter_event.dart';
import '../widgets/currency_list_tile.dart';
import '../widgets/currency_search_bar.dart';

class CurrencyListView extends StatelessWidget {
  final String? title;
  final Currency? selectedCurrency;
  final void Function(Currency)? onCurrencySelected;

  const CurrencyListView({
    super.key,
    this.title,
    this.selectedCurrency,
    this.onCurrencySelected,
  });

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: Text(title ?? 'Currencies'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<CurrenciesConverterBloc, CurrenciesConverterState>(
        builder: (context, state) {
          return Column(
            children: [
              CurrencySearchBar(
                onChanged: (query) {
                  context.read<CurrenciesConverterBloc>().add(
                    SearchCurrencies(query),
                  );
                },
              ),
              Expanded(child: _buildContent(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, CurrenciesConverterState state) {
    if (state.isCurrencyListLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasCurrencyListError) {
      return _buildErrorWidget(
        context,
        state.currencyListError ?? 'Unknown error',
      );
    }

    if (state.isCurrencyListLoaded) {
      if (state.filteredCurrencies.isEmpty) {
        return _buildEmptyWidget(state.searchQuery);
      }
      return _buildCurrencyList(context, state);
    }

    // Initial state - show loading or prompt
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildCurrencyList(
    BuildContext context,
    CurrenciesConverterState state,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<CurrenciesConverterBloc>().add(const RefreshCurrencies());
      },
      child: ListView.separated(
        itemCount: state.filteredCurrencies.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final currency = state.filteredCurrencies[index];
          final isSelected = selectedCurrency?.id == currency.id;

          return CurrencyListTile(
            currency: currency,
            selected: isSelected,
            onTap: onCurrencySelected != null
                ? () => onCurrencySelected!(currency)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.read<CurrenciesConverterBloc>().add(
                  const LoadCurrencies(),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(String searchQuery) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty
                  ? 'No currencies found for "$searchQuery"'
                  : 'No currencies available',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
