import 'package:flutter/material.dart';
import 'package:vgv_challenge/domain/domain.dart';

class CoffeeBackgroundWidget extends StatelessWidget {
  const CoffeeBackgroundWidget({
    required this.coffee,
    required this.height,
    super.key,
  });

  final Coffee coffee;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isVisible = coffee.asFile.existsSync();
    return Visibility(
      visible: isVisible,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          coffee.asFile,
          fit: BoxFit.cover,
          width: MediaQuery.of(context).size.width * 0.9,
          height: height,
        ),
      ),
    );
  }
}
