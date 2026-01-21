class DatabaseConstants {
  static const String databaseName = 'currency_converter.db';
  static const int databaseVersion = 1;

  // Table names
  static const String currenciesTable = 'currencies';
  static const String exchangeRatesTable = 'exchange_rates';

  // Currencies table columns
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnSymbol = 'symbol';
  static const String columnCountryCode = 'country_code';

  // Exchange rates table columns
  static const String columnFromCurrency = 'from_currency';
  static const String columnToCurrency = 'to_currency';
  static const String columnRate = 'rate';
  static const String columnDate = 'date';

  // SQL statements
  static const String createCurrenciesTable = '''
    CREATE TABLE $currenciesTable (
      $columnId TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL,
      $columnSymbol TEXT,
      $columnCountryCode TEXT
    )
  ''';

  static const String createExchangeRatesTable = '''
    CREATE TABLE $exchangeRatesTable (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnFromCurrency TEXT NOT NULL,
      $columnToCurrency TEXT NOT NULL,
      $columnRate REAL NOT NULL,
      $columnDate TEXT NOT NULL,
      UNIQUE($columnFromCurrency, $columnToCurrency, $columnDate)
    )
  ''';
}
