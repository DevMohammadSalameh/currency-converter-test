import 'package:currency_converter/features/converter/data/models/currency.dart';
import 'package:currency_converter/features/converter/presentation/bloc/currencies_converter_bloc.dart';
import 'package:currency_converter/features/converter/presentation/bloc/currencies_converter_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrencyListItem extends StatelessWidget {
  const CurrencyListItem({
    super.key,
    required this.currency,
    required this.isSelected,
  });

  final Currency currency;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<CurrenciesConverterBloc>().add(SelectCurrency(currency));
      },
      child: Container(
        padding: const EdgeInsets.only(left: 16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 64,
        decoration: BoxDecoration(
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Image.network(currency.flagUrl, height: 30, width: 30),
            const SizedBox(width: 8),
            Text(
              currency.id,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Text(
              currency.rate.toString(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            //Vertical Divider
            Container(
              width: 2,
              height: 64,
              margin: const EdgeInsets.only(left: 8),
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.4),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 2.0),
              child: Icon(
                Icons.more_vert,
                size: 24,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
