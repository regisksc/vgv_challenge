// ignore_for_file: lines_longer_than_80_chars

import 'dart:convert';

import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

/// A mixin that helps update a Coffee in one or both lists (favorites or history).
/// If the coffee is not found in either list, returns [ItemNeverStoredFailure].
/// If a critical failure (non-notFound) occurs in one list, it returns that error.
mixin CoffeeUpdateHelper on UpdateCoffee {
  Storage get storage;

  /// Reads coffee from the given [key], applies [newComment] and/or [newRating],
  /// and writes back the updated list. Returns `Result.success(null)` on success,
  /// or a `Result.failure(...)` if a critical error occurs.
  Future<Result<void, Failure>> updateCoffeeIfPresent({
    required String key,
    required String coffeeId,
    String? newComment,
    CoffeeRating? newRating,
  }) async {
    try {
      final models = await storage.getCoffeeList(key);
      if (models == null) {
        return Result.failure(ReadingFromEmptyFailure());
      }
      final index = models.indexWhere((m) => m.id == coffeeId);
      if (index == -1) {
        return Result.failure(LookedUpItemNotInListFailure(key: key));
      }

      final oldModel = models[index];
      final updatedModel = oldModel.copyWith(
        comment: newComment ?? oldModel.comment,
        rating: newRating?.intValue ?? oldModel.rating,
      );
      models[index] = updatedModel;

      final updatedJson = jsonEncode(models.map((c) => c.toJson()).toList());
      await storage.write(key: key, value: updatedJson);
      return const Result.success(null);
    } catch (e) {
      if (e is Failure) return Result.failure(e);
      return Result.failure(ReadingFailure(key: key));
    }
  }

  /// Attempts to update a Coffee in one list (using [key]). If the update fails with
  /// a critical error (anything other than ReadingFromEmptyFailure or
  /// LookedUpItemNotInListFailure), returns that failure. Otherwise returns null
  /// (meaning either success or a non-critical failure that can be ignored).
  Future<Failure?> _tryUpdateKey({
    required String key,
    required String coffeeId,
    String? newComment,
    CoffeeRating? newRating,
  }) async {
    final result = await updateCoffeeIfPresent(
      key: key,
      coffeeId: coffeeId,
      newComment: newComment,
      newRating: newRating,
    );
    if (result.isFailure) {
      final fail = result.failure;
      final isIgnoredType = fail is ReadingFromEmptyFailure ||
          fail is LookedUpItemNotInListFailure;
      if (!isIgnoredType) return fail;
      return fail; 
    }
    return null;
  }

  /// Updates a Coffee by either newComment or newRating or both,
  /// across favorites and history lists. If a critical error (non-notFound) occurs
  /// in one list, returns that. If the Coffee is missing in both, returns
  /// [ItemNeverStoredFailure]. Otherwise returns success.
  Future<Result<void, Failure>> update(
    String coffeeId,
    Object? updateValue,
  ) async {
    try {
      final (String? newComment, CoffeeRating? newRating) =
          _extractUpdateData(updateValue);

      final favoritesFail = await _tryUpdateKey(
        key: StorageConstants.favoritesKey,
        coffeeId: coffeeId,
        newComment: newComment,
        newRating: newRating,
      );
      final notFoundInFavorites = favoritesFail is LookedUpItemNotInListFailure;
      final seriousFailInFavorites =
          favoritesFail != null && !notFoundInFavorites;
      if (seriousFailInFavorites) return Result.failure(favoritesFail);

      final historyFail = await _tryUpdateKey(
        key: StorageConstants.historyKey,
        coffeeId: coffeeId,
        newComment: newComment,
        newRating: newRating,
      );
      final notFoundInHistory = historyFail is LookedUpItemNotInListFailure;
      final seriousFailInHistory = historyFail != null && !notFoundInHistory;
      if (seriousFailInHistory) {
        return Result.failure(historyFail);
      }

      if (notFoundInFavorites && notFoundInHistory) {
        return Result.failure(ItemNeverStoredFailure());
      }
      return const Result.success(null);
    } catch (e) {
      if (e is Failure) return Result.failure(e);
      return Result.failure(ReadingFailure());
    }
  }

  (String?, CoffeeRating?) _extractUpdateData(Object? updateValue) {
    if (updateValue is String) {
      return (updateValue, null);
    } else if (updateValue is CoffeeRating) {
      return (null, updateValue);
    }
    return (null, null);
  }
}
