import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

// ignore: lines_longer_than_80_chars
class CoffeeInteractionBloc extends Bloc<CoffeeInteractionEvent, CoffeeInteractionState> {
  CoffeeInteractionBloc({
    required UpdateCoffee commentCoffee,
    required UpdateCoffee rateCoffee,
  })  : _commentCoffee = commentCoffee,
        _rateCoffee = rateCoffee,
        super(CoffeeInteractionInitial()) {
    on<CommentChanged>(_onCommentChanged);
    on<SubmitComment>(_onSubmitComment);
    on<SubmitRating>(_onSubmitRating);
  }
  final UpdateCoffee _commentCoffee;
  final UpdateCoffee _rateCoffee;

  Timer? _debounce;
  String _lastComment = '';

  Emitter<CoffeeInteractionState>? _emitter;

  void _onCommentChanged(
    CommentChanged event,
    Emitter<CoffeeInteractionState> emit,
  ) {
    _emitter = emit;
    emit(CommentIsGettingInput());
    _lastComment = event.comment;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 5), () {
      if (_emitter == null) return;

      add(SubmitComment(coffee: event.coffee));
    });
  }

  Future<void> _onSubmitComment(
    SubmitComment event,
    Emitter<CoffeeInteractionState> emit,
  ) async {
    _emitter = emit;
    emit(CommentSubmissionInProgress());
    final params = UpdateCoffeeParams(
      coffee: event.coffee,
      newComment: _lastComment,
    );
    final result = await _commentCoffee(params);
    result.when(
      (updatedCoffee) => emit(CommentSubmissionSuccess()),
      (failure) => emit(CommentSubmissionFailure(failure: failure)),
    );
  }

  Future<void> _onSubmitRating(
    SubmitRating event,
    Emitter<CoffeeInteractionState> emit,
  ) async {
    emit(RatingSubmissionInProgress());
    final params = UpdateCoffeeParams(
      coffee: event.coffee,
      newRating: event.rating,
    );
    final result = await _rateCoffee(params);
    result.when(
      (_) => emit(RatingSubmissionSuccess(rating: event.rating)),
      (failure) => emit(RatingSubmissionFailure(failure: failure)),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
