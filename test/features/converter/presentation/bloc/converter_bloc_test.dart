import 'package:bloc_test/bloc_test.dart';
import 'package:currency_converter/core/error/failures.dart';
import 'package:currency_converter/features/currencies/domain/entities/currency.dart';
import 'package:currency_converter/features/converter/domain/entities/conversion_result.dart';
import 'package:currency_converter/features/converter/domain/usecases/convert_currency.dart';
import 'package:currency_converter/features/converter/presentation/bloc/converter_bloc.dart';
import 'package:currency_converter/features/converter/presentation/bloc/converter_event.dart';
import 'package:currency_converter/features/converter/presentation/bloc/converter_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'converter_bloc_test.mocks.dart';

@GenerateMocks([ConvertCurrency])
void main() {
  late ConverterBloc bloc;
  late MockConvertCurrency mockConvertCurrency;

  setUp(() {
    mockConvertCurrency = MockConvertCurrency();
    bloc = ConverterBloc(convertCurrency: mockConvertCurrency);
  });

  tearDown(() {
    bloc.close();
  });

  const tFromCurrency = Currency(
    id: 'USD',
    name: 'United States Dollar',
    symbol: '\$',
    countryCode: 'us',
  );

  const tToCurrency = Currency(
    id: 'EUR',
    name: 'Euro',
    symbol: '€',
    countryCode: 'eu',
  );

  final tConversionResult = ConversionResult(
    fromCurrency: 'USD',
    toCurrency: 'EUR',
    amount: 100,
    rate: 0.85,
    convertedAmount: 85,
    timestamp: DateTime(2024, 1, 15),
  );

  test('initial state should be ConverterState with default values', () {
    expect(bloc.state, const ConverterState());
  });

  group('SelectFromCurrency', () {
    blocTest<ConverterBloc, ConverterState>(
      'emits state with fromCurrency when SelectFromCurrency is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const SelectFromCurrency(tFromCurrency)),
      expect: () => [
        const ConverterState(fromCurrency: tFromCurrency),
      ],
    );
  });

  group('SelectToCurrency', () {
    blocTest<ConverterBloc, ConverterState>(
      'emits state with toCurrency when SelectToCurrency is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const SelectToCurrency(tToCurrency)),
      expect: () => [
        const ConverterState(toCurrency: tToCurrency),
      ],
    );
  });

  group('UpdateAmount', () {
    blocTest<ConverterBloc, ConverterState>(
      'emits state with amount when UpdateAmount is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const UpdateAmount('100')),
      expect: () => [
        const ConverterState(amount: '100'),
      ],
    );
  });

  group('SwapCurrencies', () {
    blocTest<ConverterBloc, ConverterState>(
      'swaps fromCurrency and toCurrency when SwapCurrencies is added',
      build: () => bloc,
      seed: () => const ConverterState(
        fromCurrency: tFromCurrency,
        toCurrency: tToCurrency,
      ),
      act: (bloc) => bloc.add(const SwapCurrencies()),
      expect: () => [
        const ConverterState(
          fromCurrency: tToCurrency,
          toCurrency: tFromCurrency,
        ),
      ],
    );
  });

  group('ConvertCurrencyEvent', () {
    blocTest<ConverterBloc, ConverterState>(
      'emits [loading, success] when conversion succeeds',
      build: () {
        when(mockConvertCurrency(any))
            .thenAnswer((_) async => Right(tConversionResult));
        return bloc;
      },
      seed: () => const ConverterState(
        fromCurrency: tFromCurrency,
        toCurrency: tToCurrency,
        amount: '100',
      ),
      act: (bloc) => bloc.add(const ConvertCurrencyEvent()),
      expect: () => [
        const ConverterState(
          status: ConverterStatus.loading,
          fromCurrency: tFromCurrency,
          toCurrency: tToCurrency,
          amount: '100',
        ),
        ConverterState(
          status: ConverterStatus.success,
          fromCurrency: tFromCurrency,
          toCurrency: tToCurrency,
          amount: '100',
          result: tConversionResult,
        ),
      ],
    );

    blocTest<ConverterBloc, ConverterState>(
      'emits [loading, failure] when conversion fails',
      build: () {
        when(mockConvertCurrency(any))
            .thenAnswer((_) async => const Left(ConversionFailure('Conversion failed')));
        return bloc;
      },
      seed: () => const ConverterState(
        fromCurrency: tFromCurrency,
        toCurrency: tToCurrency,
        amount: '100',
      ),
      act: (bloc) => bloc.add(const ConvertCurrencyEvent()),
      expect: () => [
        const ConverterState(
          status: ConverterStatus.loading,
          fromCurrency: tFromCurrency,
          toCurrency: tToCurrency,
          amount: '100',
        ),
        const ConverterState(
          status: ConverterStatus.failure,
          fromCurrency: tFromCurrency,
          toCurrency: tToCurrency,
          amount: '100',
          errorMessage: 'Conversion failed',
        ),
      ],
    );

    blocTest<ConverterBloc, ConverterState>(
      'does nothing when canConvert is false',
      build: () => bloc,
      seed: () => const ConverterState(
        fromCurrency: tFromCurrency,
        // toCurrency is null
        amount: '100',
      ),
      act: (bloc) => bloc.add(const ConvertCurrencyEvent()),
      expect: () => [],
    );
  });
}
