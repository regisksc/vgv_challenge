import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({
    required this.coffee,
    required this.historyListBloc,
    super.key,
  });
  final Coffee coffee;
  final CoffeeCardListBloc historyListBloc;
  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late final TextEditingController _controller;
  late final DetailsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.coffee.comment ?? '');
    _bloc = DetailsBloc(
      commentCoffee: sl.get<CommentCoffee>(),
      initialCoffee: widget.coffee,
      historyListBloc: widget.historyListBloc,
    );
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
              onPressed: () {},
              icon: Icon(
                Icons.star,
                // ignore: lines_longer_than_80_chars
                color: widget.coffee.isFavorite ? Colors.brown[100] : Colors.brown[650],
              ),
            ),
          ],
        ),
        body: BlocListener<DetailsBloc, DetailsState>(
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(() {
                  final isCurrent = ModalRoute.of(context)?.isCurrent;
                  final successState = state is CommentSubmissionSuccess;
                  final saved = successState && (isCurrent ?? false);
                  return saved ? 'Comment saved' : 'Oops! Something wrong';
                }()),
              ),
            );
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
}
