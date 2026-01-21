import 'package:bloc_test/bloc_test.dart';
import 'package:currency_converter/core/error/failures.dart';
import 'package:currency_converter/core/usecases/usecase.dart';
import 'package:currency_converter/features/currencies/domain/entities/currency.dart';
import 'package:currency_converter/features/currencies/domain/usecases/get_currencies.dart';
import 'package:currency_converter/features/currencies/presentation/bloc/currencies_bloc.dart';
import 'package:currency_converter/features/currencies/presentation/bloc/currencies_event.dart';
import 'package:currency_converter/features/currencies/presentation/bloc/currencies_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'currencies_bloc_test.mocks.dart';

@GenerateMocks([GetCurrencies])
void main() {
  late CurrenciesBloc bloc;
  late MockGetCurrencies mockGetCurrencies;

  setUp(() {
    mockGetCurrencies = MockGetCurrencies();
    bloc = CurrenciesBloc(getCurrencies: mockGetCurrencies);
  });

  tearDown(() {
    bloc.close();
  });

  const tCurrencies = [
    Currency(id: 'USD', name: 'United States Dollar', symbol: '\$', countryCode: 'us'),
    Currency(id: 'EUR', name: 'Euro', symbol: '€', countryCode: 'eu'),
  ];

  test('initial state should be CurrenciesInitial', () {
    expect(bloc.state, const CurrenciesInitial());
  });

  group('LoadCurrencies', () {
    blocTest<CurrenciesBloc, CurrenciesState>(
      'emits [CurrenciesLoading, CurrenciesLoaded] when getCurrencies succeeds',
      build: () {
        when(mockGetCurrencies(any))
            .thenAnswer((_) async => const Right(tCurrencies));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadCurrencies()),
      expect: () => [
        const CurrenciesLoading(),
        const CurrenciesLoaded(
          currencies: tCurrencies,
          filteredCurrencies: tCurrencies,
        ),
      ],
      verify: (_) {
        verify(mockGetCurrencies(NoParams()));
      },
    );

    blocTest<CurrenciesBloc, CurrenciesState>(
      'emits [CurrenciesLoading, CurrenciesError] when getCurrencies fails',
      build: () {
        when(mockGetCurrencies(any))
            .thenAnswer((_) async => const Left(ServerFailure('Server error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadCurrencies()),
      expect: () => [
        const CurrenciesLoading(),
        const CurrenciesError('Server error'),
      ],
    );
  });

  group('SearchCurrencies', () {
    blocTest<CurrenciesBloc, CurrenciesState>(
      'filters currencies based on search query',
      build: () {
        when(mockGetCurrencies(any))
            .thenAnswer((_) async => const Right(tCurrencies));
        return bloc;
      },
      seed: () => const CurrenciesLoaded(
        currencies: tCurrencies,
        filteredCurrencies: tCurrencies,
      ),
      act: (bloc) => bloc.add(const SearchCurrencies('USD')),
      expect: () => [
        const CurrenciesLoaded(
          currencies: tCurrencies,
          filteredCurrencies: [
            Currency(id: 'USD', name: 'United States Dollar', symbol: '\$', countryCode: 'us'),
          ],
          searchQuery: 'USD',
        ),
      ],
    );

    blocTest<CurrenciesBloc, CurrenciesState>(
      'returns all currencies when search query is empty',
      build: () => bloc,
      seed: () => const CurrenciesLoaded(
        currencies: tCurrencies,
        filteredCurrencies: [
          Currency(id: 'USD', name: 'United States Dollar', symbol: '\$', countryCode: 'us'),
        ],
        searchQuery: 'USD',
      ),
      act: (bloc) => bloc.add(const SearchCurrencies('')),
      expect: () => [
        const CurrenciesLoaded(
          currencies: tCurrencies,
          filteredCurrencies: tCurrencies,
          searchQuery: '',
        ),
      ],
    );
  });
}
