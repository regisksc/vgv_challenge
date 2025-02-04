import 'dart:convert';

import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

abstract class GetCoffeeListFromStorage extends GetCoffeeList {
  GetCoffeeListFromStorage({required this.storage, required this.key});

  final Storage storage;
  final String key;

  @override
  Future<Result<List<Coffee>, Failure>> call([void params]) async {
    try {
      final readData = await storage.read(key: key);
      if (readData == null) return Result.failure(ReadingFromEmptyFailure());
      final list = (jsonDecode(readData) as List).map(
        (e) => e as Map<String, dynamic>,
      );
      final mappedList = list.map(CoffeeModel.fromJson).toList();
      return Result.success(mappedList.asEntities.reversed.toList());
    } catch (e) {
      return Result.failure(ReadingFailure());
    }
  }
}

class GetFavoriteCoffeeList extends GetCoffeeListFromStorage {
  GetFavoriteCoffeeList({
    required super.storage,
  }) : super(key: StorageConstants.favoritesKey);
}

class GetCoffeeHistoryList extends GetCoffeeListFromStorage {
  GetCoffeeHistoryList({
    required super.storage,
  }) : super(key: StorageConstants.historyKey);
}
