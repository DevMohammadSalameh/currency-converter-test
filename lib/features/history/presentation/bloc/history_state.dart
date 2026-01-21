import 'package:equatable/equatable.dart';

import '../../domain/entities/historical_rate.dart';
import 'history_event.dart';

enum HistoryStatus {
  initial,
  loading,
  success,
  failure,
}

class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<HistoricalRate> rates;
  final String? fromCurrency;
  final String? toCurrency;
  final HistoryDateRange selectedRange;
  final String? errorMessage;

  const HistoryState({
    this.status = HistoryStatus.initial,
    this.rates = const [],
    this.fromCurrency,
    this.toCurrency,
    this.selectedRange = HistoryDateRange.week,
    this.errorMessage,
  });

  double? get minRate =>
      rates.isNotEmpty ? rates.map((r) => r.rate).reduce((a, b) => a < b ? a : b) : null;

  double? get maxRate =>
      rates.isNotEmpty ? rates.map((r) => r.rate).reduce((a, b) => a > b ? a : b) : null;

  double? get averageRate =>
      rates.isNotEmpty ? rates.map((r) => r.rate).reduce((a, b) => a + b) / rates.length : null;

  double? get latestRate => rates.isNotEmpty ? rates.last.rate : null;

  double? get percentageChange {
    if (rates.length < 2) return null;
    final first = rates.first.rate;
    final last = rates.last.rate;
    return ((last - first) / first) * 100;
  }

  HistoryState copyWith({
    HistoryStatus? status,
    List<HistoricalRate>? rates,
    String? fromCurrency,
    String? toCurrency,
    HistoryDateRange? selectedRange,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HistoryState(
      status: status ?? this.status,
      rates: rates ?? this.rates,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      selectedRange: selectedRange ?? this.selectedRange,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        rates,
        fromCurrency,
        toCurrency,
        selectedRange,
        errorMessage,
      ];
}
