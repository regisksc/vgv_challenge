import 'package:vgv_challenge/domain/domain.dart';

abstract class CoffeeInteractionState {}

class CoffeeInteractionInitial extends CoffeeInteractionState {}

class CommentSubmissionInProgress extends CoffeeInteractionState {}

class CommentSubmissionSuccess extends CoffeeInteractionState {}

class CommentSubmissionFailure extends CoffeeInteractionState {
  CommentSubmissionFailure({required this.failure});
  final Failure failure;
}

class RatingSubmissionInProgress extends CoffeeInteractionState {}

class RatingSubmissionSuccess extends CoffeeInteractionState {
  RatingSubmissionSuccess({required this.rating});
  final CoffeeRating rating;
}

class RatingSubmissionFailure extends CoffeeInteractionState {
  RatingSubmissionFailure({required this.failure});
  final Failure failure;
}
