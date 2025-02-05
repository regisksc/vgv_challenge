import 'package:flutter/material.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class CoffeeBookLogoWidget extends StatelessWidget {
  const CoffeeBookLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 30,
      decoration: BoxDecoration(
        color: facebookColor,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: const FittedBox(
        child: Text(
          'Coffeebook',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }
}
