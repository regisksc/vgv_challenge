import 'package:flutter/material.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class CoffeeCard extends StatelessWidget {
  const CoffeeCard({
    required this.coffee,
    super.key,
    this.onTap,
    this.enableTimeAgoTimer = true,
    this.shouldShowRating,
  });

  final Coffee coffee;
  final bool enableTimeAgoTimer;
  final bool? shouldShowRating;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const height = 400.0;
    return GestureDetector(
      key: const Key('coffeeCard'),
      onTap: onTap,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            CoffeeBackgroundWidget(coffee: coffee, height: height),
            Positioned(
              left: 16,
              top: 16,
              child: CoffeeTimeAgoWidget(
                date: coffee.seenAt,
                enableTimeAgoTimer: enableTimeAgoTimer,
              ).overBlackBackground(),
            ),
            Positioned(
              right: 16,
              top: 16,
              child: Visibility(
                // ignore: lines_longer_than_80_chars
                visible: shouldShowRating ?? coffee.rating != CoffeeRating.unrated,
                child: CoffeeRatingWidget(coffee: coffee),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CoffeeCommentOverlayWidget(coffee: coffee, height: height),
            ),
          ],
        ),
      ),
    );
  }
}
