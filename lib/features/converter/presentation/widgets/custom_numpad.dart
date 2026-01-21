import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/currencies_converter_bloc.dart';
import '../bloc/currencies_converter_event.dart';
import '../bloc/converter_state.dart';

class CustomNumpad extends StatelessWidget {
  const CustomNumpad({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrenciesConverterBloc, CurrenciesConverterState>(
      buildWhen: (previous, current) =>
          previous.editingRateValue != current.editingRateValue ||
          previous.calculatorOperator != current.calculatorOperator,
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Display
                _buildDisplay(context, state),
                // Numpad grid
                _buildNumpadGrid(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDisplay(BuildContext context, CurrenciesConverterState state) {
    final displayText = state.editingRateValue.isEmpty
        ? '0'
        : state.editingRateValue;
    final hasOperator = state.calculatorOperator != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (hasOperator && state.calculatorFirstOperand != null)
            Text(
              '${_formatNumber(state.calculatorFirstOperand!)} ${state.calculatorOperator}',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    if (value == value.truncate()) {
      return value.truncate().toString();
    }
    return value.toString();
  }

  Widget _buildNumpadGrid(
      BuildContext context, CurrenciesConverterState state) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Row 1: 7, 8, 9, ÷
          Row(
            children: [
              _buildDigitButton(context, '7'),
              _buildDigitButton(context, '8'),
              _buildDigitButton(context, '9'),
              _buildOperationButton(context, '÷'),
            ],
          ),
          // Row 2: 4, 5, 6, ×
          Row(
            children: [
              _buildDigitButton(context, '4'),
              _buildDigitButton(context, '5'),
              _buildDigitButton(context, '6'),
              _buildOperationButton(context, '×'),
            ],
          ),
          // Row 3: 1, 2, 3, -
          Row(
            children: [
              _buildDigitButton(context, '1'),
              _buildDigitButton(context, '2'),
              _buildDigitButton(context, '3'),
              _buildOperationButton(context, '-'),
            ],
          ),
          // Row 4: ., 0, ⌫, +
          Row(
            children: [
              _buildDigitButton(context, '.'),
              _buildDigitButton(context, '0'),
              _buildDeleteButton(context),
              _buildOperationButton(context, '+'),
            ],
          ),
          const SizedBox(height: 8),
          // Row 5: AC, Done
          Row(
            children: [
              _buildClearButton(context),
              const SizedBox(width: 8),
              _buildDoneButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDigitButton(BuildContext context, String digit) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              context
                  .read<CurrenciesConverterBloc>()
                  .add(NumpadDigitPressed(digit));
            },
            child: Container(
              height: 56,
              alignment: Alignment.center,
              child: Text(
                digit,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOperationButton(BuildContext context, String operation) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              context
                  .read<CurrenciesConverterBloc>()
                  .add(NumpadOperationPressed(operation));
            },
            child: Container(
              height: 56,
              alignment: Alignment.center,
              child: Text(
                operation,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              context.read<CurrenciesConverterBloc>().add(const NumpadDelete());
            },
            child: Container(
              height: 56,
              alignment: Alignment.center,
              child: Icon(
                Icons.backspace_outlined,
                size: 24,
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClearButton(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              context.read<CurrenciesConverterBloc>().add(const NumpadClear());
            },
            child: Container(
              height: 56,
              alignment: Alignment.center,
              child: Text(
                'AC',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              context
                  .read<CurrenciesConverterBloc>()
                  .add(const ApplyRateChange());
            },
            child: Container(
              height: 56,
              alignment: Alignment.center,
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
