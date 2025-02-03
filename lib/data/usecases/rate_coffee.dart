import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

class RateCoffee extends UpdateCoffee with CoffeeUpdateHelper {
  RateCoffee({required this.storage});
  @override
  final Storage storage;

  @override
  Future<Result<Coffee, Failure>> call([UpdateCoffeeParams? params]) async {
    try {
      if (params == null || params.newRating == null) {
        throw UnexpectedInputFailure();
      }

      final coffeeId = params.coffee.id;
      final newRating = params.newRating!;

      // fRes => favoriteLookupResult (line length sake)
      final fRes = await updateCoffeeIfPresent(
        key: StorageConstants.favoritesKey,
        coffeeId: coffeeId,
        newRating: newRating,
      );
      if (fRes.isFailure && fRes.failure is! LookedUpItemNotInListFailure) {
        return Result.failure(fRes.failure);
      }

      // hRes => historyLookupResult (line length sake)
      final hRes = await updateCoffeeIfPresent(
        key: StorageConstants.historyKey,
        coffeeId: coffeeId,
        newRating: newRating,
      );
      if (hRes.isFailure && hRes.failure is! LookedUpItemNotInListFailure) {
        return Result.failure(hRes.failure);
      }

      CoffeeModel? finalModel;
      if (fRes.isSuccess) finalModel = fRes.successValue;
      if (hRes.isSuccess) finalModel = hRes.successValue;

      if (finalModel == null) return Result.failure(ItemNeverStoredFailure());
      return Result.success(finalModel.asEntity);
    } catch (e) {
      if (e is Failure) return Result.failure(e);
      return Result.failure(ReadingFailure());
    }
  }
}
