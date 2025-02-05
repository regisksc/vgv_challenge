import 'package:equatable/equatable.dart';
import 'package:vgv_challenge/domain/domain.dart';

abstract class DetailsEvent extends Equatable {
  const DetailsEvent();
  @override
  List<Object?> get props => [];
}

class CommentChanged extends DetailsEvent {
  const CommentChanged({required this.comment});
  final String comment;
  @override
  List<Object?> get props => [comment];
}

class FavoritedCoffee extends DetailsEvent {}

class UnfavoritedCoffee extends DetailsEvent {}

class SubmitComment extends DetailsEvent {}

class SubmitRating extends DetailsEvent {
  const SubmitRating({required this.rating});

  final CoffeeRating rating;
}
