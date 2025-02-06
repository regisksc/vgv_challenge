import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

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
