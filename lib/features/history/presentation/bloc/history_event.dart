import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadHistoricalRates extends HistoryEvent {
  final String fromCurrency;
  final String toCurrency;
  final DateTime startDate;
  final DateTime endDate;

  const LoadHistoricalRates({
    required this.fromCurrency,
    required this.toCurrency,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [fromCurrency, toCurrency, startDate, endDate];
}

class ChangeDateRange extends HistoryEvent {
  final HistoryDateRange range;

  const ChangeDateRange(this.range);

  @override
  List<Object?> get props => [range];
}

enum HistoryDateRange {
  week,
  month,
  threeMonths,
  sixMonths,
  year,
}

extension HistoryDateRangeExtension on HistoryDateRange {
  String get label {
    switch (this) {
      case HistoryDateRange.week:
        return '1W';
      case HistoryDateRange.month:
        return '1M';
      case HistoryDateRange.threeMonths:
        return '3M';
      case HistoryDateRange.sixMonths:
        return '6M';
      case HistoryDateRange.year:
        return '1Y';
    }
  }

  int get days {
    switch (this) {
      case HistoryDateRange.week:
        return 7;
      case HistoryDateRange.month:
        return 30;
      case HistoryDateRange.threeMonths:
        return 90;
      case HistoryDateRange.sixMonths:
        return 180;
      case HistoryDateRange.year:
        return 365;
    }
  }
}
