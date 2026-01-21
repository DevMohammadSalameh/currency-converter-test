import 'package:currency_converter/core/usecases/usecase.dart';
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
    on<SearchCurrencies>(_onSearchCurrencies);
    on<ReorderCurrencies>(_onReorderCurrencies);
    on<SelectCurrency>(_onSelectCurrency);
    on<AddCurrencyToDisplayed>(_onAddCurrencyToDisplayed);
    on<RemoveCurrencyFromDisplayed>(_onRemoveCurrencyFromDisplayed);
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

    final result = await getCurrencies(NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          currencyListStatus: CurrencyListStatus.error,
          currencyListError: failure.message,
        ),
      ),
      (currencies) {
        // Initialize displayed currencies if empty
        List<Currency> displayed = state.displayedCurrencies;
        if (displayed.isEmpty) {
          displayed = currencies
              .where((c) => defaultDisplayedCurrencyIds.contains(c.id))
              .toList();
        }

        emit(
          state.copyWith(
            currencyListStatus: CurrencyListStatus.loaded,
            currencies: currencies,
            filteredCurrencies: currencies,
            displayedCurrencies: displayed,
            lastUpdated: DateTime.now(),
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

  Future<void> _onRefreshCurrencies(
    RefreshCurrencies event,
    Emitter<CurrenciesConverterState> emit,
  ) async {
    final result = await getCurrencies(NoParams());

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
      (currencies) {
        final filtered = _filterCurrencies(currencies, state.searchQuery);
        emit(
          state.copyWith(
            currencyListStatus: CurrencyListStatus.loaded,
            currencies: currencies,
            filteredCurrencies: filtered,
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
}
