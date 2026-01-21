import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_historical_rates.dart';
import 'history_event.dart';
import 'history_state.dart';

@injectable
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistoricalRates getHistoricalRates;

  HistoryBloc({required this.getHistoricalRates}) : super(const HistoryState()) {
    on<LoadHistoricalRates>(_onLoadHistoricalRates);
    on<ChangeDateRange>(_onChangeDateRange);
  }

  Future<void> _onLoadHistoricalRates(
    LoadHistoricalRates event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(
      status: HistoryStatus.loading,
      fromCurrency: event.fromCurrency,
      toCurrency: event.toCurrency,
      clearError: true,
    ));

    final result = await getHistoricalRates(GetHistoricalRatesParams(
      fromCurrency: event.fromCurrency,
      toCurrency: event.toCurrency,
      startDate: event.startDate,
      endDate: event.endDate,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: HistoryStatus.failure,
        errorMessage: failure.message,
      )),
      (rates) => emit(state.copyWith(
        status: HistoryStatus.success,
        rates: rates,
      )),
    );
  }

  void _onChangeDateRange(
    ChangeDateRange event,
    Emitter<HistoryState> emit,
  ) {
    if (state.fromCurrency == null || state.toCurrency == null) return;

    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: event.range.days));

    emit(state.copyWith(selectedRange: event.range));

    add(LoadHistoricalRates(
      fromCurrency: state.fromCurrency!,
      toCurrency: state.toCurrency!,
      startDate: startDate,
      endDate: endDate,
    ));
  }
}
