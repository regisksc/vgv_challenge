import 'package:equatable/equatable.dart';

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

class SubmitComment extends DetailsEvent {}
