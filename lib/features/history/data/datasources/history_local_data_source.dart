import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/database_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/historical_rate_model.dart';

abstract class HistoryLocalDataSource {
  Future<List<HistoricalRateModel>> getCachedHistoricalRates({
    required String fromCurrency,
    required String toCurrency,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<void> cacheHistoricalRates(List<HistoricalRateModel> rates);
}

class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  final Database database;

  HistoryLocalDataSourceImpl({required this.database});

  @override
  Future<List<HistoricalRateModel>> getCachedHistoricalRates({
    required String fromCurrency,
    required String toCurrency,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startDateStr = _formatDate(startDate);
      final endDateStr = _formatDate(endDate);

      final result = await database.query(
        DatabaseConstants.exchangeRatesTable,
        where:
            '${DatabaseConstants.columnFromCurrency} = ? AND ${DatabaseConstants.columnToCurrency} = ? AND ${DatabaseConstants.columnDate} >= ? AND ${DatabaseConstants.columnDate} <= ?',
        whereArgs: [fromCurrency, toCurrency, startDateStr, endDateStr],
        orderBy: '${DatabaseConstants.columnDate} ASC',
      );

      if (result.isEmpty) {
        throw const CacheException('No cached historical rates found');
      }

      return result.map((map) => HistoricalRateModel.fromDatabase(map)).toList();
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to fetch cached historical rates: $e');
    }
  }

  @override
  Future<void> cacheHistoricalRates(List<HistoricalRateModel> rates) async {
    try {
      final batch = database.batch();

      for (final rate in rates) {
        batch.insert(
          DatabaseConstants.exchangeRatesTable,
          rate.toDatabase(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw CacheException('Failed to cache historical rates: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
