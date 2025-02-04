import 'package:equatable/equatable.dart';
import 'package:vgv_challenge/domain/domain.dart';

abstract class HistoryListState extends Equatable {
  const HistoryListState();
  @override
  List<Object?> get props => [];
}

class HistoryListLoading extends HistoryListState {
  const HistoryListLoading();
  @override
  List<Object?> get props => [];
}

class HistoryListLoaded extends HistoryListState {
  const HistoryListLoaded({required this.list});
  final List<Coffee> list;
  @override
  List<Object?> get props => [list];
}

class HistoryListFailedLoading extends HistoryListState {
  const HistoryListFailedLoading(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
