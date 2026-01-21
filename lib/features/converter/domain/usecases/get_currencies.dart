import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/currency_result.dart';
import '../repositories/currency_repository.dart';

class GetCurrencies implements UseCase<CurrencyResult, GetCurrenciesParams> {
  final CurrencyRepository repository;

  GetCurrencies(this.repository);

  @override
  Future<Either<Failure, CurrencyResult>> call(GetCurrenciesParams params) async {
    return await repository.getCurrencies(forceRefresh: params.forceRefresh);
  }
}

class GetCurrenciesParams extends Equatable {
  final bool forceRefresh;

  const GetCurrenciesParams({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}
