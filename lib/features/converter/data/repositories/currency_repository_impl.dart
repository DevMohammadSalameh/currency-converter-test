import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/enums/data_source.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../models/currency.dart';
import '../../domain/entities/currency_result.dart';
import '../../domain/repositories/currency_repository.dart';
import '../datasources/currency_local_data_source.dart';
import '../datasources/currency_remote_data_source.dart';
import '../models/currency_model.dart';

@LazySingleton(as: CurrencyRepository)
class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyRemoteDataSource remoteDataSource;
  final CurrencyLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  CurrencyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, CurrencyResult>> getCurrencies({
    bool forceRefresh = false,
  }) async {
    // If force refresh, skip cache and fetch from API directly
    if (forceRefresh) {
      if (await networkInfo.isConnected) {
        try {
          final remoteCurrencies = await remoteDataSource.getCurrencies();
          await localDataSource.cacheCurrencies(remoteCurrencies);
          return Right(CurrencyResult(
            currencies: remoteCurrencies,
            source: DataSource.api,
          ));
        } on ServerException catch (e) {
          return Left(ServerFailure(e.message));
        }
      } else {
        return const Left(
          NetworkFailure('No internet connection. Cannot refresh from API.'),
        );
      }
    }

    // 1. Check cache first - load from database if available
    final hasCached = await localDataSource.hasCachedCurrencies();
    if (hasCached) {
      try {
        final cachedCurrencies = await localDataSource.getCachedCurrencies();
        return Right(CurrencyResult(
          currencies: cachedCurrencies,
          source: DataSource.cache,
        ));
      } on CacheException {
        // Cache read failed, continue to fetch from API
      }
    }

    // 2. Cache empty - fetch from API if online
    if (await networkInfo.isConnected) {
      try {
        final remoteCurrencies = await remoteDataSource.getCurrencies();
        await localDataSource.cacheCurrencies(remoteCurrencies);
        return Right(CurrencyResult(
          currencies: remoteCurrencies,
          source: DataSource.api,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    }

    // 3. Offline and no cache
    return const Left(
      CacheFailure('No cached currencies and no network connection'),
    );
  }

  @override
  Future<Either<Failure, void>> cacheCurrencies(
    List<Currency> currencies,
  ) async {
    try {
      final models = currencies
          .map((c) => CurrencyModel.fromEntity(c))
          .toList();
      await localDataSource.cacheCurrencies(models);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
