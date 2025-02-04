import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class HistoryListBloc extends Bloc<HistoryListEvent, HistoryListState> {
  HistoryListBloc({required this.getHistoryList})
      : super(
          const HistoryListLoading(),
        ) {
    on<LoadHistory>(_onFetchHistoryList);
  }
  final GetCoffeeList getHistoryList;

  Future<void> _onFetchHistoryList(
    LoadHistory event,
    Emitter<HistoryListState> emit,
  ) async {
    emit(const HistoryListLoading());
    final result = await getHistoryList();
    result.when(
      (list) => emit(HistoryListLoaded(list: list)),
      (failure) => emit(HistoryListFailedLoading(failure)),
    );
  }
}
