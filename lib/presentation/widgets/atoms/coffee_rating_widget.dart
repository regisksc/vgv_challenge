import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class CoffeeRatingWidget extends StatelessWidget {
  const CoffeeRatingWidget({
    required this.coffee,
    super.key,
    this.canTap = false,
  });

  final Coffee coffee;
  final bool canTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoffeeInteractionBloc, CoffeeInteractionState>(
      builder: (context, state) {
        var ratingIndex = coffee.rating.index;
        if (state is RatingSubmissionSuccess) {
          ratingIndex = state.rating.index;
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final isFilled = index < ratingIndex;
            return GestureDetector(
              onTap: canTap
                  ? () {
                      context.read<CoffeeInteractionBloc>().add(
                            SubmitRating(
                              rating: CoffeeRating.values[index + 1],
                              coffee: coffee,
                            ),
                          );
                    }
                  : null,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.star, size: 25, color: Colors.black54),
                  Icon(
                    Icons.star,
                    size: 22,
                    color: isFilled ? Colors.yellow : Colors.grey,
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
