import 'package:bloc_test/bloc_test.dart';
import 'package:currency_converter/core/error/failures.dart';
import 'package:currency_converter/features/converter/data/models/currency.dart';
import 'package:currency_converter/features/converter/domain/entities/conversion_result.dart';
import 'package:currency_converter/features/converter/domain/usecases/convert_currency.dart';
import 'package:currency_converter/features/converter/domain/usecases/get_currencies.dart';
import 'package:currency_converter/features/converter/presentation/bloc/currencies_converter_bloc.dart';
import 'package:currency_converter/features/converter/presentation/bloc/currencies_converter_event.dart';
import 'package:currency_converter/features/converter/presentation/bloc/converter_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'converter_bloc_test.mocks.dart';

@GenerateMocks([ConvertCurrency, GetCurrencies])
void main() {
  late CurrenciesConverterBloc bloc;
  late MockConvertCurrency mockConvertCurrency;
  late MockGetCurrencies mockGetCurrencies;

  setUp(() {
    mockConvertCurrency = MockConvertCurrency();
    mockGetCurrencies = MockGetCurrencies();
    bloc = CurrenciesConverterBloc(
      convertCurrency: mockConvertCurrency,
      getCurrencies: mockGetCurrencies,
    );
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

  test('initial state should be CurrenciesConverterState with default values', () {
    expect(bloc.state, const CurrenciesConverterState());
  });

  group('SelectFromCurrency', () {
    blocTest<CurrenciesConverterBloc, CurrenciesConverterState>(
      'emits state with fromCurrency when SelectFromCurrency is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const SelectFromCurrency(tFromCurrency)),
      expect: () => [
        const CurrenciesConverterState(fromCurrency: tFromCurrency),
      ],
    );
  });

  group('SelectToCurrency', () {
    blocTest<CurrenciesConverterBloc, CurrenciesConverterState>(
      'emits state with toCurrency when SelectToCurrency is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const SelectToCurrency(tToCurrency)),
      expect: () => [const CurrenciesConverterState(toCurrency: tToCurrency)],
    );
  });

  group('UpdateAmount', () {
    blocTest<CurrenciesConverterBloc, CurrenciesConverterState>(
      'emits state with amount when UpdateAmount is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const UpdateAmount('100')),
      expect: () => [const CurrenciesConverterState(amount: '100')],
    );
  });

  group('SwapCurrencies', () {
    blocTest<CurrenciesConverterBloc, CurrenciesConverterState>(
      'swaps fromCurrency and toCurrency when SwapCurrencies is added',
      build: () => bloc,
      seed: () => const CurrenciesConverterState(
        fromCurrency: tFromCurrency,
        toCurrency: tToCurrency,
      ),
      act: (bloc) => bloc.add(const SwapCurrencies()),
      expect: () => [
        const CurrenciesConverterState(
          fromCurrency: tToCurrency,
          toCurrency: tFromCurrency,
        ),
      ],
    );
  });

  group('ConvertCurrencyEvent', () {
    blocTest<CurrenciesConverterBloc, CurrenciesConverterState>(
      'emits [loading, success] when conversion succeeds',
      build: () {
        when(
          mockConvertCurrency(any),
        ).thenAnswer((_) async => Right(tConversionResult));
        return bloc;
      },
      seed: () => const CurrenciesConverterState(
        fromCurrency: tFromCurrency,
        toCurrency: tToCurrency,
        amount: '100',
      ),
      act: (bloc) => bloc.add(const ConvertCurrencyEvent()),
      expect: () => [
        const CurrenciesConverterState(
          status: ConverterStatus.loading,
          fromCurrency: tFromCurrency,
          toCurrency: tToCurrency,
          amount: '100',
        ),
        CurrenciesConverterState(
          status: ConverterStatus.success,
          fromCurrency: tFromCurrency,
          toCurrency: tToCurrency,
          amount: '100',
          result: tConversionResult,
        ),
      ],
    );

    blocTest<CurrenciesConverterBloc, CurrenciesConverterState>(
      'emits [loading, failure] when conversion fails',
      build: () {
        when(mockConvertCurrency(any)).thenAnswer(
          (_) async => const Left(ConversionFailure('Conversion failed')),
        );
        return bloc;
      },
      seed: () => const CurrenciesConverterState(
        fromCurrency: tFromCurrency,
        toCurrency: tToCurrency,
        amount: '100',
      ),
      act: (bloc) => bloc.add(const ConvertCurrencyEvent()),
      expect: () => [
        const CurrenciesConverterState(
          status: ConverterStatus.loading,
          fromCurrency: tFromCurrency,
          toCurrency: tToCurrency,
          amount: '100',
        ),
        const CurrenciesConverterState(
          status: ConverterStatus.failure,
          fromCurrency: tFromCurrency,
          toCurrency: tToCurrency,
          amount: '100',
          errorMessage: 'Conversion failed',
        ),
      ],
    );

    blocTest<CurrenciesConverterBloc, CurrenciesConverterState>(
      'does nothing when canConvert is false',
      build: () => bloc,
      seed: () => const CurrenciesConverterState(
        fromCurrency: tFromCurrency,
        // toCurrency is null
        amount: '100',
      ),
      act: (bloc) => bloc.add(const ConvertCurrencyEvent()),
      expect: () => [],
    );
  });
}
