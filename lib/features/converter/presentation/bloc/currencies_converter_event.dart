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

class ForceRefreshCurrencies extends CurrenciesConverterEvent {
  const ForceRefreshCurrencies();
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

class ReplaceCurrencyInDisplayed extends CurrenciesConverterEvent {
  final Currency oldCurrency;
  final Currency newCurrency;

  const ReplaceCurrencyInDisplayed(this.oldCurrency, this.newCurrency);

  @override
  List<Object?> get props => [oldCurrency, newCurrency];
}

// Rate editing events
class StartEditingRate extends CurrenciesConverterEvent {
  const StartEditingRate();
}

class CancelEditingRate extends CurrenciesConverterEvent {
  const CancelEditingRate();
}

class NumpadDigitPressed extends CurrenciesConverterEvent {
  final String digit;

  const NumpadDigitPressed(this.digit);

  @override
  List<Object?> get props => [digit];
}

class NumpadOperationPressed extends CurrenciesConverterEvent {
  final String operation;

  const NumpadOperationPressed(this.operation);

  @override
  List<Object?> get props => [operation];
}

class NumpadClear extends CurrenciesConverterEvent {
  const NumpadClear();
}

class NumpadDelete extends CurrenciesConverterEvent {
  const NumpadDelete();
}

class ApplyRateChange extends CurrenciesConverterEvent {
  const ApplyRateChange();
}
