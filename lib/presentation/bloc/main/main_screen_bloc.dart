import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class MainScreenBloc extends Bloc<MainScreenEvent, MainScreenState> {
  MainScreenBloc({
    required this.historyListBloc,
    required this.apiFetchCoffee,
    required this.localFetchCoffee,
    required this.saveCoffeeToHistory,
  }) : super(MainScreenLoading()) {
    on<FetchRandomCoffee>(_onFetchRandomCoffee);
    on<RefreshRandomCoffee>(_onRefreshMainScreen);
    on<ReloadLoadedImage>(_onReloadLoadedImage);
  }

  final CoffeeCardListBloc historyListBloc;
  final GetCoffee apiFetchCoffee;
  final GetCoffee localFetchCoffee;
  final SaveCoffee saveCoffeeToHistory;

  Coffee? _latestCoffee;

  Future<void> _onFetchRandomCoffee(
    FetchRandomCoffee event,
    Emitter<MainScreenState> emit,
  ) async {
    if (state is CoffeeCardListLoading) return;
    _latestCoffee = null;
    emit(MainScreenLoading());
    final apiFetchResult = await apiFetchCoffee();
    await apiFetchResult.when(
      (coffee) async {
        _latestCoffee = coffee;
        final saveResult = await saveCoffeeToHistory(coffee);
        saveResult.when(
          (success) {
            historyListBloc.add(LoadCoffeeCardList());
          },
          (failure) => emit(MainScreenFailure(failure)),
        );
        emit(MainScreenLoaded(coffee: coffee));
      },
      (failure) async {
        final localFetchResult = await localFetchCoffee();
        localFetchResult.when(
          (coffee) {
            emit(MainScreenLoaded(coffee: coffee));
          },
          (failure) {
            emit(MainScreenFailure(failure));
          },
        );
      },
    );
  }

  Future<void> _onRefreshMainScreen(
    RefreshRandomCoffee event,
    Emitter<MainScreenState> emit,
  ) async =>
      _onFetchRandomCoffee(FetchRandomCoffee(), emit);

  Future<void> _onReloadLoadedImage(
    ReloadLoadedImage event,
    Emitter<MainScreenState> emit,
  ) async {
    if (_latestCoffee == null) {
      return;
    } else {
      emit(MainScreenLoaded(coffee: _latestCoffee!));
    }
  }
}
