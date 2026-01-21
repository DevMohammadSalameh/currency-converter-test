import 'package:equatable/equatable.dart';

import '../../../../core/enums/data_source.dart';
import '../../data/models/currency.dart';

/// Wrapper class that holds currencies along with their data source
class CurrencyResult extends Equatable {
  final List<Currency> currencies;
  final DataSource source;

  const CurrencyResult({
    required this.currencies,
    required this.source,
  });

  @override
  List<Object?> get props => [currencies, source];
}
