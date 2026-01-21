import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/convert_currency.dart';
import 'converter_event.dart';
import 'converter_state.dart';

class ConverterBloc extends Bloc<ConverterEvent, ConverterState> {
  final ConvertCurrency convertCurrency;

  ConverterBloc({required this.convertCurrency}) : super(const ConverterState()) {
    on<SelectFromCurrency>(_onSelectFromCurrency);
    on<SelectToCurrency>(_onSelectToCurrency);
    on<UpdateAmount>(_onUpdateAmount);
    on<ConvertCurrencyEvent>(_onConvertCurrency);
    on<SwapCurrencies>(_onSwapCurrencies);
    on<ResetConverter>(_onResetConverter);
  }

  void _onSelectFromCurrency(
    SelectFromCurrency event,
    Emitter<ConverterState> emit,
  ) {
    emit(state.copyWith(
      fromCurrency: event.currency,
      clearResult: true,
    ));
  }

  void _onSelectToCurrency(
    SelectToCurrency event,
    Emitter<ConverterState> emit,
  ) {
    emit(state.copyWith(
      toCurrency: event.currency,
      clearResult: true,
    ));
  }

  void _onUpdateAmount(
    UpdateAmount event,
    Emitter<ConverterState> emit,
  ) {
    emit(state.copyWith(
      amount: event.amount,
      clearResult: true,
    ));
  }

  Future<void> _onConvertCurrency(
    ConvertCurrencyEvent event,
    Emitter<ConverterState> emit,
  ) async {
    if (!state.canConvert) return;

    emit(state.copyWith(
      status: ConverterStatus.loading,
      clearError: true,
    ));

    final result = await convertCurrency(ConvertCurrencyParams(
      fromCurrency: state.fromCurrency!.id,
      toCurrency: state.toCurrency!.id,
      amount: double.parse(state.amount),
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: ConverterStatus.failure,
        errorMessage: failure.message,
      )),
      (conversionResult) => emit(state.copyWith(
        status: ConverterStatus.success,
        result: conversionResult,
      )),
    );
  }

  void _onSwapCurrencies(
    SwapCurrencies event,
    Emitter<ConverterState> emit,
  ) {
    if (state.fromCurrency == null || state.toCurrency == null) return;

    emit(state.copyWith(
      fromCurrency: state.toCurrency,
      toCurrency: state.fromCurrency,
      clearResult: true,
    ));
  }

  void _onResetConverter(
    ResetConverter event,
    Emitter<ConverterState> emit,
  ) {
    emit(const ConverterState());
  }
}
