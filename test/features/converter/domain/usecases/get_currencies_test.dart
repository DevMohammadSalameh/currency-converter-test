import 'package:currency_converter/core/enums/data_source.dart';
import 'package:currency_converter/core/error/failures.dart';
import 'package:currency_converter/features/converter/data/models/currency.dart';
import 'package:currency_converter/features/converter/domain/entities/currency_result.dart';
import 'package:currency_converter/features/converter/domain/repositories/currency_repository.dart';
import 'package:currency_converter/features/converter/domain/usecases/get_currencies.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_currencies_test.mocks.dart';

@GenerateMocks([CurrencyRepository])
void main() {
  late GetCurrencies usecase;
  late MockCurrencyRepository mockRepository;

  setUp(() {
    mockRepository = MockCurrencyRepository();
    usecase = GetCurrencies(mockRepository);
  });

  const tCurrencies = [
    Currency(
      id: 'USD',
      name: 'United States Dollar',
      symbol: '\$',
      countryCode: 'us',
      rate: 1,
    ),
    Currency(id: 'EUR', name: 'Euro', symbol: '€', countryCode: 'eu', rate: 1),
    Currency(
      id: 'GBP',
      name: 'British Pound',
      symbol: '£',
      countryCode: 'gb',
      rate: 1,
    ),
  ];

  const tCurrencyResult = CurrencyResult(
    currencies: tCurrencies,
    source: DataSource.api,
  );

  test('should get currencies from the repository', () async {
    // arrange
    when(
      mockRepository.getCurrencies(forceRefresh: false),
    ).thenAnswer((_) async => const Right(tCurrencyResult));

    // act
    final result = await usecase(const GetCurrenciesParams());

    // assert
    expect(result, const Right(tCurrencyResult));
    verify(mockRepository.getCurrencies(forceRefresh: false));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // arrange
    when(
      mockRepository.getCurrencies(forceRefresh: false),
    ).thenAnswer((_) async => const Left(ServerFailure('Server error')));

    // act
    final result = await usecase(const GetCurrenciesParams());

    // assert
    expect(result, const Left(ServerFailure('Server error')));
    verify(mockRepository.getCurrencies(forceRefresh: false));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should pass forceRefresh to repository', () async {
    // arrange
    when(
      mockRepository.getCurrencies(forceRefresh: true),
    ).thenAnswer((_) async => const Right(tCurrencyResult));

    // act
    final result = await usecase(const GetCurrenciesParams(forceRefresh: true));

    // assert
    expect(result, const Right(tCurrencyResult));
    verify(mockRepository.getCurrencies(forceRefresh: true));
    verifyNoMoreInteractions(mockRepository);
  });
}
