import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/historical_rate.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_data_source.dart';
import '../datasources/history_remote_data_source.dart';

@LazySingleton(as: HistoryRepository)
class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;
  final HistoryLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  HistoryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<HistoricalRate>>> getHistoricalRates({
    required String fromCurrency,
    required String toCurrency,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteRates = await remoteDataSource.getHistoricalRates(
          fromCurrency: fromCurrency,
          toCurrency: toCurrency,
          startDate: startDate,
          endDate: endDate,
        );

        // Cache the rates
        await localDataSource.cacheHistoricalRates(remoteRates);

        return Right(remoteRates);
      } on ServerException catch (e) {
        // Try cached data on failure
        try {
          final cachedRates = await localDataSource.getCachedHistoricalRates(
            fromCurrency: fromCurrency,
            toCurrency: toCurrency,
            startDate: startDate,
            endDate: endDate,
          );
          return Right(cachedRates);
        } on CacheException {
          return Left(ServerFailure(e.message));
        }
      }
    } else {
      try {
        final cachedRates = await localDataSource.getCachedHistoricalRates(
          fromCurrency: fromCurrency,
          toCurrency: toCurrency,
          startDate: startDate,
          endDate: endDate,
        );
        return Right(cachedRates);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }
}
