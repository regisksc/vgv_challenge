import 'package:vgv_challenge/domain/domain.dart';

/// Base state.
abstract class CoffeeInteractionState {}

/// Initial state.
class CoffeeInteractionInitial extends CoffeeInteractionState {}

/// States for comment submission.
class CommentSubmissionInProgress extends CoffeeInteractionState {}

class CommentSubmissionSuccess extends CoffeeInteractionState {}

class CommentSubmissionFailure extends CoffeeInteractionState {
  CommentSubmissionFailure({required this.failure});
  final Failure failure;
}

/// States for rating submission.
class RatingSubmissionInProgress extends CoffeeInteractionState {}

class RatingSubmissionSuccess extends CoffeeInteractionState {
  RatingSubmissionSuccess({required this.rating});
  final CoffeeRating rating;
}

class RatingSubmissionFailure extends CoffeeInteractionState {
  RatingSubmissionFailure({required this.failure});
  final Failure failure;
}
