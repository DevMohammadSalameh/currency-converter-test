import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/historical_rate.dart';
import '../repositories/history_repository.dart';

@lazySingleton
class GetHistoricalRates
    implements UseCase<List<HistoricalRate>, GetHistoricalRatesParams> {
  final HistoryRepository repository;

  GetHistoricalRates(this.repository);

  @override
  Future<Either<Failure, List<HistoricalRate>>> call(
      GetHistoricalRatesParams params) async {
    return await repository.getHistoricalRates(
      fromCurrency: params.fromCurrency,
      toCurrency: params.toCurrency,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetHistoricalRatesParams extends Equatable {
  final String fromCurrency;
  final String toCurrency;
  final DateTime startDate;
  final DateTime endDate;

  const GetHistoricalRatesParams({
    required this.fromCurrency,
    required this.toCurrency,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [fromCurrency, toCurrency, startDate, endDate];
}
