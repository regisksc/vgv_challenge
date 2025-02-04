import 'package:equatable/equatable.dart';

abstract class MainScreenEvent extends Equatable {
  const MainScreenEvent();
  @override
  List<Object?> get props => [];
}

class FetchRandomCoffee extends MainScreenEvent {}

class RefreshRandomCoffee extends MainScreenEvent {}
