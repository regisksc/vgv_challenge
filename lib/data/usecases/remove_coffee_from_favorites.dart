import 'dart:convert';

import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

class RemoveCoffeeFromFavorites extends Unfavorite {
  RemoveCoffeeFromFavorites({required this.storage});

  final Storage storage;

  @override
  Future<Result<void, Failure>> call([Coffee? params]) async {
    try {
      if (params == null) return Result.failure(UnexpectedInputFailure());
      final favoriteList = await storage.getCoffeeList(
        StorageConstants.favoritesKey,
      );
      if (favoriteList == null || favoriteList.isEmpty) throw ReadingFailure();
      final initialLength = favoriteList.length;
      favoriteList.removeWhere((element) => element.id == params.id);
      if (favoriteList.length < initialLength) {
        await storage.write(
          key: StorageConstants.favoritesKey,
          value: jsonEncode(favoriteList.map((e) => e.toJson()).toList()),
        );
      }
      return const Result.success(null);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(
        ReadingOrWritingFailure(key: StorageConstants.favoritesKey),
      );
    }
  }
}
