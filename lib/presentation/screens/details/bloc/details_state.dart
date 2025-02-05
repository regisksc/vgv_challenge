import 'package:equatable/equatable.dart';
import 'package:vgv_challenge/domain/domain.dart';

abstract class DetailsState extends Equatable {
  const DetailsState();
  @override
  List<Object?> get props => [];
}

class DetailsInitial extends DetailsState {}

class CommentSubmissionInProgress extends DetailsState {}

class CommentSubmissionSuccess extends DetailsState {}

class CommentSubmissionFailure extends DetailsState {
  const CommentSubmissionFailure({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
