import 'package:vgv_challenge/domain/domain.dart';

abstract class FavoritesState {}

class FavoritesInitial extends FavoritesState {}

class FavoritingInProgress extends FavoritesState {}

class FavoritingSuccess extends FavoritesState {}

class FavoritingFailure extends FavoritesState {
  FavoritingFailure({required this.failure});
  final Failure failure;
}

class UnfavoritingInProgress extends FavoritesState {}

class UnfavoritingSuccess extends FavoritesState {}

class UnfavoritingFailure extends FavoritesState {
  UnfavoritingFailure({required this.failure});
  final Failure failure;
}
