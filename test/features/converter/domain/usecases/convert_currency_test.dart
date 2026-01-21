import 'package:currency_converter/core/error/failures.dart';
import 'package:currency_converter/features/converter/domain/entities/conversion_result.dart';
import 'package:currency_converter/features/converter/domain/repositories/converter_repository.dart';
import 'package:currency_converter/features/converter/domain/usecases/convert_currency.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'convert_currency_test.mocks.dart';

@GenerateMocks([ConverterRepository])
void main() {
  late ConvertCurrency usecase;
  late MockConverterRepository mockRepository;

  setUp(() {
    mockRepository = MockConverterRepository();
    usecase = ConvertCurrency(mockRepository);
  });

  final tConversionResult = ConversionResult(
    fromCurrency: 'USD',
    toCurrency: 'EUR',
    amount: 100,
    rate: 0.85,
    convertedAmount: 85,
    timestamp: DateTime(2024, 1, 15),
  );

  const tParams = ConvertCurrencyParams(
    fromCurrency: 'USD',
    toCurrency: 'EUR',
    amount: 100,
  );

  test('should convert currency using the repository', () async {
    // arrange
    when(mockRepository.convertCurrency(
      fromCurrency: anyNamed('fromCurrency'),
      toCurrency: anyNamed('toCurrency'),
      amount: anyNamed('amount'),
    )).thenAnswer((_) async => Right(tConversionResult));

    // act
    final result = await usecase(tParams);

    // assert
    expect(result, Right(tConversionResult));
    verify(mockRepository.convertCurrency(
      fromCurrency: 'USD',
      toCurrency: 'EUR',
      amount: 100,
    ));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when conversion fails', () async {
    // arrange
    when(mockRepository.convertCurrency(
      fromCurrency: anyNamed('fromCurrency'),
      toCurrency: anyNamed('toCurrency'),
      amount: anyNamed('amount'),
    )).thenAnswer((_) async => const Left(ConversionFailure('Conversion failed')));

    // act
    final result = await usecase(tParams);

    // assert
    expect(result, const Left(ConversionFailure('Conversion failed')));
    verify(mockRepository.convertCurrency(
      fromCurrency: 'USD',
      toCurrency: 'EUR',
      amount: 100,
    ));
    verifyNoMoreInteractions(mockRepository);
  });
}
