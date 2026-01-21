import 'package:currency_converter/features/converter/presentation/widgets/currencies_list.dart';
import 'package:currency_converter/features/history/presentation/view/history_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/gradient_scaffold.dart';
// import 'currency_list_view.dart';
// import '../bloc/currencies_converter_event.dart';
import '../bloc/currencies_converter_bloc.dart';
import '../bloc/converter_state.dart';
// import '../widgets/amount_input.dart';
// import '../widgets/conversion_result_card.dart';
// import '../widgets/currency_selector.dart';

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
          return Padding(
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
                            padding: const EdgeInsets.symmetric(vertical: 8),
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
                        //Add currency button
                        Row(
                          children: [
                            ,
                          ],
                        ),
                        // AmountInput(
                        //   controller: _amountController,
                        //   onChanged: (value) {
                        //     context.read<CurrenciesConverterBloc>().add(
                        //       UpdateAmount(value),
                        //     );
                        //   },
                        //   currencySymbol: state.fromCurrency?.symbol,
                        //   hintText: 'Enter amount',
                        // ),
                        // const SizedBox(height: 24),
                        // CurrencySelector(
                        //   selectedCurrency: state.fromCurrency,
                        //   label: 'From',
                        //   onTap: () => _selectCurrency(context, isFrom: true),
                        // ),
                        // const SizedBox(height: 16),
                        // Center(
                        //   child: IconButton.filled(
                        //     onPressed:
                        //         state.fromCurrency != null &&
                        //             state.toCurrency != null
                        //         ? () {
                        //             context.read<CurrenciesConverterBloc>().add(
                        //               const SwapCurrencies(),
                        //             );
                        //           }
                        //         : null,
                        //     icon: const Icon(Icons.swap_vert),
                        //     tooltip: 'Swap currencies',
                        //   ),
                        // ),
                        // const SizedBox(height: 16),
                        // CurrencySelector(
                        //   selectedCurrency: state.toCurrency,
                        //   label: 'To',
                        //   onTap: () => _selectCurrency(context, isFrom: false),
                        // ),
                        // const SizedBox(height: 32),
                        // FilledButton(
                        //   onPressed:
                        //       state.canConvert &&
                        //           state.status != ConverterStatus.loading
                        //       ? () {
                        //           context.read<CurrenciesConverterBloc>().add(
                        //             const ConvertCurrencyEvent(),
                        //           );
                        //         }
                        //       : null,
                        //   style: FilledButton.styleFrom(
                        //     padding: const EdgeInsets.symmetric(vertical: 16),
                        //   ),
                        //   child: state.status == ConverterStatus.loading
                        //       ? const SizedBox(
                        //           height: 20,
                        //           width: 20,
                        //           child: CircularProgressIndicator(
                        //             strokeWidth: 2,
                        //             color: Colors.white,
                        //           ),
                        //         )
                        //       : const Text('Convert'),
                        // ),
                        // const SizedBox(height: 24),
                        // if (state.result != null)
                        //   ConversionResultCard(result: state.result!),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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

  // void _selectCurrency(BuildContext context, {required bool isFrom}) {
  //   final converterBloc = context.read<CurrenciesConverterBloc>();

  //   // Ensure currencies are loaded
  //   if (!converterBloc.state.isCurrencyListLoaded) {
  //     converterBloc.add(const LoadCurrencies());
  //   }

  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (_) => BlocProvider.value(
  //         value: converterBloc,
  //         child: CurrencyListView(
  //           title: isFrom ? 'Select From Currency' : 'Select To Currency',
  //           selectedCurrency: isFrom
  //               ? converterBloc.state.fromCurrency
  //               : converterBloc.state.toCurrency,
  //           onCurrencySelected: (currency) {
  //             if (isFrom) {
  //               converterBloc.add(SelectFromCurrency(currency));
  //             } else {
  //               converterBloc.add(SelectToCurrency(currency));
  //             }
  //             Navigator.of(context).pop();
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
    //from 2026-01-21 22:14:16.881442 to 21 Jan 2026 22:14
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
