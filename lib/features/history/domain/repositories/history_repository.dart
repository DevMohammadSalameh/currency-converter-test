import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/historical_rate.dart';

abstract class HistoryRepository {
  Future<Either<Failure, List<HistoricalRate>>> getHistoricalRates({
    required String fromCurrency,
    required String toCurrency,
    required DateTime startDate,
    required DateTime endDate,
  });
}
