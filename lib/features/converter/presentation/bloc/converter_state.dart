import 'package:equatable/equatable.dart';

import '../../data/models/currency.dart';
import '../../domain/entities/conversion_result.dart';

enum ConverterStatus { initial, loading, success, failure }

enum CurrencyListStatus { initial, loading, loaded, error }

class CurrenciesConverterState extends Equatable {
  // Converter fields
  final ConverterStatus status;
  final Currency? fromCurrency;
  final Currency? toCurrency;
  final String amount;
  final ConversionResult? result;
  final String? errorMessage;

  // Currency list fields
  final CurrencyListStatus currencyListStatus;
  final List<Currency> currencies;
  final List<Currency> filteredCurrencies;
  final String searchQuery;
  final String? currencyListError;

  // Last updated
  final DateTime? lastUpdated;

  // Selected currency
  final Currency? selectedCurrency;

  // Displayed currencies (for reorderable list)
  final List<Currency> displayedCurrencies;

  const CurrenciesConverterState({
    this.status = ConverterStatus.initial,
    this.fromCurrency,
    this.toCurrency,
    this.amount = '',
    this.result,
    this.errorMessage,
    this.currencyListStatus = CurrencyListStatus.initial,
    this.currencies = const [],
    this.filteredCurrencies = const [],
    this.searchQuery = '',
    this.currencyListError,
    this.lastUpdated,
    this.selectedCurrency,
    this.displayedCurrencies = const [],
  });

  bool get canConvert =>
      fromCurrency != null &&
      toCurrency != null &&
      amount.isNotEmpty &&
      double.tryParse(amount) != null &&
      double.parse(amount) > 0;

  bool get isCurrencyListLoading =>
      currencyListStatus == CurrencyListStatus.loading;

  bool get isCurrencyListLoaded =>
      currencyListStatus == CurrencyListStatus.loaded;

  bool get hasCurrencyListError =>
      currencyListStatus == CurrencyListStatus.error;

  CurrenciesConverterState copyWith({
    ConverterStatus? status,
    Currency? fromCurrency,
    Currency? toCurrency,
    String? amount,
    ConversionResult? result,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
    CurrencyListStatus? currencyListStatus,
    List<Currency>? currencies,
    List<Currency>? filteredCurrencies,
    String? searchQuery,
    String? currencyListError,
    bool clearCurrencyListError = false,
    DateTime? lastUpdated,
    Currency? selectedCurrency,
    List<Currency>? displayedCurrencies,
  }) {
    return CurrenciesConverterState(
      status: status ?? this.status,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      amount: amount ?? this.amount,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currencyListStatus: currencyListStatus ?? this.currencyListStatus,
      currencies: currencies ?? this.currencies,
      filteredCurrencies: filteredCurrencies ?? this.filteredCurrencies,
      searchQuery: searchQuery ?? this.searchQuery,
      currencyListError: clearCurrencyListError
          ? null
          : (currencyListError ?? this.currencyListError),
      lastUpdated: lastUpdated ?? this.lastUpdated,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      displayedCurrencies: displayedCurrencies ?? this.displayedCurrencies,
    );
  }

  @override
  List<Object?> get props => [
    status,
    fromCurrency,
    toCurrency,
    amount,
    result,
    errorMessage,
    currencyListStatus,
    currencies,
    filteredCurrencies,
    searchQuery,
    currencyListError,
    lastUpdated,
    selectedCurrency,
    displayedCurrencies,
  ];
}
