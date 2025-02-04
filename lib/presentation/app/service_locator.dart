import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:vgv_challenge/data/data.dart';

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
    ..registerSingleton<GetCoffeeHistoryList>(
      GetCoffeeHistoryList(storage: sl<Storage>()),
    )
    ..registerSingleton<GetFavoriteCoffeeList>(
      GetFavoriteCoffeeList(storage: sl<Storage>()),
    )
    ..registerSingleton<SaveCoffeeToFavorites>(
      SaveCoffeeToFavorites(storage: sl<Storage>()),
    )
    ..registerSingleton<SaveCoffeeToHistory>(
      SaveCoffeeToHistory(storage: sl<Storage>()),
    )
    ..registerSingleton<RateCoffee>(
      RateCoffee(storage: sl<Storage>()),
    )
    ..registerSingleton<CommentCoffee>(
      CommentCoffee(storage: sl<Storage>()),
    );
}
