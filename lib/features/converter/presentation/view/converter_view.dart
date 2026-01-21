import 'package:currency_converter/features/converter/presentation/widgets/currencies_list.dart';
import 'package:currency_converter/features/converter/presentation/widgets/custom_numpad.dart';
import 'package:currency_converter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/enums/data_source.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/widgets/refresh_confirmation_dialog.dart';
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
  bool _isLoadingDialogShowing = false;

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
          icon: Icon(
            ThemeProvider.of(context).isDarkMode
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
          ),
          onPressed: () => ThemeProvider.of(context).toggleTheme(),
          tooltip: 'Toggle theme',
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
        listenWhen: (previous, current) {
          // Only listen when currencyListStatus or converter status changes
          return previous.currencyListStatus != current.currencyListStatus ||
              previous.status != current.status;
        },
        listener: (context, state) {
          // Show loading dialog when currency list is loading
          if (state.currencyListStatus == CurrencyListStatus.loading &&
              !_isLoadingDialogShowing) {
            _isLoadingDialogShowing = true;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading currencies...'),
                      ],
                    ),
                  ),
                ),
              ),
            ).then((_) {
              _isLoadingDialogShowing = false;
            });
          } else if ((state.currencyListStatus == CurrencyListStatus.loaded ||
                  state.currencyListStatus == CurrencyListStatus.error) &&
              _isLoadingDialogShowing) {
            // Dismiss loading dialog only if we showed it
            _isLoadingDialogShowing = false;
            Navigator.of(context).pop();
          }

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
                      child: RefreshIndicator(
                        onRefresh: () => _handleRefresh(context),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              if (state.lastUpdated != null)
                                // Last Time Updated with Data Source Icon
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Last Time Updated: ${_formatTime(state.lastUpdated!)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Data Source Icon
                                      if (state.dataSource != null)
                                        Tooltip(
                                          message:
                                              state.dataSource == DataSource.api
                                              ? 'Fetched from API'
                                              : 'Loaded from local database',
                                          child: Icon(
                                            state.dataSource == DataSource.api
                                                ? Icons.cloud_download
                                                : Icons.storage,
                                            size: 16,
                                            color:
                                                state.dataSource ==
                                                    DataSource.api
                                                ? Theme.of(context).colorScheme.primary
                                                : Theme.of(context).colorScheme.tertiary,
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
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
                                          : () => _navigateToCurrencyList(
                                              context,
                                            ),
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add'),
                                    ),
                                  ),
                                  const Spacer(),
                                  // Info Text
                                  Text(
                                    'Click to view usage guide',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                      color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.3),
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

  Future<void> _handleRefresh(BuildContext context) async {
    final appPreferences = GetIt.instance<AppPreferences>();
    final bloc = context.read<CurrenciesConverterBloc>();

    // Check if user has opted to skip the confirmation dialog
    if (appPreferences.skipRefreshConfirmation) {
      bloc.add(const ForceRefreshCurrencies());
      return;
    }

    // Show confirmation dialog
    final result = await showRefreshConfirmationDialog(context);

    if (result == null) {
      // User cancelled
      return;
    }

    // User confirmed - save preference if "don't ask again" was checked
    if (result) {
      await appPreferences.setSkipRefreshConfirmation(true);
    }

    // Trigger force refresh
    bloc.add(const ForceRefreshCurrencies());
  }

  void _showInfoSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '- Long press and drag to reorder.\n- Swipe left to delete.\n- Click on the selected currency to edit the rate and convert.\n- Click on the add button to add a new currency.\n- Click on the replace button to replace the selected currency with another currency.',
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
    //temp
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('History is not implemented, becuse of API limitations'),
      ),
    );
    return;
    //
    // final converterState = context.read<CurrenciesConverterBloc>().state;

    // if (converterState.fromCurrency == null ||
    //     converterState.toCurrency == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please select both currencies first')),
    //   );
    //   return;
    // }

    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (_) => HistoryView(
    //       fromCurrency: converterState.fromCurrency!,
    //       toCurrency: converterState.toCurrency!,
    //     ),
    //   ),
    // );
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
