import 'package:flutter/material.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/l10n/l10n.dart';

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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: isVisible
          ? Image.file(
              coffee.asFile,
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width * 0.9,
              height: height,
            )
          : Center(
              child: Text(context.l10n.imageNotAvailableText),
            ),
    );
  }
}
