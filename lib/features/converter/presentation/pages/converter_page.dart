import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../currencies/presentation/bloc/currencies_bloc.dart';
import '../../../currencies/presentation/bloc/currencies_event.dart';
import '../../../currencies/presentation/bloc/currencies_state.dart';
import '../../../currencies/presentation/pages/currency_list_page.dart';
import '../bloc/converter_bloc.dart';
import '../bloc/converter_event.dart';
import '../bloc/converter_state.dart';
import '../widgets/amount_input.dart';
import '../widgets/conversion_result_card.dart';
import '../widgets/currency_selector.dart';

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _navigateToHistory(context),
            tooltip: 'View History',
          ),
        ],
      ),
      body: BlocConsumer<ConverterBloc, ConverterState>(
        listener: (context, state) {
          if (state.status == ConverterStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AmountInput(
                  controller: _amountController,
                  onChanged: (value) {
                    context.read<ConverterBloc>().add(UpdateAmount(value));
                  },
                  currencySymbol: state.fromCurrency?.symbol,
                  hintText: 'Enter amount',
                ),
                const SizedBox(height: 24),
                CurrencySelector(
                  selectedCurrency: state.fromCurrency,
                  label: 'From',
                  onTap: () => _selectCurrency(context, isFrom: true),
                ),
                const SizedBox(height: 16),
                Center(
                  child: IconButton.filled(
                    onPressed: state.fromCurrency != null &&
                            state.toCurrency != null
                        ? () {
                            context
                                .read<ConverterBloc>()
                                .add(const SwapCurrencies());
                          }
                        : null,
                    icon: const Icon(Icons.swap_vert),
                    tooltip: 'Swap currencies',
                  ),
                ),
                const SizedBox(height: 16),
                CurrencySelector(
                  selectedCurrency: state.toCurrency,
                  label: 'To',
                  onTap: () => _selectCurrency(context, isFrom: false),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: state.canConvert &&
                          state.status != ConverterStatus.loading
                      ? () {
                          context
                              .read<ConverterBloc>()
                              .add(const ConvertCurrencyEvent());
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: state.status == ConverterStatus.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Convert'),
                ),
                const SizedBox(height: 24),
                if (state.result != null)
                  ConversionResultCard(result: state.result!),
              ],
            ),
          );
        },
      ),
    );
  }

  void _selectCurrency(BuildContext context, {required bool isFrom}) {
    final converterBloc = context.read<ConverterBloc>();
    final currenciesBloc = context.read<CurrenciesBloc>();

    // Ensure currencies are loaded
    if (currenciesBloc.state is! CurrenciesLoaded) {
      currenciesBloc.add(const LoadCurrencies());
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: currenciesBloc,
          child: CurrencyListPage(
            title: isFrom ? 'Select From Currency' : 'Select To Currency',
            selectedCurrency: isFrom
                ? converterBloc.state.fromCurrency
                : converterBloc.state.toCurrency,
            onCurrencySelected: (currency) {
              if (isFrom) {
                converterBloc.add(SelectFromCurrency(currency));
              } else {
                converterBloc.add(SelectToCurrency(currency));
              }
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  void _navigateToHistory(BuildContext context) {
    final converterState = context.read<ConverterBloc>().state;

    if (converterState.fromCurrency == null ||
        converterState.toCurrency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both currencies first'),
        ),
      );
      return;
    }

    Navigator.of(context).pushNamed(
      '/history',
      arguments: {
        'fromCurrency': converterState.fromCurrency,
        'toCurrency': converterState.toCurrency,
      },
    );
  }
}
