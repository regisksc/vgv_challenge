import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class DetailsBloc extends Bloc<DetailsEvent, DetailsState> {
  DetailsBloc({
    required this.commentCoffee,
    required this.initialCoffee,
    required this.historyListBloc,
  }) : super(DetailsInitial()) {
    on<CommentChanged>(_onCommentChanged);
    on<SubmitComment>(_onSubmitComment);
  }

  final CommentCoffee commentCoffee;
  final Coffee initialCoffee;
  Timer? _debounce;
  String _lastComment = '';

  final HistoryListBloc historyListBloc;

  void _onCommentChanged(
    CommentChanged event,
    Emitter<DetailsState> emit,
  ) {
    _lastComment = event.comment;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 3), () {
      add(SubmitComment());
    });
  }

  Future<void> _onSubmitComment(
    SubmitComment event,
    Emitter<DetailsState> emit,
  ) async {
    emit(CommentSubmissionInProgress());
    final params = UpdateCoffeeParams(
      coffee: initialCoffee,
      newComment: _lastComment,
    );
    final result = await commentCoffee(params);
    result.when(
      (coffee) {
        emit(CommentSubmissionSuccess());
        historyListBloc.add(LoadHistory());
      },
      (failure) => emit(CommentSubmissionFailure(failure: failure)),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
