import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/conversion_result.dart';

abstract class ConverterRepository {
  Future<Either<Failure, ConversionResult>> convertCurrency({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  });

  Future<Either<Failure, double>> getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  });
}
