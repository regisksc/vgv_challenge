import 'package:equatable/equatable.dart';

abstract class HistoryListEvent extends Equatable {
  const HistoryListEvent();
  @override
  List<Object?> get props => [];
}

class LoadHistory extends HistoryListEvent {}
