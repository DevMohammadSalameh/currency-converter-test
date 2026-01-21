import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'core/network/endpoints.dart';
import 'core/database/database_helper.dart';
import 'core/network/network_info.dart';
import 'core/storage/app_preferences.dart';

// Currencies feature
import 'features/converter/data/datasources/currency_local_data_source.dart';
import 'features/converter/data/datasources/currency_remote_data_source.dart';
import 'features/converter/data/repositories/currency_repository_impl.dart';
import 'features/converter/domain/repositories/currency_repository.dart';
import 'features/converter/domain/usecases/get_currencies.dart';

// Converter feature
import 'features/converter/data/datasources/converter_local_data_source.dart';
import 'features/converter/data/datasources/converter_remote_data_source.dart';
import 'features/converter/data/repositories/converter_repository_impl.dart';
import 'features/converter/domain/repositories/converter_repository.dart';
import 'features/converter/domain/usecases/convert_currency.dart';
import 'features/converter/presentation/bloc/currencies_converter_bloc.dart';

// History feature
import 'features/history/data/datasources/history_local_data_source.dart';
import 'features/history/data/datasources/history_remote_data_source.dart';
import 'features/history/data/repositories/history_repository_impl.dart';
import 'features/history/domain/repositories/history_repository.dart';
import 'features/history/domain/usecases/get_historical_rates.dart';
import 'features/history/presentation/bloc/history_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ==================== External ====================
  final database = await DatabaseHelper.database;
  sl.registerLazySingleton<Database>(() => database);

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: Endpoints.connectTimeout,
        receiveTimeout: Endpoints.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    return dio;
  });

  sl.registerLazySingleton(() => InternetConnectionChecker.instance);

  // ==================== Core ====================
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<AppPreferences>(() => AppPreferences(sl()));

  // ==================== Features ====================
  _initCurrenciesFeature();
  _initConverterFeature();
  _initHistoryFeature();
}

void _initCurrenciesFeature() {
  // Bloc
  sl.registerFactory(
    () => CurrenciesConverterBloc(getCurrencies: sl(), convertCurrency: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCurrencies(sl()));

  // Repository
  sl.registerLazySingleton<CurrencyRepository>(
    () => CurrencyRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<CurrencyRemoteDataSource>(
    () => CurrencyRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<CurrencyLocalDataSource>(
    () => CurrencyLocalDataSourceImpl(database: sl()),
  );
}

void _initConverterFeature() {
  // Use cases
  sl.registerLazySingleton(() => ConvertCurrency(sl()));

  // Repository
  sl.registerLazySingleton<ConverterRepository>(
    () => ConverterRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ConverterRemoteDataSource>(
    () => ConverterRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<ConverterLocalDataSource>(
    () => ConverterLocalDataSourceImpl(database: sl()),
  );
}

void _initHistoryFeature() {
  // Bloc
  sl.registerFactory(() => HistoryBloc(getHistoricalRates: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetHistoricalRates(sl()));

  // Repository
  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<HistoryRemoteDataSource>(
    () => HistoryRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<HistoryLocalDataSource>(
    () => HistoryLocalDataSourceImpl(database: sl()),
  );
}
