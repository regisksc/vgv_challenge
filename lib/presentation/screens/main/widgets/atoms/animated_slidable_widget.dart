import 'package:flutter/material.dart';

class AnimatedSlidableWidget extends StatelessWidget {
  const AnimatedSlidableWidget({
    required this.child,
    required this.animationValue,
    super.key,
    this.slideLeft = true,
  });
  final Widget child;
  final double animationValue;
  final bool slideLeft;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hPadding = animationValue < 0.03 ? size.shortestSide * .05 : 0;
    // ignore: lines_longer_than_80_chars
    final left =
        animationValue < 0.03 ? Alignment.centerLeft : Alignment.center;
    // ignore: lines_longer_than_80_chars
    final right =
        animationValue < 0.03 ? Alignment.bottomRight : Alignment.bottomCenter;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      padding: EdgeInsets.symmetric(horizontal: hPadding * 1.0),
      alignment: slideLeft ? left : right,
      child: AnimatedOpacity(
        // ignore: lines_longer_than_80_chars
        opacity: (animationValue < 0.1)
            ? (1 - (animationValue / 0.1)).clamp(0.0, 1.0)
            : 0.0,
        duration: const Duration(milliseconds: 400),
        child: child,
      ),
    );
  }
}
