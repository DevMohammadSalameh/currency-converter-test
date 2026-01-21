import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/currency.dart';
import '../repositories/currency_repository.dart';

class GetCurrencies implements UseCase<List<Currency>, NoParams> {
  final CurrencyRepository repository;

  GetCurrencies(this.repository);

  @override
  Future<Either<Failure, List<Currency>>> call(NoParams params) async {
    return await repository.getCurrencies();
  }
}
