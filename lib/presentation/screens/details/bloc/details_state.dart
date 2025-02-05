import 'package:vgv_challenge/domain/domain.dart';

abstract class DetailsState {}

class DetailsInitial extends DetailsState {}

class CommentSubmissionInProgress extends DetailsState {}

class CommentSubmissionSuccess extends DetailsState {}

class CommentSubmissionFailure extends DetailsState {
  CommentSubmissionFailure({required this.failure});
  final Failure failure;
}

class RatingSubmissionInProgress extends DetailsState {}

class RatingSubmissionSuccess extends DetailsState {}

class RatingSubmissionFailure extends DetailsState {
  RatingSubmissionFailure({required this.failure});
  final Failure failure;
}

class FavoritingInProgress extends DetailsState {}

class FavoritingSuccess extends DetailsState {}

class FavoritingFailure extends DetailsState {
  FavoritingFailure({required this.failure});
  final Failure failure;
}

class UnfavoritingInProgress extends DetailsState {}

class UnfavoritingSuccess extends DetailsState {}

class UnfavoritingFailure extends DetailsState {
  UnfavoritingFailure({required this.failure});
  final Failure failure;
}
