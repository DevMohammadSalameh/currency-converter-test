import 'package:equatable/equatable.dart';

import '../../../currencies/domain/entities/currency.dart';

abstract class ConverterEvent extends Equatable {
  const ConverterEvent();

  @override
  List<Object?> get props => [];
}

class SelectFromCurrency extends ConverterEvent {
  final Currency currency;

  const SelectFromCurrency(this.currency);

  @override
  List<Object?> get props => [currency];
}

class SelectToCurrency extends ConverterEvent {
  final Currency currency;

  const SelectToCurrency(this.currency);

  @override
  List<Object?> get props => [currency];
}

class UpdateAmount extends ConverterEvent {
  final String amount;

  const UpdateAmount(this.amount);

  @override
  List<Object?> get props => [amount];
}

class ConvertCurrencyEvent extends ConverterEvent {
  const ConvertCurrencyEvent();
}

class SwapCurrencies extends ConverterEvent {
  const SwapCurrencies();
}

class ResetConverter extends ConverterEvent {
  const ResetConverter();
}
