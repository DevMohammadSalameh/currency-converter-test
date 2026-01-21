import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/currency.dart';
import '../../domain/usecases/get_currencies.dart';
import 'currencies_event.dart';
import 'currencies_state.dart';

class CurrenciesBloc extends Bloc<CurrenciesEvent, CurrenciesState> {
  final GetCurrencies getCurrencies;

  CurrenciesBloc({required this.getCurrencies}) : super(const CurrenciesInitial()) {
    on<LoadCurrencies>(_onLoadCurrencies);
    on<RefreshCurrencies>(_onRefreshCurrencies);
    on<SearchCurrencies>(_onSearchCurrencies);
  }

  Future<void> _onLoadCurrencies(
    LoadCurrencies event,
    Emitter<CurrenciesState> emit,
  ) async {
    emit(const CurrenciesLoading());

    final result = await getCurrencies(NoParams());

    result.fold(
      (failure) => emit(CurrenciesError(failure.message)),
      (currencies) => emit(CurrenciesLoaded(
        currencies: currencies,
        filteredCurrencies: currencies,
      )),
    );
  }

  Future<void> _onRefreshCurrencies(
    RefreshCurrencies event,
    Emitter<CurrenciesState> emit,
  ) async {
    final currentState = state;

    final result = await getCurrencies(NoParams());

    result.fold(
      (failure) {
        if (currentState is CurrenciesLoaded) {
          // Keep existing data on refresh failure
          emit(currentState);
        } else {
          emit(CurrenciesError(failure.message));
        }
      },
      (currencies) {
        final searchQuery = currentState is CurrenciesLoaded
            ? currentState.searchQuery
            : '';
        final filtered = _filterCurrencies(currencies, searchQuery);
        emit(CurrenciesLoaded(
          currencies: currencies,
          filteredCurrencies: filtered,
          searchQuery: searchQuery,
        ));
      },
    );
  }

  void _onSearchCurrencies(
    SearchCurrencies event,
    Emitter<CurrenciesState> emit,
  ) {
    final currentState = state;
    if (currentState is CurrenciesLoaded) {
      final filtered = _filterCurrencies(currentState.currencies, event.query);
      emit(currentState.copyWith(
        filteredCurrencies: filtered,
        searchQuery: event.query,
      ));
    }
  }

  List<Currency> _filterCurrencies(List<Currency> currencies, String query) {
    if (query.isEmpty) return currencies;

    final lowerQuery = query.toLowerCase();
    return currencies.where((currency) {
      return currency.name.toLowerCase().contains(lowerQuery) ||
          currency.id.toLowerCase().contains(lowerQuery) ||
          (currency.symbol?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}
