import 'package:equatable/equatable.dart';

import '../../../currencies/domain/entities/currency.dart';
import '../../domain/entities/conversion_result.dart';

enum ConverterStatus {
  initial,
  loading,
  success,
  failure,
}

class ConverterState extends Equatable {
  final ConverterStatus status;
  final Currency? fromCurrency;
  final Currency? toCurrency;
  final String amount;
  final ConversionResult? result;
  final String? errorMessage;

  const ConverterState({
    this.status = ConverterStatus.initial,
    this.fromCurrency,
    this.toCurrency,
    this.amount = '',
    this.result,
    this.errorMessage,
  });

  bool get canConvert =>
      fromCurrency != null &&
      toCurrency != null &&
      amount.isNotEmpty &&
      double.tryParse(amount) != null &&
      double.parse(amount) > 0;

  ConverterState copyWith({
    ConverterStatus? status,
    Currency? fromCurrency,
    Currency? toCurrency,
    String? amount,
    ConversionResult? result,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return ConverterState(
      status: status ?? this.status,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      amount: amount ?? this.amount,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
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
      ];
}
