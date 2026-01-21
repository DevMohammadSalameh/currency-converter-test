import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../models/currency.dart';
import '../../domain/repositories/currency_repository.dart';
import '../datasources/currency_local_data_source.dart';
import '../datasources/currency_remote_data_source.dart';
import '../models/currency_model.dart';

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
  Future<Either<Failure, List<Currency>>> getCurrencies() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteCurrencies = await remoteDataSource.getCurrencies();
        await localDataSource.cacheCurrencies(remoteCurrencies);
        return Right(remoteCurrencies);
      } on ServerException catch (e) {
        // If remote fails, try to get cached data
        try {
          final cachedCurrencies = await localDataSource.getCachedCurrencies();
          return Right(cachedCurrencies);
        } on CacheException {
          return Left(ServerFailure(e.message));
        }
      }
    } else {
      try {
        final cachedCurrencies = await localDataSource.getCachedCurrencies();
        return Right(cachedCurrencies);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
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
