import 'package:equatable/equatable.dart';

abstract class CurrenciesEvent extends Equatable {
  const CurrenciesEvent();

  @override
  List<Object?> get props => [];
}

class LoadCurrencies extends CurrenciesEvent {
  const LoadCurrencies();
}

class RefreshCurrencies extends CurrenciesEvent {
  const RefreshCurrencies();
}

class SearchCurrencies extends CurrenciesEvent {
  final String query;

  const SearchCurrencies(this.query);

  @override
  List<Object?> get props => [query];
}
