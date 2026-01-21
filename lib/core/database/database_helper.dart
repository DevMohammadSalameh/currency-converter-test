import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/database_constants.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, DatabaseConstants.databaseName);

    return await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute(DatabaseConstants.createCurrenciesTable);
    await db.execute(DatabaseConstants.createExchangeRatesTable);
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle migrations here if needed
    if (oldVersion < newVersion) {
      // Drop and recreate tables for simplicity
      await db.execute('DROP TABLE IF EXISTS ${DatabaseConstants.currenciesTable}');
      await db.execute('DROP TABLE IF EXISTS ${DatabaseConstants.exchangeRatesTable}');
      await _onCreate(db, newVersion);
    }
  }

  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
