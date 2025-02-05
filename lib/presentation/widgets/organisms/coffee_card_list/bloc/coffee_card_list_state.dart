import 'package:equatable/equatable.dart';
import 'package:vgv_challenge/domain/domain.dart';

abstract class CoffeeCardListState extends Equatable {
  const CoffeeCardListState();
  @override
  List<Object?> get props => [];
}

class CoffeeCardListLoading extends CoffeeCardListState {
  const CoffeeCardListLoading();
  @override
  List<Object?> get props => [];
}

class CoffeeCardListLoaded extends CoffeeCardListState {
  const CoffeeCardListLoaded({required this.list});
  final List<Coffee> list;
  @override
  List<Object?> get props => [list];
}

class CoffeeCardListFailedLoading extends CoffeeCardListState {
  const CoffeeCardListFailedLoading(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
