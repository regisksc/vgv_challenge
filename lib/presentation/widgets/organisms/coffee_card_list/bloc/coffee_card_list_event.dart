import 'package:equatable/equatable.dart';

abstract class CoffeeCardListEvent extends Equatable {
  const CoffeeCardListEvent();
  @override
  List<Object?> get props => [];
}

class LoadCoffeeCardList extends CoffeeCardListEvent {}
