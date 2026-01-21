import 'package:equatable/equatable.dart';

class Currency extends Equatable {
  final String id;
  final String name;
  final String? symbol;
  final String? countryCode;
  final num rate;

  const Currency({
    required this.id,
    required this.name,
    this.symbol,
    this.countryCode,
    required this.rate,
  });

  String get flagUrl {
    if (countryCode == null || countryCode!.isEmpty) {
      return '';
    }
    return 'https://flagcdn.com/w80/${countryCode!.toLowerCase()}.png';
  }

  Currency copyWith({
    String? id,
    String? name,
    String? symbol,
    String? countryCode,
    num? rate,
  }) {
    return Currency(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      countryCode: countryCode ?? this.countryCode,
      rate: rate ?? this.rate,
    );
  }

  @override
  List<Object?> get props => [id, name, symbol, countryCode, rate];
}
