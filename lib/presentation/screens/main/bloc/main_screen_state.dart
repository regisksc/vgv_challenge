import 'package:equatable/equatable.dart';
import 'package:vgv_challenge/domain/domain.dart';

abstract class MainScreenState extends Equatable {
  const MainScreenState();
  @override
  List<Object?> get props => [];
}

class MainScreenLoading extends MainScreenState {}

class MainScreenLoaded extends MainScreenState {
  const MainScreenLoaded({required this.coffee});
  final Coffee coffee;
  @override
  List<Object?> get props => [coffee];
}

class MainScreenFailure extends MainScreenState {
  const MainScreenFailure(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

class NewCoffeeTapped extends MainScreenState {}

class IsNavigating extends MainScreenState {
  const IsNavigating({required this.destination, required this.coffee});
  final String destination;
  final Coffee? coffee;

  @override
  List<Object?> get props => [destination, coffee];
}
