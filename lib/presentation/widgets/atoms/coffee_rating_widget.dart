import 'package:flutter/material.dart';
import 'package:vgv_challenge/domain/domain.dart';

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final isFilled = index < coffee.rating.index;
        return GestureDetector(
          onTap: () => debugPrint('Tapped on star $index'),
          child: Stack(
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
  }
}
