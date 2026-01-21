import 'package:currency_converter/features/currencies/data/models/currency_model.dart';
import 'package:currency_converter/features/currencies/domain/entities/currency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tCurrencyModel = CurrencyModel(
    id: 'USD',
    name: 'United States Dollar',
    symbol: '\$',
    countryCode: 'us',
  );

  test('should be a subclass of Currency entity', () {
    expect(tCurrencyModel, isA<Currency>());
  });

  group('fromJson', () {
    test('should return a valid model from JSON', () {
      // arrange
      final json = {
        'currencyName': 'United States Dollar',
        'currencySymbol': '\$',
        'id': 'USD',
      };

      // act
      final result = CurrencyModel.fromJson('USD', json);

      // assert
      expect(result.id, 'USD');
      expect(result.name, 'United States Dollar');
      expect(result.symbol, '\$');
    });

    test('should handle missing symbol', () {
      // arrange
      final json = {
        'currencyName': 'Bitcoin',
      };

      // act
      final result = CurrencyModel.fromJson('BTC', json);

      // assert
      expect(result.id, 'BTC');
      expect(result.name, 'Bitcoin');
      expect(result.symbol, null);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing proper data', () {
      // act
      final result = tCurrencyModel.toJson();

      // assert
      expect(result, {
        'id': 'USD',
        'currencyName': 'United States Dollar',
        'currencySymbol': '\$',
      });
    });
  });

  group('fromDatabase', () {
    test('should return a valid model from database map', () {
      // arrange
      final map = {
        'id': 'USD',
        'name': 'United States Dollar',
        'symbol': '\$',
        'country_code': 'us',
      };

      // act
      final result = CurrencyModel.fromDatabase(map);

      // assert
      expect(result, tCurrencyModel);
    });
  });

  group('toDatabase', () {
    test('should return a map for database storage', () {
      // act
      final result = tCurrencyModel.toDatabase();

      // assert
      expect(result, {
        'id': 'USD',
        'name': 'United States Dollar',
        'symbol': '\$',
        'country_code': 'us',
      });
    });
  });

  group('fromEntity', () {
    test('should create a model from entity', () {
      // arrange
      const entity = Currency(
        id: 'USD',
        name: 'United States Dollar',
        symbol: '\$',
        countryCode: 'us',
      );

      // act
      final result = CurrencyModel.fromEntity(entity);

      // assert
      expect(result, tCurrencyModel);
    });
  });
}
