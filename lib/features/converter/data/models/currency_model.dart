import 'package:currency_converter/features/converter/data/models/currency.dart';

class CurrencyModel extends Currency {
  const CurrencyModel({
    required super.id,
    required super.name,
    required super.rate,
    super.symbol,
    super.countryCode,
  });

  factory CurrencyModel.fromJson(String id, Map<String, dynamic> json) {
    // Extract country code from currency ID (first 2 characters typically)
    String? extractedCountryCode;
    if (id.length >= 2) {
      extractedCountryCode = id.substring(0, 2).toLowerCase();
    }

    return CurrencyModel(
      id: id,
      name: json['currencyName'] ?? json['name'] ?? '',
      rate: json['rate'] ?? 1,
      symbol: json['currencySymbol'] ?? json['symbol'],
      countryCode:
          json['id']?.toString().substring(0, 2).toLowerCase() ??
          extractedCountryCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'currencyName': name, 'currencySymbol': symbol};
  }

  factory CurrencyModel.fromDatabase(Map<String, dynamic> map) {
    return CurrencyModel(
      id: map['id'] as String,
      name: map['name'] as String,
      rate: map['rate'] as num,
      symbol: map['symbol'] as String?,
      countryCode: map['country_code'] as String?,
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'name': name,
      'rate': rate,
      'symbol': symbol,
      'country_code': countryCode,
    };
  }

  factory CurrencyModel.fromEntity(Currency currency) {
    return CurrencyModel(
      id: currency.id,
      name: currency.name,
      rate: currency.rate,
      symbol: currency.symbol,
      countryCode: currency.countryCode,
    );
  }
}
