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
    on<TapCoffee>((event, emit) {
      if (state is MainScreenLoaded) {
        final loadedState = state as MainScreenLoaded;
        emit(
          IsNavigating(
            destination: AppRoutes.details,
            coffee: event.coffee ?? loadedState.coffee,
          ),
        );
      }
    });
    on<TapFavoritesCallToAction>((event, emit) {
      emit(const IsNavigating(destination: AppRoutes.favorites, coffee: null));
    });
  }

  final HistoryListBloc historyListBloc;
  final GetCoffee apiFetchCoffee;
  final GetCoffee localFetchCoffee;
  final SaveCoffee saveCoffeeToHistory;

  Future<void> _onFetchRandomCoffee(
    FetchRandomCoffee event,
    Emitter<MainScreenState> emit,
  ) async {
    if (state is HistoryListLoading) return;
    emit(MainScreenLoading());
    final apiFetchResult = await apiFetchCoffee();
    await apiFetchResult.when(
      (coffee) async {
        final saveResult = await saveCoffeeToHistory(coffee);
        saveResult.when(
          (success) {
            historyListBloc.add(LoadHistory());
          },
          (failure) {
            emit(MainScreenFailure(failure));
          },
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
}
