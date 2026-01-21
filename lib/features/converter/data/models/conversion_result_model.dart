import '../../domain/entities/conversion_result.dart';

class ConversionResultModel extends ConversionResult {
  const ConversionResultModel({
    required super.fromCurrency,
    required super.toCurrency,
    required super.amount,
    required super.rate,
    required super.convertedAmount,
    required super.timestamp,
  });

  factory ConversionResultModel.fromApiResponse({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
    required Map<String, dynamic> json,
  }) {
    final key = '${fromCurrency}_$toCurrency';
    final rate = (json[key] as num?)?.toDouble() ?? 0.0;

    return ConversionResultModel(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      amount: amount,
      rate: rate,
      convertedAmount: amount * rate,
      timestamp: DateTime.now(),
    );
  }

  factory ConversionResultModel.fromRate({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
    required double rate,
  }) {
    return ConversionResultModel(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      amount: amount,
      rate: rate,
      convertedAmount: amount * rate,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'amount': amount,
      'rate': rate,
      'convertedAmount': convertedAmount,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
