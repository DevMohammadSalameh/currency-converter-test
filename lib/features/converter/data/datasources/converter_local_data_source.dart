import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/database_constants.dart';
import '../../../../core/error/exceptions.dart';

abstract class ConverterLocalDataSource {
  Future<double?> getCachedRate({
    required String fromCurrency,
    required String toCurrency,
  });

  Future<void> cacheRate({
    required String fromCurrency,
    required String toCurrency,
    required double rate,
  });
}

class ConverterLocalDataSourceImpl implements ConverterLocalDataSource {
  final Database database;

  ConverterLocalDataSourceImpl({required this.database});

  @override
  Future<double?> getCachedRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      // Get most recent cached rate regardless of date
      final result = await database.query(
        DatabaseConstants.exchangeRatesTable,
        where:
            '${DatabaseConstants.columnFromCurrency} = ? AND ${DatabaseConstants.columnToCurrency} = ?',
        whereArgs: [fromCurrency, toCurrency],
        orderBy: '${DatabaseConstants.columnDate} DESC',
        limit: 1,
      );

      if (result.isEmpty) return null;

      return result.first[DatabaseConstants.columnRate] as double?;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheRate({
    required String fromCurrency,
    required String toCurrency,
    required double rate,
  }) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      await database.insert(
        DatabaseConstants.exchangeRatesTable,
        {
          DatabaseConstants.columnFromCurrency: fromCurrency,
          DatabaseConstants.columnToCurrency: toCurrency,
          DatabaseConstants.columnRate: rate,
          DatabaseConstants.columnDate: today,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException('Failed to cache rate: $e');
    }
  }
}
