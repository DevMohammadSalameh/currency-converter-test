import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/conversion_result.dart';
import '../../domain/repositories/converter_repository.dart';
import '../datasources/converter_local_data_source.dart';
import '../datasources/converter_remote_data_source.dart';
import '../models/conversion_result_model.dart';

@LazySingleton(as: ConverterRepository)
class ConverterRepositoryImpl implements ConverterRepository {
  final ConverterRemoteDataSource remoteDataSource;
  final ConverterLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ConverterRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ConversionResult>> convertCurrency({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    // If same currency, return 1:1 rate
    if (fromCurrency == toCurrency) {
      return Right(ConversionResultModel.fromRate(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        amount: amount,
        rate: 1.0,
      ));
    }

    // 1. Check cache first - load from database if available
    final cachedRate = await localDataSource.getCachedRate(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
    );

    if (cachedRate != null) {
      return Right(ConversionResultModel.fromRate(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        amount: amount,
        rate: cachedRate,
      ));
    }

    // 2. Cache miss - fetch from API if online
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.convertCurrency(
          fromCurrency: fromCurrency,
          toCurrency: toCurrency,
          amount: amount,
        );

        // Cache the rate for future usage
        await localDataSource.cacheRate(
          fromCurrency: fromCurrency,
          toCurrency: toCurrency,
          rate: result.rate,
        );

        return Right(result);
      } on ServerException catch (e) {
        return Left(ConversionFailure(e.message));
      }
    }

    // 3. Offline and no cache
    return const Left(
      NetworkFailure('No cached rate and no network connection'),
    );
  }

  @override
  Future<Either<Failure, double>> getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (fromCurrency == toCurrency) {
      return const Right(1.0);
    }

    // 1. Check cache first - load from database if available
    final cachedRate = await localDataSource.getCachedRate(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
    );

    if (cachedRate != null) {
      return Right(cachedRate);
    }

    // 2. Cache miss - fetch from API if online
    if (await networkInfo.isConnected) {
      try {
        final rate = await remoteDataSource.getExchangeRate(
          fromCurrency: fromCurrency,
          toCurrency: toCurrency,
        );

        // Cache the rate for future usage
        await localDataSource.cacheRate(
          fromCurrency: fromCurrency,
          toCurrency: toCurrency,
          rate: rate,
        );

        return Right(rate);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    }

    // 3. Offline and no cache
    return const Left(
      NetworkFailure('No cached rate and no network connection'),
    );
  }
}
