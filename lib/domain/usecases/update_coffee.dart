import 'package:equatable/equatable.dart';
import 'package:vgv_challenge/domain/domain.dart';

// ignore: lines_longer_than_80_chars
abstract class UpdateCoffee extends Usecase<Result<Coffee, Failure>, UpdateCoffeeParams> {}

base class UpdateCoffeeParams extends Equatable {
  const UpdateCoffeeParams({
    required this.coffee,
    this.newComment,
    this.newRating,
  });

  final Coffee coffee;
  final String? newComment;
  final CoffeeRating? newRating;

  @override
  List<Object?> get props => [coffee, newComment, newRating];
}
