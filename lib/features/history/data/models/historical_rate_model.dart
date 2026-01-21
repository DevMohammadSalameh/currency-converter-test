import '../../domain/entities/historical_rate.dart';

class HistoricalRateModel extends HistoricalRate {
  const HistoricalRateModel({
    required super.fromCurrency,
    required super.toCurrency,
    required super.rate,
    required super.date,
  });

  factory HistoricalRateModel.fromApiResponse({
    required String fromCurrency,
    required String toCurrency,
    required String dateString,
    required Map<String, dynamic> rateData,
  }) {
    final key = '${fromCurrency}_$toCurrency';
    final rate = (rateData[key] as num?)?.toDouble() ?? 0.0;

    return HistoricalRateModel(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      rate: rate,
      date: DateTime.parse(dateString),
    );
  }

  factory HistoricalRateModel.fromDatabase(Map<String, dynamic> map) {
    return HistoricalRateModel(
      fromCurrency: map['from_currency'] as String,
      toCurrency: map['to_currency'] as String,
      rate: map['rate'] as double,
      date: DateTime.parse(map['date'] as String),
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'from_currency': fromCurrency,
      'to_currency': toCurrency,
      'rate': rate,
      'date': date.toIso8601String().split('T')[0],
    };
  }
}
