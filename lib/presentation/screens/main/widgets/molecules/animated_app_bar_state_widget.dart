import 'package:flutter/material.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class AnimatedAppBarStateWidget extends StatelessWidget {
  const AnimatedAppBarStateWidget({
    required this.animationValue,
    required this.leftChild,
    required this.rightChild,
    super.key,
  });

  final double animationValue;
  final Widget leftChild;
  final Widget rightChild;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedSlidableWidget(
            animationValue: animationValue,
            child: leftChild,
          ),
          const Spacer(),
          AnimatedSlidableWidget(
            animationValue: animationValue,
            slideLeft: false,
            child: rightChild,
          ),
        ],
      ),
    );
  }
}
