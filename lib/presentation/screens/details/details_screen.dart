import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  bool _isFavorite = false;
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
    if (_controller.text.isNotEmpty) {
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
              color: _isFavorite ? Colors.amber : Colors.brown[100],
            ),
          ),
        ],
      ),
      body: BlocListener<CoffeeInteractionBloc, CoffeeInteractionState>(
        listener: (context, state) {
          var message = 'Oops. Something went wrong!';
          if (state is CommentSubmissionSuccess) {
            message = 'Comment saved.';
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
                  shouldShowRating: true,
                  onTap: widget.onTap,
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
