import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/data/data.dart';
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
  late final DetailsBloc _bloc;

  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.coffee.comment ?? '');
    _bloc = DetailsBloc(
      commentCoffee: sl.get<CommentCoffee>(),
      rateCoffee: sl.get<RateCoffee>(),
      favoriteCoffee: sl.get<SaveCoffeeToFavorites>(),
      unfavoriteCoffee: sl.get<RemoveCoffeeFromFavorites>(),
      initialCoffee: widget.coffee,
      historyListBloc: widget.historyListBloc,
      favoritesListBloc: widget.favoritesListBloc,
    );
    _isFavorite = widget.coffee.isFavorite;
  }

  @override
  void dispose() {
    if (_controller.text.isNotEmpty) _bloc.add(SubmitComment());
    _controller.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MultiBlocProvider(
      providers: [
        BlocProvider<DetailsBloc>.value(value: _bloc),
        BlocProvider<CoffeeCardListBloc>.value(value: widget.historyListBloc),
      ],
      child: Scaffold(
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
        body: BlocListener<DetailsBloc, DetailsState>(
          listener: (context, state) {
            if (state is CommentSubmissionSuccess || state is RatingSubmissionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Success!')),
              );
            } else if (state is CommentSubmissionFailure || state is RatingSubmissionFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed: ${_getFailureMessage(state)}')),
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
                      _bloc.add(CommentChanged(comment: value));
                    },
                  ),
                  SizedBox(height: size.height * 0.2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (_isFavorite) {
      _bloc.add(FavoritedCoffee());
    } else {
      _bloc.add(UnfavoritedCoffee());
    }
  }

  String _getFailureMessage(DetailsState state) {
    if (state is CommentSubmissionFailure) {
      return 'Comment saving failed.';
    } else if (state is RatingSubmissionFailure) {
      return 'Rating saving failed.';
    }
    return 'Unknown error';
  }
}
