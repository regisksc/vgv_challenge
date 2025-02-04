import 'package:flutter/material.dart';
import 'package:vgv_challenge/domain/domain.dart';

class CoffeeCommentOverlayWidget extends StatelessWidget {
  const CoffeeCommentOverlayWidget({
    required this.coffee,
    required this.height,
    super.key,
  });

  final Coffee coffee;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (coffee.comment == null) return const SizedBox.shrink();

    return Builder(
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(
            left: 12,
            right: 12,
            top: 8,
            bottom: 20,
          ),
          height: height,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              center: Alignment.topCenter,
              radius: 1.5,
              colors: [Colors.black12, Colors.black],
              stops: [0.3, 8],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            coffee.comment ?? '',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}
