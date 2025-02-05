import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({
    required this.coffee,
    required this.historyListBloc,
    required this.favoritesListBloc,
    super.key,
  });

  final Coffee coffee;
  final CoffeeCardListBloc historyListBloc;
  final CoffeeCardListBloc favoritesListBloc;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late final TextEditingController _controller;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.coffee.comment ?? '');
    _isFavorite = widget.coffee.isFavorite;
  }

  @override
  void dispose() {
    if (_controller.text.isNotEmpty) {
      context.read<CoffeeInteractionBloc>().add(
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lovely coffee pic'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.chevron_left, color: Colors.brown[900]),
        ),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              Icons.star,
              color: _isFavorite ? Colors.amber : Colors.grey,
            ),
          ),
        ],
      ),
      body: BlocListener<CoffeeInteractionBloc, CoffeeInteractionState>(
        listener: (context, state) {
          var message = 'Oops. Something went wrong!';
          if (state is CommentSubmissionSuccess) {
            message = 'Comment saved.';
          } else if (state is RatingSubmissionSuccess) {
            message = 'Rating saved.';
          } else if (state is CommentSubmissionFailure) {
            message = 'Commenting failed.';
          } else if (state is RatingSubmissionFailure) {
            message = 'Rating failed.';
          }
          // ignore: lines_longer_than_80_chars
          if (state is! CommentSubmissionInProgress && state is! RatingSubmissionInProgress) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CoffeeCard(
                  coffee: widget.coffee,
                  shouldNavigate: false,
                  shouldShowRating: true,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Comment',
                  style: TextStyle(
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
                    hintText: 'Type your comment here',
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
    );
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    context.read<FavoritesBloc>().add(
          _isFavorite ? FavoritedCoffee() : UnfavoritedCoffee(),
        );
  }
}
