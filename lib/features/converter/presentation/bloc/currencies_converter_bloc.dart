import 'package:currency_converter/features/converter/data/models/currency.dart';
import 'package:currency_converter/features/converter/domain/usecases/get_currencies.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/convert_currency.dart';
import 'currencies_converter_event.dart';
import 'converter_state.dart';

class CurrenciesConverterBloc
    extends Bloc<CurrenciesConverterEvent, CurrenciesConverterState> {
  final ConvertCurrency convertCurrency;
  final GetCurrencies getCurrencies;

  static const defaultDisplayedCurrencyIds = ['USD', 'JOD'];

  CurrenciesConverterBloc({
    required this.convertCurrency,
    required this.getCurrencies,
  }) : super(const CurrenciesConverterState()) {
    on<SelectFromCurrency>(_onSelectFromCurrency);
    on<SelectToCurrency>(_onSelectToCurrency);
    on<UpdateAmount>(_onUpdateAmount);
    on<ConvertCurrencyEvent>(_onConvertCurrency);
    on<SwapCurrencies>(_onSwapCurrencies);
    on<ResetConverter>(_onResetConverter);
    on<LoadCurrencies>(_onLoadCurrencies);
    on<RefreshCurrencies>(_onRefreshCurrencies);
    on<ForceRefreshCurrencies>(_onForceRefreshCurrencies);
    on<SearchCurrencies>(_onSearchCurrencies);
    on<ReorderCurrencies>(_onReorderCurrencies);
    on<SelectCurrency>(_onSelectCurrency);
    on<AddCurrencyToDisplayed>(_onAddCurrencyToDisplayed);
    on<RemoveCurrencyFromDisplayed>(_onRemoveCurrencyFromDisplayed);
    on<ReplaceCurrencyInDisplayed>(_onReplaceCurrencyInDisplayed);
    // Rate editing events
    on<StartEditingRate>(_onStartEditingRate);
    on<CancelEditingRate>(_onCancelEditingRate);
    on<NumpadDigitPressed>(_onNumpadDigitPressed);
    on<NumpadOperationPressed>(_onNumpadOperationPressed);
    on<NumpadClear>(_onNumpadClear);
    on<NumpadDelete>(_onNumpadDelete);
    on<ApplyRateChange>(_onApplyRateChange);
  }

  void _onSelectCurrency(
    SelectCurrency event,
    Emitter<CurrenciesConverterState> emit,
  ) {
    emit(state.copyWith(selectedCurrency: event.currency));
  }

  Future<void> _onLoadCurrencies(
    LoadCurrencies event,
    Emitter<CurrenciesConverterState> emit,
  ) async {
    emit(
      state.copyWith(
        currencyListStatus: CurrencyListStatus.loading,
        clearCurrencyListError: true,
      ),
    );

    final result = await getCurrencies(const GetCurrenciesParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          currencyListStatus: CurrencyListStatus.error,
          currencyListError: failure.message,
        ),
      ),
      (currencyResult) {
        // Initialize displayed currencies if empty
        List<Currency> displayed = state.displayedCurrencies;
        if (displayed.isEmpty) {
          displayed = currencyResult.currencies
              .where((c) => defaultDisplayedCurrencyIds.contains(c.id))
              .toList();
        }

        emit(
          state.copyWith(
            currencyListStatus: CurrencyListStatus.loaded,
            currencies: currencyResult.currencies,
            filteredCurrencies: currencyResult.currencies,
            displayedCurrencies: displayed,
            lastUpdated: DateTime.now(),
            dataSource: currencyResult.source,
            selectedCurrency: displayed.isNotEmpty ? displayed.first : null,
          ),
        );
      },
    );
  }

  void _onReorderCurrencies(
    ReorderCurrencies event,
    Emitter<CurrenciesConverterState> emit,
  ) {
    final List<Currency> reordered = List.from(state.displayedCurrencies);
    final Currency item = reordered.removeAt(event.oldIndex);
    reordered.insert(event.newIndex, item);

    emit(state.copyWith(displayedCurrencies: reordered));
  }

  void _onAddCurrencyToDisplayed(
    AddCurrencyToDisplayed event,
    Emitter<CurrenciesConverterState> emit,
  ) {
    // Check if currency already exists in displayed list
    if (state.displayedCurrencies.any((c) => c.id == event.currency.id)) {
      return;
    }

    final List<Currency> updated = [...state.displayedCurrencies, event.currency];
    emit(state.copyWith(displayedCurrencies: updated));
  }

  void _onRemoveCurrencyFromDisplayed(
    RemoveCurrencyFromDisplayed event,
    Emitter<CurrenciesConverterState> emit,
  ) {
    final List<Currency> updated = state.displayedCurrencies
        .where((c) => c.id != event.currency.id)
        .toList();

    // Update selected currency if the removed one was selected
    Currency? newSelected = state.selectedCurrency;
    if (state.selectedCurrency?.id == event.currency.id) {
      newSelected = updated.isNotEmpty ? updated.first : null;
    }

    emit(state.copyWith(
      displayedCurrencies: updated,
      selectedCurrency: newSelected,
    ));
  }

  void _onReplaceCurrencyInDisplayed(
    ReplaceCurrencyInDisplayed event,
    Emitter<CurrenciesConverterState> emit,
  ) {
    // Find the index of the old currency
    final index = state.displayedCurrencies.indexWhere(
      (c) => c.id == event.oldCurrency.id,
    );

    if (index == -1) return;

    // Check if new currency already exists in the list
    final existingIndex = state.displayedCurrencies.indexWhere(
      (c) => c.id == event.newCurrency.id,
    );

    List<Currency> updated;
    if (existingIndex != -1 && existingIndex != index) {
      // New currency already exists, swap positions
      updated = List.from(state.displayedCurrencies);
      updated[index] = event.newCurrency;
      updated[existingIndex] = event.oldCurrency;
    } else {
      // Replace old currency with new one at the same position
      updated = List.from(state.displayedCurrencies);
      updated[index] = event.newCurrency;
    }

    // Update selected currency to the new one
    emit(state.copyWith(
      displayedCurrencies: updated,
      selectedCurrency: event.newCurrency,
    ));
  }

  Future<void> _onRefreshCurrencies(
    RefreshCurrencies event,
    Emitter<CurrenciesConverterState> emit,
  ) async {
    final result = await getCurrencies(const GetCurrenciesParams());

    result.fold(
      (failure) {
        // Keep existing data on refresh failure, only show error if no data
        if (state.currencies.isEmpty) {
          emit(
            state.copyWith(
              currencyListStatus: CurrencyListStatus.error,
              currencyListError: failure.message,
            ),
          );
        }
      },
      (currencyResult) {
        final filtered = _filterCurrencies(
          currencyResult.currencies,
          state.searchQuery,
        );
        emit(
          state.copyWith(
            currencyListStatus: CurrencyListStatus.loaded,
            currencies: currencyResult.currencies,
            filteredCurrencies: filtered,
            dataSource: currencyResult.source,
          ),
        );
      },
    );
  }

  Future<void> _onForceRefreshCurrencies(
    ForceRefreshCurrencies event,
    Emitter<CurrenciesConverterState> emit,
  ) async {
    emit(
      state.copyWith(
        currencyListStatus: CurrencyListStatus.loading,
        clearCurrencyListError: true,
      ),
    );

    final result = await getCurrencies(
      const GetCurrenciesParams(forceRefresh: true),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          currencyListStatus: CurrencyListStatus.error,
          currencyListError: failure.message,
        ),
      ),
      (currencyResult) {
        // Update displayed currencies with new rates from API
        final updatedDisplayed = state.displayedCurrencies.map((displayed) {
          try {
            return currencyResult.currencies.firstWhere(
              (c) => c.id == displayed.id,
            );
          } catch (_) {
            // Currency not found in fresh data, keep the old one
            return displayed;
          }
        }).toList();

        emit(
          state.copyWith(
            currencyListStatus: CurrencyListStatus.loaded,
            currencies: currencyResult.currencies,
            filteredCurrencies: currencyResult.currencies,
            displayedCurrencies: updatedDisplayed,
            lastUpdated: DateTime.now(),
            dataSource: currencyResult.source,
          ),
        );
      },
    );
  }

  void _onSearchCurrencies(
    SearchCurrencies event,
    Emitter<CurrenciesConverterState> emit,
  ) {
    final filtered = _filterCurrencies(state.currencies, event.query);
    emit(
      state.copyWith(filteredCurrencies: filtered, searchQuery: event.query),
    );
  }

  List<Currency> _filterCurrencies(List<Currency> currencies, String query) {
    if (query.isEmpty) return currencies;

    final lowerQuery = query.toLowerCase();
    return currencies.where((currency) {
      return currency.name.toLowerCase().contains(lowerQuery) ||
          currency.id.toLowerCase().contains(lowerQuery) ||
          (currency.symbol?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  void _onSelectFromCurrency(
    SelectFromCurrency event,
    Emitter<CurrenciesConverterState> emit,
  ) {
    emit(state.copyWith(fromCurrency: event.currency, clearResult: true));
  }

  void _onSelectToCurrency(
    SelectToCurrency event,
    Emitter<CurrenciesConverterState> emit,
  ) {
    emit(state.copyWith(toCurrency: event.currency, clearResult: true));
  }

  void _onUpdateAmount(
    UpdateAmount event,
    Emitter<CurrenciesConverterState> emit,
  ) {
    emit(state.copyWith(amount: event.amount, clearResult: true));
  }

  Future<void> _onConvertCurrency(
    ConvertCurrencyEvent event,
    Emitter<CurrenciesConverterState> emit,
  ) async {
    if (!state.canConvert) return;

    emit(state.copyWith(status: ConverterStatus.loading, clearError: true));

    final result = await convertCurrency(
      ConvertCurrencyParams(
        fromCurrency: state.fromCurrency!.id,
        toCurrency: state.toCurrency!.id,
        amount: double.parse(state.amount),
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ConverterStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (conversionResult) => emit(
        state.copyWith(
          status: ConverterStatus.success,
          result: conversionResult,
        ),
      ),
    );
  }

  void _onSwapCurrencies(
    SwapCurrencies event,
    Emitter<CurrenciesConverterState> emit,
  ) {
    if (state.fromCurrency == null || state.toCurrency == null) return;

    emit(
      state.copyWith(
        fromCurrency: state.toCurrency,
        toCurrency: state.fromCurrency,
        clearResult: true,
      ),
    );
  }

  void _onResetConverter(
    ResetConverter event,
    Emitter<CurrenciesConverterState> emit,
  ) {
    // Keep currencies loaded, only reset converter state
    emit(
      state.copyWith(
        status: ConverterStatus.initial,
        fromCurrency: null,
        toCurrency: null,
        amount: '',
        clearResult: true,
        clearError: true,
      ),
    );
  }

  // Rate editing handlers
  void _onStartEditingRate(
    StartEditingRate event,
    Emitter<CurrenciesConverterState> emit,
  ) {
    if (state.selectedCurrency == null) return;

    emit(state.copyWith(
      isEditingRate: true,
      editingRateValue: state.selectedCurrency!.rate.toString(),
      clearCalculator: true,
    ));
  }

  void _onCancelEditingRate(
    CancelEditingRate event,
    Emitter<CurrenciesConverterState> emit,
  ) {
    emit(state.copyWith(
      isEditingRate: false,
      editingRateValue: '',
      clearCalculator: true,
    ));
  }

  void _onNumpadDigitPressed(
    NumpadDigitPressed event,
    Emitter<CurrenciesConverterState> emit,
  ) {
    String currentValue = state.editingRateValue;

    // Handle decimal point
    if (event.digit == '.') {
      if (currentValue.contains('.')) return; // Already has decimal
      if (currentValue.isEmpty) {
        currentValue = '0';
      }
    }

    // Prevent leading zeros (except for decimal like "0.5")
    if (currentValue == '0' && event.digit != '.') {
      currentValue = '';
    }

    emit(state.copyWith(editingRateValue: currentValue + event.digit));
  }

  void _onNumpadOperationPressed(
    NumpadOperationPressed event,
    Emitter<CurrenciesConverterState> emit,
  ) {
    final currentValue = state.editingRateValue;
    if (currentValue.isEmpty) return;

    final currentNumber = double.tryParse(currentValue);
    if (currentNumber == null) return;

    // If there's already an operation pending, calculate first
    if (state.calculatorFirstOperand != null &&
        state.calculatorOperator != null) {
      final result = _performCalculation(
        state.calculatorFirstOperand!,
        currentNumber,
        state.calculatorOperator!,
      );
      emit(state.copyWith(
        calculatorFirstOperand: result,
        calculatorOperator: event.operation,
        editingRateValue: '',
      ));
    } else {
      emit(state.copyWith(
        calculatorFirstOperand: currentNumber,
        calculatorOperator: event.operation,
        editingRateValue: '',
      ));
    }
  }

  void _onNumpadClear(
    NumpadClear event,
    Emitter<CurrenciesConverterState> emit,
  ) {
    emit(state.copyWith(
      editingRateValue: '',
      clearCalculator: true,
    ));
  }

  void _onNumpadDelete(
    NumpadDelete event,
    Emitter<CurrenciesConverterState> emit,
  ) {
    final currentValue = state.editingRateValue;
    if (currentValue.isEmpty) return;

    emit(state.copyWith(
      editingRateValue: currentValue.substring(0, currentValue.length - 1),
    ));
  }

  void _onApplyRateChange(
    ApplyRateChange event,
    Emitter<CurrenciesConverterState> emit,
  ) {
    if (state.selectedCurrency == null) {
      emit(state.copyWith(isEditingRate: false, clearCalculator: true));
      return;
    }

    // Calculate final value if operation is pending
    double? finalValue;
    final currentValue = state.editingRateValue;

    if (state.calculatorFirstOperand != null &&
        state.calculatorOperator != null &&
        currentValue.isNotEmpty) {
      final secondOperand = double.tryParse(currentValue);
      if (secondOperand != null) {
        finalValue = _performCalculation(
          state.calculatorFirstOperand!,
          secondOperand,
          state.calculatorOperator!,
        );
      }
    } else if (currentValue.isNotEmpty) {
      finalValue = double.tryParse(currentValue);
    }

    if (finalValue == null || finalValue <= 0) {
      // Invalid value, just close the numpad
      emit(state.copyWith(
        isEditingRate: false,
        editingRateValue: '',
        clearCalculator: true,
      ));
      return;
    }

    // Calculate the multiplier to scale all rates
    final oldSelectedRate = state.selectedCurrency!.rate.toDouble();
    final multiplier = finalValue / oldSelectedRate;

    // Update all displayed currencies with the new scaled rates
    final updatedDisplayed = state.displayedCurrencies.map((currency) {
      final newRate = currency.rate.toDouble() * multiplier;
      return currency.copyWith(rate: newRate);
    }).toList();

    // Update the selected currency reference
    final updatedSelected = updatedDisplayed.firstWhere(
      (c) => c.id == state.selectedCurrency!.id,
    );

    emit(state.copyWith(
      isEditingRate: false,
      editingRateValue: '',
      clearCalculator: true,
      displayedCurrencies: updatedDisplayed,
      selectedCurrency: updatedSelected,
    ));
  }

  double _performCalculation(
      double first, double second, String operation) {
    switch (operation) {
      case '+':
        return first + second;
      case '-':
        return first - second;
      case '×':
        return first * second;
      case '÷':
        if (second == 0) return first; // Prevent division by zero
        return first / second;
      default:
        return second;
    }
  }
}
