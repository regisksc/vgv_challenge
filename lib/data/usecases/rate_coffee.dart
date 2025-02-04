import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

class RateCoffee extends UpdateCoffee with CoffeeUpdateHelper {
  RateCoffee({required this.storage});
  @override
  final Storage storage;

  @override
  Future<Result<void, Failure>> call([UpdateCoffeeParams? params]) async {
    if (params == null || params.newRating == null) {
      return Result.failure(UnexpectedInputFailure());
    }

    final coffeeId = params.coffee.id;
    final newRating = params.newRating!;
    return update(coffeeId, newRating);
  }
}
