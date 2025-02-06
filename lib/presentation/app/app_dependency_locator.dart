import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  final box = await Hive.openBox<String>('coffee_box');

  // Core Dependencies
  sl
    ..registerLazySingleton<Dio>(Dio.new)
    ..registerLazySingleton<HttpClient>(() => DioHttpClient(dio: sl<Dio>()))
    ..registerLazySingleton<Box<String>>(() => box)
    ..registerLazySingleton<Storage>(() => HiveStorage(box: sl<Box<String>>()))

    // Use Cases
    ..registerSingleton<FetchCoffeeFromRemote>(
      FetchCoffeeFromRemote(httpClient: sl<HttpClient>()),
    )
    ..registerSingleton<FetchCoffeeFromHistory>(
      FetchCoffeeFromHistory(storage: sl<Storage>()),
    )
    ..registerSingleton<GetCoffeeList>(
      GetCoffeeHistoryList(storage: sl<Storage>()),
      instanceName: 'history',
    )
    ..registerSingleton<GetCoffeeList>(
      GetFavoriteCoffeeList(storage: sl<Storage>()),
      instanceName: StorageConstants.favoritesKey,
    )
    ..registerSingleton<SaveCoffee>(
      SaveCoffeeToFavorites(storage: sl<Storage>()),
      instanceName: 'saveFavorite',
    )
    ..registerSingleton<SaveCoffee>(
      SaveCoffeeToHistory(storage: sl<Storage>()),
      instanceName: 'saveHistory',
    )
    ..registerSingleton<Unfavorite>(
      RemoveCoffeeFromFavorites(storage: sl<Storage>()),
    )
    ..registerSingleton<UpdateCoffee>(
      RateCoffee(storage: sl<Storage>()),
      instanceName: 'rateCoffee',
    )
    ..registerSingleton<UpdateCoffee>(
      CommentCoffee(storage: sl<Storage>()),
      instanceName: 'commentCoffee',
    );
}
