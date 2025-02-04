import 'package:flutter/material.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class CoffeeCard extends StatelessWidget {
  const CoffeeCard({
    required this.coffee,
    super.key,
    this.enableTimeAgoTimer = true,
  });
  final Coffee coffee;
  final bool enableTimeAgoTimer;

  @override
  Widget build(BuildContext context) {
    const height = 400.0;
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          CoffeeBackgroundWidget(coffee: coffee, height: height),
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: CoffeeTimeAgoWidget(
                date: coffee.seenAt,
                enableTimeAgoTimer: enableTimeAgoTimer,
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 20,
            child: CoffeeRatingWidget(coffee: coffee),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CoffeeCommentOverlayWidget(coffee: coffee, height: height),
          ),
        ],
      ),
    );
  }
}
