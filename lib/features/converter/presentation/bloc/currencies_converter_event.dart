import 'package:equatable/equatable.dart';

import '../../data/models/currency.dart';

abstract class CurrenciesConverterEvent extends Equatable {
  const CurrenciesConverterEvent();

  @override
  List<Object?> get props => [];
}

class SelectFromCurrency extends CurrenciesConverterEvent {
  final Currency currency;

  const SelectFromCurrency(this.currency);

  @override
  List<Object?> get props => [currency];
}

class SelectToCurrency extends CurrenciesConverterEvent {
  final Currency currency;

  const SelectToCurrency(this.currency);

  @override
  List<Object?> get props => [currency];
}

class UpdateAmount extends CurrenciesConverterEvent {
  final String amount;

  const UpdateAmount(this.amount);

  @override
  List<Object?> get props => [amount];
}

class ConvertCurrencyEvent extends CurrenciesConverterEvent {
  const ConvertCurrencyEvent();
}

class SwapCurrencies extends CurrenciesConverterEvent {
  const SwapCurrencies();
}

class ResetConverter extends CurrenciesConverterEvent {
  const ResetConverter();
}

class LoadCurrencies extends CurrenciesConverterEvent {
  const LoadCurrencies();
}

class RefreshCurrencies extends CurrenciesConverterEvent {
  const RefreshCurrencies();
}

class SearchCurrencies extends CurrenciesConverterEvent {
  final String query;

  const SearchCurrencies(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectCurrency extends CurrenciesConverterEvent {
  final Currency currency;

  const SelectCurrency(this.currency);

  @override
  List<Object?> get props => [currency];
}

class ReorderCurrencies extends CurrenciesConverterEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderCurrencies({required this.oldIndex, required this.newIndex});

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class AddCurrencyToDisplayed extends CurrenciesConverterEvent {
  final Currency currency;

  const AddCurrencyToDisplayed(this.currency);

  @override
  List<Object?> get props => [currency];
}

class RemoveCurrencyFromDisplayed extends CurrenciesConverterEvent {
  final Currency currency;

  const RemoveCurrencyFromDisplayed(this.currency);

  @override
  List<Object?> get props => [currency];
}
