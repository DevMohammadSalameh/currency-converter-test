import 'package:equatable/equatable.dart';

class HistoricalRate extends Equatable {
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final DateTime date;

  const HistoricalRate({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.date,
  });

  @override
  List<Object?> get props => [fromCurrency, toCurrency, rate, date];
}
