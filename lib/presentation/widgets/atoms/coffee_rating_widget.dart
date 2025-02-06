import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class CoffeeRatingWidget extends StatefulWidget {
  const CoffeeRatingWidget({
    required this.coffee,
    super.key,
    this.canTap = false,
  });

  final Coffee coffee;
  final bool canTap;

  @override
  State<CoffeeRatingWidget> createState() => _CoffeeRatingWidgetState();
}

class _CoffeeRatingWidgetState extends State<CoffeeRatingWidget> {
  late int _displayedRatingIndex;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    _displayedRatingIndex = widget.coffee.rating.index;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CoffeeInteractionBloc, CoffeeInteractionState>(
      listenWhen: (previous, current) =>
          current is RatingSubmissionInProgress ||
          current is RatingSubmissionSuccess ||
          current is RatingSubmissionFailure,
      listener: (context, state) {
        if (state is RatingSubmissionInProgress) {
          _dialogOpen = true;
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) => const LoadingDialog(),
          );
        } else if (state is RatingSubmissionSuccess) {
          if (_dialogOpen) {
            Navigator.of(context, rootNavigator: true).pop();
            _dialogOpen = false;
          }
          setState(() => _displayedRatingIndex = state.rating.index);
        } else if (state is RatingSubmissionFailure) {
          if (_dialogOpen) {
            Navigator.of(context, rootNavigator: true).pop();
            _dialogOpen = false;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rating failed')),
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final isFilled = index < _displayedRatingIndex;
          return GestureDetector(
            onTap: () => _handleTap(index),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.star, size: 25, color: Colors.black54),
                Icon(
                  Icons.star,
                  size: 22,
                  color: isFilled ? Colors.amber : Colors.brown[100],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _handleTap(int index) {
    context.read<CoffeeInteractionBloc>().add(
          SubmitRating(
            coffee: widget.coffee,
            rating: CoffeeRating.values[index + 1],
          ),
        );
  }
}
