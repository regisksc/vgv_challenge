import 'dart:convert';

import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

/// A mixin that updates a Coffee in favorites/history. If the coffee is not found
/// in both lists, returns [ItemNeverStoredFailure]. If a critical error
/// occurs in one list, returns that error immediately.
mixin CoffeeUpdateHelper on UpdateCoffee {
  Storage get storage;

  /// Attempts to update the coffee in both favorites and history. If a critical
  /// error (like real read/write failure) occurs in either, returns it.
  /// If both fail because they're empty or item not found, returns
  /// [ItemNeverStoredFailure]. Otherwise success.
  Future<Result<void, Failure>> update(
    String coffeeId,
    Object? updateValue,
  ) async {
    try {
      final (
        String? newComment,
        CoffeeRating? newRating,
      ) = _extractUpdateData(updateValue);

      final favoritesErr = await _updateSingleList(
        key: StorageConstants.favoritesKey,
        coffeeId: coffeeId,
        newComment: newComment,
        newRating: newRating,
      );
      final notFoundInFavorites = _isRecoverableNotFound(favoritesErr);

      if (favoritesErr != null && !notFoundInFavorites) {
        return Result.failure(favoritesErr);
      }

      final historyErr = await _updateSingleList(
        key: StorageConstants.historyKey,
        coffeeId: coffeeId,
        newComment: newComment,
        newRating: newRating,
      );
      final notFoundInHistory = _isRecoverableNotFound(historyErr);

      if (historyErr != null && !notFoundInHistory) {
        return Result.failure(historyErr);
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

  /// Reads coffee from [key], updates with [newComment]/[newRating] if found,
  /// writes back to storage. Returns:
  /// - `null` if updated or if coffee wasn't found in a "recoverable" way
  ///   ([ReadingFromEmptyFailure], [LookedUpItemNotInListFailure]).
  /// - a [Failure] if a critical error occurs (like a real read/write error).
  Future<Failure?> _updateSingleList({
    required String key,
    required String coffeeId,
    String? newComment,
    CoffeeRating? newRating,
  }) async {
    try {
      final models = await storage.getCoffeeList(key);
      if (models == null) return ReadingFromEmptyFailure();
      final index = models.indexWhere((m) => m.id == coffeeId);
      if (index == -1) return LookedUpItemNotInListFailure(key: key);

      final oldModel = models[index];
      final updated = oldModel.copyWith(
        comment: newComment ?? oldModel.comment,
        rating: newRating?.intValue ?? oldModel.rating,
      );
      models[index] = updated;

      final updatedJson = jsonEncode(models.map((c) => c.toJson()).toList());
      await storage.write(key: key, value: updatedJson);
      return null;
    } catch (e) {
      if (e is Failure) return e;
      return ReadingFailure(
        key: key,
        originalException: e.toString(),
      );
    }
  }

  // ignore: comment_references
  /// Helper to parse an [updateValue]
  /// into (String? newComment, CoffeeRating? newRating).
  (String?, CoffeeRating?) _extractUpdateData(Object? value) {
    if (value is String) return (value, null);
    if (value is CoffeeRating) return (null, value);
    return (null, null);
  }

  /// Returns true if the error is [ReadingFromEmptyFailure] or
  /// [LookedUpItemNotInListFailure], i.e. recoverable "not found" scenario.
  bool _isRecoverableNotFound(Failure? fail) {
    final readingFromEmpty = fail is ReadingFromEmptyFailure;
    final notInList = fail is LookedUpItemNotInListFailure;
    return readingFromEmpty || notInList;
  }
}
