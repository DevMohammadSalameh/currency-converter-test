import 'package:equatable/equatable.dart';

import '../../domain/entities/currency.dart';

abstract class CurrenciesState extends Equatable {
  const CurrenciesState();

  @override
  List<Object?> get props => [];
}

class CurrenciesInitial extends CurrenciesState {
  const CurrenciesInitial();
}

class CurrenciesLoading extends CurrenciesState {
  const CurrenciesLoading();
}

class CurrenciesLoaded extends CurrenciesState {
  final List<Currency> currencies;
  final List<Currency> filteredCurrencies;
  final String searchQuery;

  const CurrenciesLoaded({
    required this.currencies,
    required this.filteredCurrencies,
    this.searchQuery = '',
  });

  CurrenciesLoaded copyWith({
    List<Currency>? currencies,
    List<Currency>? filteredCurrencies,
    String? searchQuery,
  }) {
    return CurrenciesLoaded(
      currencies: currencies ?? this.currencies,
      filteredCurrencies: filteredCurrencies ?? this.filteredCurrencies,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [currencies, filteredCurrencies, searchQuery];
}

class CurrenciesError extends CurrenciesState {
  final String message;

  const CurrenciesError(this.message);

  @override
  List<Object?> get props => [message];
}
