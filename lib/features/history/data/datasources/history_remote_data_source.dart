import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../models/historical_rate_model.dart';

abstract class HistoryRemoteDataSource {
  Future<List<HistoricalRateModel>> getHistoricalRates({
    required String fromCurrency,
    required String toCurrency,
    required DateTime startDate,
    required DateTime endDate,
  });
}

@LazySingleton(as: HistoryRemoteDataSource)
class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final Dio dio;

  HistoryRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<HistoricalRateModel>> getHistoricalRates({
    required String fromCurrency,
    required String toCurrency,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // The current API plan (ExchangeRate-API free/standard tier provided) does not support
    // the Time-Series endpoint or historical data in the same way as the previous API.
    // We are disabling this feature for now to avoid showing broken data.
    throw const ServerException(
      'Historical data is unfortunately not supported by the current API provider.',
    );
  }
}
