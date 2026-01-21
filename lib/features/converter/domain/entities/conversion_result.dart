import 'package:equatable/equatable.dart';

class ConversionResult extends Equatable {
  final String fromCurrency;
  final String toCurrency;
  final double amount;
  final double rate;
  final double convertedAmount;
  final DateTime timestamp;

  const ConversionResult({
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
    required this.rate,
    required this.convertedAmount,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        fromCurrency,
        toCurrency,
        amount,
        rate,
        convertedAmount,
        timestamp,
      ];
}
