import 'package:currency_converter/features/converter/presentation/widgets/currencies_list.dart';
import 'package:currency_converter/features/converter/presentation/widgets/custom_numpad.dart';
import 'package:currency_converter/features/history/presentation/view/history_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/gradient_scaffold.dart';
import 'currency_list_view.dart';
import '../bloc/currencies_converter_bloc.dart';
import '../bloc/currencies_converter_event.dart';
import '../bloc/converter_state.dart';

class ConverterView extends StatefulWidget {
  const ConverterView({super.key});

  @override
  State<ConverterView> createState() => _ConverterViewState();
}

class _ConverterViewState extends State<ConverterView> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Currency Converter', style: TextStyle(fontSize: 18)),
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 90,
        leading: IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () => _showSnackBar(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _navigateToHistory(context),
            tooltip: 'View History',
          ),
        ],
      ),
      body: BlocConsumer<CurrenciesConverterBloc, CurrenciesConverterState>(
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
          return Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 90),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (state.lastUpdated != null)
                              // Last Time Updated
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Last Time Updated: ${_formatTime(state.lastUpdated!)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const CurrenciesList(),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32),
                                    // border: Border.all(
                                    //   color: Theme.of(context)
                                    //       .colorScheme
                                    //       .primary
                                    //       .withValues(alpha: 0.2),
                                    // ),
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.1),
                                  ),
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    onPressed: state.isEditingRate
                                        ? null
                                        : () =>
                                              _navigateToCurrencyList(context),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add'),
                                  ),
                                ),
                                const Spacer(),
                                // Info Text
                                const Text(
                                  'Click to view usage guide',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                // Info Button
                                IconButton(
                                  onPressed: () => _showInfoSnackBar(context),
                                  icon: const Icon(Icons.info_outline),
                                  tooltip: 'Info',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Scrim overlay when editing
              if (state.isEditingRate)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      context.read<CurrenciesConverterBloc>().add(
                        const CancelEditingRate(),
                      );
                    },
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              // Numpad slide up from bottom
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                left: 0,
                right: 0,
                bottom: state.isEditingRate ? 0 : -500,
                child: const CustomNumpad(),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'This feature is not implemented yet, Hire me to see the full app',
        ),
      ),
    );
  }

  void _showInfoSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '- Long press and drag to reorder.\n- Swipe left to delete.\n- Click on the selected currency to edit the rate and convert.',
        ),
      ),
    );
  }

  void _navigateToCurrencyList(BuildContext context) {
    final bloc = context.read<CurrenciesConverterBloc>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: CurrencyListView(
            title: 'Add Currency',
            onCurrencySelected: (currency) {
              // Add currency to displayed list
              final currentDisplayed = List.of(bloc.state.displayedCurrencies);
              if (!currentDisplayed.any((c) => c.id == currency.id)) {
                bloc.add(AddCurrencyToDisplayed(currency));
              }
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  void _navigateToHistory(BuildContext context) {
    final converterState = context.read<CurrenciesConverterBloc>().state;

    if (converterState.fromCurrency == null ||
        converterState.toCurrency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both currencies first')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HistoryView(
          fromCurrency: converterState.fromCurrency!,
          toCurrency: converterState.toCurrency!,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    Map<int, String> months = {
      1: 'Jan',
      2: 'Feb',
      3: 'Mar',
      4: 'Apr',
      5: 'May',
      6: 'Jun',
      7: 'Jul',
      8: 'Aug',
      9: 'Sep',
      10: 'Oct',
      11: 'Nov',
      12: 'Dec',
    };
    return '${time.day} ${months[time.month]} ${time.year} ${time.hour}:${time.minute}';
  }
}
