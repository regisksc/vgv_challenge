import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

class CommentCoffee extends UpdateCoffee with CoffeeUpdateHelper {
  CommentCoffee({required this.storage});
  @override
  final Storage storage;

  @override
  Future<Result<Coffee, Failure>> call([UpdateCoffeeParams? params]) async {
    try {
      if (params == null || params.newComment == null) {
        throw UnexpectedInputFailure();
      }

      final coffeeId = params.coffee.id;
      final newComment = params.newComment!;

      // fRes => favoriteLookupResult (line length sake)
      final fRes = await updateCoffeeIfPresent(
        key: StorageConstants.favoritesKey,
        coffeeId: coffeeId,
        newComment: newComment,
      );
      if (fRes.isFailure && fRes.failure is! LookedUpItemNotInListFailure) {
        return Result.failure(fRes.failure);
      }

      // hRes => historyLookupResult (line length sake)
      final hRes = await updateCoffeeIfPresent(
        key: StorageConstants.historyKey,
        coffeeId: coffeeId,
        newComment: newComment,
      );
      if (hRes.isFailure && hRes.failure is! LookedUpItemNotInListFailure) {
        return Result.failure(hRes.failure);
      }

      var finalModel = hRes.isSuccess ? hRes.successValue : null;
      finalModel = fRes.isSuccess ? fRes.successValue : finalModel;

      if (finalModel == null) return Result.failure(ItemNeverStoredFailure());
      return Result.success(finalModel.asEntity);
    } catch (e) {
      if (e is Failure) return Result.failure(e);
      return Result.failure(ReadingFailure());
    }
  }
}
