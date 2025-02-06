import 'dart:convert';

import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

abstract class SaveCoffeeToList extends SaveCoffee {
  SaveCoffeeToList({
    required this.storage,
    required this.key,
    required this.limit,
  });

  final Storage storage;
  final String key;
  final int limit;

  @override
  Future<Result<void, Failure>> call([Coffee? params]) async {
    try {
      if (params == null) return Result.failure(UnexpectedInputFailure());
      final currentValue = await storage.read(key: key);

      List<Map<String, dynamic>> coffeesList;
      final isExistingList = currentValue != null;
      coffeesList = isExistingList ? _decodeExistingList(currentValue) : [];

      var model = CoffeeModel.fromEntity(params);

      if (key == StorageConstants.favoritesKey && model.isFavorite == false) {
        model = model.copyWith(isFavorite: true);
      }

      if (coffeesList.any((item) => item['id'] == model.id)) {
        return Result.failure(ItemAlreadySaved(key: key));
      }

      coffeesList.add(model.toJson());
      while (coffeesList.length > limit) {
        coffeesList.removeAt(0);
      }
      await storage.write(key: key, value: jsonEncode(coffeesList));
      return const Result.success(null);
    } catch (e) {
      if (e is Failure) return Result.failure(e);
      return Result.failure(WritingFailure(key: key));
    }
  }

  List<Map<String, dynamic>> _decodeExistingList(String currentValue) {
    try {
      final decoded = jsonDecode(currentValue);
      return decoded is List ? List<Map<String, dynamic>>.from(decoded) : [];
    } catch (_) {
      return [];
    }
  }
}

class SaveCoffeeToFavorites extends SaveCoffeeToList {
  SaveCoffeeToFavorites({required super.storage})
      : super(
          key: StorageConstants.favoritesKey,
          limit: StorageConstants.favoritesLimit,
        );
}

class SaveCoffeeToHistory extends SaveCoffeeToList {
  SaveCoffeeToHistory({required super.storage})
      : super(
          key: StorageConstants.historyKey,
          limit: StorageConstants.historyLimit,
        );
}
