import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/currency.dart';
import '../entities/currency_result.dart';

abstract class CurrencyRepository {
  Future<Either<Failure, CurrencyResult>> getCurrencies({bool forceRefresh = false});
  Future<Either<Failure, void>> cacheCurrencies(List<Currency> currencies);
}
