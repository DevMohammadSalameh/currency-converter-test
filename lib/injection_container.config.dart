// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:currency_converter/core/di/register_module.dart' as _i729;
import 'package:currency_converter/core/network/network_info.dart' as _i417;
import 'package:currency_converter/core/storage/app_preferences.dart' as _i965;
import 'package:currency_converter/features/converter/data/datasources/converter_local_data_source.dart'
    as _i791;
import 'package:currency_converter/features/converter/data/datasources/converter_remote_data_source.dart'
    as _i934;
import 'package:currency_converter/features/converter/data/datasources/currency_local_data_source.dart'
    as _i241;
import 'package:currency_converter/features/converter/data/datasources/currency_remote_data_source.dart'
    as _i940;
import 'package:currency_converter/features/converter/data/repositories/converter_repository_impl.dart'
    as _i7;
import 'package:currency_converter/features/converter/data/repositories/currency_repository_impl.dart'
    as _i495;
import 'package:currency_converter/features/converter/domain/repositories/converter_repository.dart'
    as _i153;
import 'package:currency_converter/features/converter/domain/repositories/currency_repository.dart'
    as _i29;
import 'package:currency_converter/features/converter/domain/usecases/convert_currency.dart'
    as _i416;
import 'package:currency_converter/features/converter/domain/usecases/get_currencies.dart'
    as _i965;
import 'package:currency_converter/features/converter/presentation/bloc/currencies_converter_bloc.dart'
    as _i115;
import 'package:currency_converter/features/history/data/datasources/history_local_data_source.dart'
    as _i961;
import 'package:currency_converter/features/history/data/datasources/history_remote_data_source.dart'
    as _i1047;
import 'package:currency_converter/features/history/data/repositories/history_repository_impl.dart'
    as _i609;
import 'package:currency_converter/features/history/domain/repositories/history_repository.dart'
    as _i292;
import 'package:currency_converter/features/history/domain/usecases/get_historical_rates.dart'
    as _i351;
import 'package:currency_converter/features/history/presentation/bloc/history_bloc.dart'
    as _i846;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i973;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:sqflite/sqflite.dart' as _i779;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    await gh.lazySingletonAsync<_i779.Database>(
      () => registerModule.database,
      preResolve: true,
    );
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i973.InternetConnectionChecker>(
      () => registerModule.connectionChecker,
    );
    gh.lazySingleton<_i965.AppPreferences>(
      () => _i965.AppPreferences(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i791.ConverterLocalDataSource>(
      () => _i791.ConverterLocalDataSourceImpl(database: gh<_i779.Database>()),
    );
    gh.lazySingleton<_i934.ConverterRemoteDataSource>(
      () => _i934.ConverterRemoteDataSourceImpl(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i1047.HistoryRemoteDataSource>(
      () => _i1047.HistoryRemoteDataSourceImpl(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i961.HistoryLocalDataSource>(
      () => _i961.HistoryLocalDataSourceImpl(database: gh<_i779.Database>()),
    );
    gh.lazySingleton<_i241.CurrencyLocalDataSource>(
      () => _i241.CurrencyLocalDataSourceImpl(database: gh<_i779.Database>()),
    );
    gh.lazySingleton<_i417.NetworkInfo>(
      () => _i417.NetworkInfoImpl(gh<_i973.InternetConnectionChecker>()),
    );
    gh.lazySingleton<_i940.CurrencyRemoteDataSource>(
      () => _i940.CurrencyRemoteDataSourceImpl(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i292.HistoryRepository>(
      () => _i609.HistoryRepositoryImpl(
        remoteDataSource: gh<_i1047.HistoryRemoteDataSource>(),
        localDataSource: gh<_i961.HistoryLocalDataSource>(),
        networkInfo: gh<_i417.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i29.CurrencyRepository>(
      () => _i495.CurrencyRepositoryImpl(
        remoteDataSource: gh<_i940.CurrencyRemoteDataSource>(),
        localDataSource: gh<_i241.CurrencyLocalDataSource>(),
        networkInfo: gh<_i417.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i351.GetHistoricalRates>(
      () => _i351.GetHistoricalRates(gh<_i292.HistoryRepository>()),
    );
    gh.lazySingleton<_i153.ConverterRepository>(
      () => _i7.ConverterRepositoryImpl(
        remoteDataSource: gh<_i934.ConverterRemoteDataSource>(),
        localDataSource: gh<_i791.ConverterLocalDataSource>(),
        networkInfo: gh<_i417.NetworkInfo>(),
      ),
    );
    gh.factory<_i846.HistoryBloc>(
      () =>
          _i846.HistoryBloc(getHistoricalRates: gh<_i351.GetHistoricalRates>()),
    );
    gh.lazySingleton<_i416.ConvertCurrency>(
      () => _i416.ConvertCurrency(gh<_i153.ConverterRepository>()),
    );
    gh.lazySingleton<_i965.GetCurrencies>(
      () => _i965.GetCurrencies(gh<_i29.CurrencyRepository>()),
    );
    gh.factory<_i115.CurrenciesConverterBloc>(
      () => _i115.CurrenciesConverterBloc(
        convertCurrency: gh<_i416.ConvertCurrency>(),
        getCurrencies: gh<_i965.GetCurrencies>(),
        appPreferences: gh<_i965.AppPreferences>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i729.RegisterModule {}
