import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class DetailsBloc extends Bloc<DetailsEvent, DetailsState> {
  DetailsBloc({
    required UpdateCoffee commentCoffee,
    required UpdateCoffee rateCoffee,
    required SaveCoffee favoriteCoffee,
    required Unfavorite unfavoriteCoffee,
    required Coffee initialCoffee,
    required CoffeeCardListBloc historyListBloc,
    required CoffeeCardListBloc favoritesListBloc,
  })  : _commentCoffee = commentCoffee,
        _rateCoffee = rateCoffee,
        _favoriteCoffee = favoriteCoffee,
        _unfavoriteCoffee = unfavoriteCoffee,
        _initialCoffee = initialCoffee,
        _historyListBloc = historyListBloc,
        _favoritesListBloc = favoritesListBloc,
        super(DetailsInitial()) {
    on<CommentChanged>(_onCommentChanged);
    on<SubmitRating>(_onSubmitRating);
    on<SubmitComment>(_onSubmitComment);
    on<FavoritedCoffee>(_onFavoritedCoffee);
    on<UnfavoritedCoffee>(_onUnfavoritedCoffee);
  }

  // Private members
  final UpdateCoffee _commentCoffee;
  final UpdateCoffee _rateCoffee;
  final SaveCoffee _favoriteCoffee;
  final Unfavorite _unfavoriteCoffee;
  final Coffee _initialCoffee;
  final CoffeeCardListBloc _historyListBloc;
  final CoffeeCardListBloc _favoritesListBloc;

  Timer? _debounce;
  String _lastComment = '';

  // Event handlers
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
      coffee: _initialCoffee,
      newComment: _lastComment,
    );
    final result = await _commentCoffee(params);
    result.when(
      (coffee) {
        emit(CommentSubmissionSuccess());
        _historyListBloc.add(LoadCoffeeCardList());
        _favoritesListBloc.add(LoadCoffeeCardList());
      },
      (failure) => emit(CommentSubmissionFailure(failure: failure)),
    );
  }

  Future<void> _onSubmitRating(
    SubmitRating event,
    Emitter<DetailsState> emit,
  ) async {
    emit(RatingSubmissionInProgress());
    final params = UpdateCoffeeParams(
      coffee: _initialCoffee,
      newRating: event.rating,
    );
    final result = await _rateCoffee(params);
    result.when(
      (_) => emit(RatingSubmissionSuccess()),
      (failure) => emit(RatingSubmissionFailure(failure: failure)),
    );
  }

  Future<void> _onFavoritedCoffee(
    FavoritedCoffee event,
    Emitter<DetailsState> emit,
  ) async {
    emit(FavoritingInProgress());
    final result = await _favoriteCoffee(_initialCoffee);
    result.when(
      (_) {
        emit(FavoritingSuccess());
        _favoritesListBloc.add(LoadCoffeeCardList());
      },
      (failure) => emit(FavoritingFailure(failure: failure)),
    );
  }

  Future<void> _onUnfavoritedCoffee(
    UnfavoritedCoffee event,
    Emitter<DetailsState> emit,
  ) async {
    emit(UnfavoritingInProgress());
    final result = await _unfavoriteCoffee(_initialCoffee);
    result.when(
      (_) {
        emit(UnfavoritingSuccess());
        _favoritesListBloc.add(LoadCoffeeCardList());
      },
      (failure) => emit(UnfavoritingFailure(failure: failure)),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
