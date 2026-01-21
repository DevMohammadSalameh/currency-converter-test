import 'package:equatable/equatable.dart';

class Currency extends Equatable {
  final String id;
  final String name;
  final String? symbol;
  final String? countryCode;

  const Currency({
    required this.id,
    required this.name,
    this.symbol,
    this.countryCode,
  });

  String get flagUrl {
    if (countryCode == null || countryCode!.isEmpty) {
      return '';
    }
    return 'https://flagcdn.com/w80/${countryCode!.toLowerCase()}.png';
  }

  @override
  List<Object?> get props => [id, name, symbol, countryCode];
}
