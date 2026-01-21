import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/currency.dart';
import '../bloc/currencies_bloc.dart';
import '../bloc/currencies_event.dart';
import '../bloc/currencies_state.dart';
import '../widgets/currency_list_tile.dart';
import '../widgets/currency_search_bar.dart';

class CurrencyListPage extends StatelessWidget {
  final String? title;
  final Currency? selectedCurrency;
  final void Function(Currency)? onCurrencySelected;

  const CurrencyListPage({
    super.key,
    this.title,
    this.selectedCurrency,
    this.onCurrencySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'Currencies'),
        centerTitle: true,
      ),
      body: BlocBuilder<CurrenciesBloc, CurrenciesState>(
        builder: (context, state) {
          return Column(
            children: [
              CurrencySearchBar(
                onChanged: (query) {
                  context.read<CurrenciesBloc>().add(SearchCurrencies(query));
                },
              ),
              Expanded(
                child: _buildContent(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, CurrenciesState state) {
    if (state is CurrenciesLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is CurrenciesError) {
      return _buildErrorWidget(context, state.message);
    }

    if (state is CurrenciesLoaded) {
      if (state.filteredCurrencies.isEmpty) {
        return _buildEmptyWidget(state.searchQuery);
      }
      return _buildCurrencyList(context, state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildCurrencyList(BuildContext context, CurrenciesLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<CurrenciesBloc>().add(const RefreshCurrencies());
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
                context.read<CurrenciesBloc>().add(const LoadCurrencies());
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
            const Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
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
