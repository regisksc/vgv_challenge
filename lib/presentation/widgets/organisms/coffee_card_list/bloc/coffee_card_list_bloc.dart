import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/domain/domain.dart';

// ignore: lines_longer_than_80_chars
class CoffeeCardListBloc extends Bloc<CoffeeCardListEvent, CoffeeCardListState> {
  CoffeeCardListBloc({required this.getList})
      : super(
          const CoffeeCardListLoading(),
        ) {
    on<LoadCoffeeCardList>(_onLoadCoffeeList);
  }

  final GetCoffeeList getList;

  Future<void> _onLoadCoffeeList(
    LoadCoffeeCardList event,
    Emitter<CoffeeCardListState> emit,
  ) async {
    emit(const CoffeeCardListLoading());
    final result = await getList();
    result.when(
      (list) => emit(CoffeeCardListLoaded(list: list)),
      (failure) => emit(CoffeeCardListFailedLoading(failure)),
    );
  }
}

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

abstract class CoffeeCardListEvent extends Equatable {
  const CoffeeCardListEvent();
  @override
  List<Object?> get props => [];
}

class LoadCoffeeCardList extends CoffeeCardListEvent {}
