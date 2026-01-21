import 'package:currency_converter/core/error/failures.dart';
import 'package:currency_converter/core/usecases/usecase.dart';
import 'package:currency_converter/features/converter/data/models/currency.dart';
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
    ),
    Currency(id: 'EUR', name: 'Euro', symbol: '€', countryCode: 'eu'),
    Currency(id: 'GBP', name: 'British Pound', symbol: '£', countryCode: 'gb'),
  ];

  test('should get currencies from the repository', () async {
    // arrange
    when(
      mockRepository.getCurrencies(),
    ).thenAnswer((_) async => const Right(tCurrencies));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, const Right(tCurrencies));
    verify(mockRepository.getCurrencies());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // arrange
    when(
      mockRepository.getCurrencies(),
    ).thenAnswer((_) async => const Left(ServerFailure('Server error')));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, const Left(ServerFailure('Server error')));
    verify(mockRepository.getCurrencies());
    verifyNoMoreInteractions(mockRepository);
  });
}
