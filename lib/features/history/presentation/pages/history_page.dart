import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../currencies/domain/entities/currency.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';
import '../widgets/date_range_selector.dart';
import '../widgets/rate_chart.dart';
import '../widgets/rate_statistics.dart';

class HistoryPage extends StatefulWidget {
  final Currency fromCurrency;
  final Currency toCurrency;

  const HistoryPage({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 7));

    context.read<HistoryBloc>().add(LoadHistoricalRates(
          fromCurrency: widget.fromCurrency.id,
          toCurrency: widget.toCurrency.id,
          startDate: startDate,
          endDate: endDate,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.fromCurrency.id} / ${widget.toCurrency.id}'),
        centerTitle: true,
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 16),
                DateRangeSelector(
                  selectedRange: state.selectedRange,
                  onRangeSelected: (range) {
                    context.read<HistoryBloc>().add(ChangeDateRange(range));
                  },
                ),
                const SizedBox(height: 24),
                _buildChartSection(state, theme),
                const SizedBox(height: 24),
                if (state.status == HistoryStatus.success)
                  RateStatistics(state: state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.fromCurrency.name,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'to ${widget.toCurrency.name}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection(HistoryState state, ThemeData theme) {
    if (state.status == HistoryStatus.loading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == HistoryStatus.failure) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'Failed to load data',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadInitialData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.rates.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.show_chart,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              const Text('No historical data available'),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: RateChart(
        rates: state.rates,
        fromCurrency: widget.fromCurrency.id,
        toCurrency: widget.toCurrency.id,
      ),
    );
  }
}
