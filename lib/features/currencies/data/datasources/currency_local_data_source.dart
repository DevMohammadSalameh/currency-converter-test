import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/database_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/currency_model.dart';

abstract class CurrencyLocalDataSource {
  Future<List<CurrencyModel>> getCachedCurrencies();
  Future<void> cacheCurrencies(List<CurrencyModel> currencies);
  Future<bool> hasCachedCurrencies();
}

class CurrencyLocalDataSourceImpl implements CurrencyLocalDataSource {
  final Database database;

  CurrencyLocalDataSourceImpl({required this.database});

  @override
  Future<List<CurrencyModel>> getCachedCurrencies() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        DatabaseConstants.currenciesTable,
        orderBy: '${DatabaseConstants.columnName} ASC',
      );

      if (maps.isEmpty) {
        throw const CacheException('No cached currencies found');
      }

      return maps.map((map) => CurrencyModel.fromDatabase(map)).toList();
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to fetch cached currencies: $e');
    }
  }

  @override
  Future<void> cacheCurrencies(List<CurrencyModel> currencies) async {
    try {
      final batch = database.batch();

      // Clear existing currencies
      batch.delete(DatabaseConstants.currenciesTable);

      // Insert new currencies
      for (final currency in currencies) {
        batch.insert(
          DatabaseConstants.currenciesTable,
          currency.toDatabase(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw CacheException('Failed to cache currencies: $e');
    }
  }

  @override
  Future<bool> hasCachedCurrencies() async {
    try {
      final result = await database.query(
        DatabaseConstants.currenciesTable,
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
