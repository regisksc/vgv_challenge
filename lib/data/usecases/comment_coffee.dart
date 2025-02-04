import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

class CommentCoffee extends UpdateCoffee with CoffeeUpdateHelper {
  CommentCoffee({required this.storage});
  @override
  final Storage storage;

  @override
  Future<Result<void, Failure>> call([UpdateCoffeeParams? params]) async {
    if (params == null || params.newComment == null) {
      return Result.failure(UnexpectedInputFailure());
    }

    final coffeeId = params.coffee.id;
    final newComment = params.newComment!;
    return update(coffeeId, newComment);
  }
}
