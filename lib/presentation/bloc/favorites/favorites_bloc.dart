import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc({
    required Coffee coffee,
    required SaveCoffee saveCoffee,
    required Unfavorite unfavoriteCoffee,
  })  : _coffee = coffee,
        _saveCoffee = saveCoffee,
        _unfavoriteCoffee = unfavoriteCoffee,
        super(FavoritesInitial()) {
    on<FavoritedCoffee>(_onFavoritedCoffee);
    on<UnfavoritedCoffee>(_onUnfavoritedCoffee);
  }

  final Coffee _coffee;
  final SaveCoffee _saveCoffee;
  final Unfavorite _unfavoriteCoffee;

  Future<void> _onFavoritedCoffee(
    FavoritedCoffee event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritingInProgress());
    final result = await _saveCoffee(_coffee);
    result.when(
      (_) => emit(FavoritingSuccess()),
      (failure) => emit(FavoritingFailure(failure: failure)),
    );
  }

  Future<void> _onUnfavoritedCoffee(
    UnfavoritedCoffee event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(UnfavoritingInProgress());
    final result = await _unfavoriteCoffee(_coffee);
    result.when(
      (_) => emit(UnfavoritingSuccess()),
      (failure) => emit(UnfavoritingFailure(failure: failure)),
    );
  }
}
