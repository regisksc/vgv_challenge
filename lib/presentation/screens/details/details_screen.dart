import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({
    required this.coffee,
    super.key,
    this.onTap,
  });

  final Coffee coffee;
  final GestureTapCallback? onTap;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late final TextEditingController _controller;
  late bool _isFavorite;
  late final CoffeeInteractionBloc _coffeeInteractionBloc;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.coffee.comment ?? '');
    _isFavorite = widget.coffee.isFavorite;
    _coffeeInteractionBloc = context.read<CoffeeInteractionBloc>();
  }

  @override
  void dispose() {
    // ignore: lines_longer_than_80_chars
    if (_controller.text.isNotEmpty && _coffeeInteractionBloc.state is CommentIsGettingInput) {
      _coffeeInteractionBloc.add(
        CommentChanged(
          comment: _controller.text,
          coffee: widget.coffee,
        ),
      );
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocBuilder<CoffeeInteractionBloc, CoffeeInteractionState>(
      builder: (context, state) {
        // ignore: lines_longer_than_80_chars
        final storing = state is CommentIsGettingInput || state is RatingSubmissionInProgress;
        return PopScope(
          canPop: storing == false,
          child: Semantics(
            label: context.l10n.lovelyCoffeePicAppBarTitle,
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  context.l10n.lovelyCoffeePicAppBarTitle,
                ),
                leading: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: storing
                      ? const CircularProgressIndicator.adaptive()
                      : IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.chevron_left,
                            color: Colors.brown[900],
                          ),
                        ),
                ),
                actions: [
                  IconButton(
                    key: const Key('favoriteIcon'),
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      Icons.star,
                      color: _isFavorite ? Colors.amber : Colors.brown[100],
                    ),
                  ),
                ],
              ),
              body: MultiBlocListener(
                listeners: [
                  BlocListener<CoffeeInteractionBloc, CoffeeInteractionState>(
                    listener: (context, state) {
                      var message = '';
                      if (state is CommentSubmissionSuccess) {
                        message = context.l10n.commentSavedSnackbarMessage;
                      } else if (state is CommentSubmissionFailure) {
                        message = context.l10n.commentingFailedSnackbarMessage;
                      } else if (state is RatingSubmissionFailure) {
                        message = '${context.l10n.ratingFailedSnackbarMessage}.';
                      }
                      // ignore: lines_longer_than_80_chars
                      if (state is! CommentSubmissionInProgress &&
                          state is! RatingSubmissionInProgress &&
                          message.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      }
                    },
                  ),
                  BlocListener<FavoritesBloc, FavoritesState>(
                    listener: (context, state) {
                      // ignore: lines_longer_than_80_chars
                      if (state is FavoritingSuccess || state is UnfavoritingSuccess) {
                        setState(() => _isFavorite = !_isFavorite);
                      }
                      // ignore: lines_longer_than_80_chars, unrelated_type_equality_checks
                      else if (state is FavoritingFailure && state.failure == ItemAlreadySaved) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            key: const Key('already'),
                            content: Text(
                              context.l10n.alreadyInFavoritesSnackbarMessage,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CoffeeCard(
                          coffee: widget.coffee,
                          shouldShowRating: true,
                          onTap: widget.onTap,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.commentLabel,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _controller,
                          maxLines: 5,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            hintText: context.l10n.commentHintText,
                          ),
                          onChanged: (value) {
                            context.read<CoffeeInteractionBloc>().add(
                                  CommentChanged(
                                    comment: value,
                                    coffee: widget.coffee,
                                  ),
                                );
                          },
                        ),
                        SizedBox(height: size.height * 0.2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _toggleFavorite() {
    context.read<FavoritesBloc>().add(
          _isFavorite ? UnfavoritedCoffee() : FavoritedCoffee(),
        );
  }
}
