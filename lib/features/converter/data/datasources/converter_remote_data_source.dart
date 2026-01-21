import 'package:dio/dio.dart';

import '../../../../core/network/endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/conversion_result_model.dart';

abstract class ConverterRemoteDataSource {
  Future<ConversionResultModel> convertCurrency({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  });

  Future<double> getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  });
}

class ConverterRemoteDataSourceImpl implements ConverterRemoteDataSource {
  final Dio dio;

  ConverterRemoteDataSourceImpl({required this.dio});

  @override
  Future<ConversionResultModel> convertCurrency({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    try {
      final rate = await getExchangeRate(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );

      return ConversionResultModel.fromRate(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        amount: amount,
        rate: rate,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Conversion failed: $e');
    }
  }

  @override
  Future<double> getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      //TODO this will be calculated not fetched from API
      final response = await dio.get(
        Endpoints.currencies(currency: fromCurrency),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final Map<String, dynamic> rates = data['conversion_rates'];

        final fromRate = (rates[fromCurrency] as num?)?.toDouble();
        final toRate = (rates[toCurrency] as num?)?.toDouble();

        if (fromRate == null || toRate == null) {
          throw const ServerException(
            'Exchange rate not found for specified currencies',
          );
        }

        // Calculate cross rate
        // Base is USD.
        // fromRate = USD -> FROM
        // toRate = USD -> TO
        // FROM -> TO = (1/fromRate) * toRate = toRate / fromRate
        return toRate / fromRate;
      } else {
        throw const ServerException('Failed to fetch exchange rate');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }
}
