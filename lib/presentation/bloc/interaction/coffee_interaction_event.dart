import 'package:vgv_challenge/domain/domain.dart';

abstract class CoffeeInteractionEvent {}

class CommentChanged extends CoffeeInteractionEvent {
  CommentChanged({required this.coffee, required this.comment});
  final String comment;
  final Coffee coffee;
}

class SubmitComment extends CoffeeInteractionEvent {
  SubmitComment({required this.coffee});

  final Coffee coffee;
}

class SubmitRating extends CoffeeInteractionEvent {
  SubmitRating({required this.coffee, required this.rating});
  final CoffeeRating rating;
  final Coffee coffee;
}
