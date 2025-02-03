// ignore_for_file: lines_longer_than_80_chars

import 'dart:convert';

import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

mixin CoffeeUpdateHelper on UpdateCoffee {
  Storage get storage;

  /// Reads the coffee list from the given [key], updates the coffee with [coffeeId]
  /// by applying [newComment] and/or [newRating], and writes back the updated list.
  /// If the coffee is not found, returns a failure of type [LookedUpItemNotInListFailure].
  Future<Result<CoffeeModel, Failure>> updateCoffeeIfPresent({
    required String key,
    required String coffeeId,
    String? newComment,
    CoffeeRating? newRating,
  }) async {
    try {
      final models = await storage.getCoffeeList(key);
      final index = models.indexWhere((m) => m.id == coffeeId);
      if (index == -1) {
        return Result.failure(LookedUpItemNotInListFailure(key: key));
      }
      final oldModel = models[index];
      final updatedModel = oldModel.copyWith(
        comment: newComment ?? oldModel.comment,
        rating: newRating != null ? newRating.intValue : oldModel.rating,
      );
      models[index] = updatedModel;
      final updatedJson = jsonEncode(models.map((c) => c.toJson()).toList());
      await storage.write(key: key, value: updatedJson);
      return Result.success(updatedModel);
    } catch (e) {
      if (e is Failure) return Result.failure(e);
      return Result.failure(ReadingFailure(key: key));
    }
  }
}
