import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/currency_model.dart';

abstract class CurrencyRemoteDataSource {
  Future<List<CurrencyModel>> getCurrencies();
}

class CurrencyRemoteDataSourceImpl implements CurrencyRemoteDataSource {
  final Dio dio;

  CurrencyRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CurrencyModel>> getCurrencies() async {
    try {
      // Fetch rates and names in parallel
      final results = await Future.wait([
        dio.get('${ApiConstants.baseUrl}${ApiConstants.latestEndpoint}'),
        dio.get(ApiConstants.flagCodesUrl),
      ]);

      final ratesResponse = results[0];
      final namesResponse = results[1];

      if (ratesResponse.statusCode == 200 && namesResponse.statusCode == 200) {
        final Map<String, dynamic> ratesData = ratesResponse.data;
        final Map<String, dynamic> rates = ratesData['conversion_rates'] ?? {};

        final Map<String, dynamic> namesData = namesResponse.data;

        // Use a set to track seen country codes for deduplication
        final Set<String> seenCountryCodes = {};
        final List<CurrencyModel> currencies = [];

        rates.forEach((code, rate) {
          if (code.length < 2) return;

          final String countryCode = code.substring(0, 2).toLowerCase();

          // Filter: Must exist in FlagCDN names and not be a duplicate country code
          if (namesData.containsKey(countryCode) &&
              !seenCountryCodes.contains(countryCode)) {
            seenCountryCodes.add(countryCode);

            final String name = namesData[countryCode];

            currencies.add(
              CurrencyModel(
                id: code,
                name: name,
                symbol: null, // Symbol not available in new API
                countryCode: countryCode,
              ),
            );
          }
        });

        currencies.sort((a, b) => a.name.compareTo(b.name));
        return currencies;
      } else {
        throw const ServerException('Failed to fetch currencies');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }
}
