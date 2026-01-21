import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversion_result.dart';
import '../repositories/converter_repository.dart';

class ConvertCurrency implements UseCase<ConversionResult, ConvertCurrencyParams> {
  final ConverterRepository repository;

  ConvertCurrency(this.repository);

  @override
  Future<Either<Failure, ConversionResult>> call(ConvertCurrencyParams params) async {
    return await repository.convertCurrency(
      fromCurrency: params.fromCurrency,
      toCurrency: params.toCurrency,
      amount: params.amount,
    );
  }
}

class ConvertCurrencyParams extends Equatable {
  final String fromCurrency;
  final String toCurrency;
  final double amount;

  const ConvertCurrencyParams({
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
  });

  @override
  List<Object?> get props => [fromCurrency, toCurrency, amount];
}
