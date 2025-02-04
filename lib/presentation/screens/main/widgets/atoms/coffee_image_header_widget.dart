import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class CoffeeImageHeaderWidget extends StatelessWidget {
  const CoffeeImageHeaderWidget({
    required this.animationValue,
    super.key,
  });

  final double animationValue;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Animated coffee image
        BlocBuilder<MainScreenBloc, MainScreenState>(
          builder: (context, state) {
            if (state is! MainScreenLoaded) {
              return Container(color: Colors.brown[300]);
            }

            return AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              padding: EdgeInsets.all(8.0 * animationValue),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16 * (1 + animationValue)),
                child: Transform.translate(
                  offset: Offset(0, -50 * animationValue),
                  child: Transform.scale(
                    scale: 1 - (0.5 * animationValue),
                    child: Image.file(
                      state.coffee.asFile,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // Refresh button
        Positioned(
          right: 16,
          top: 16 + (40 * animationValue),
          child: RefreshButton(animationValue: animationValue),
        ),
      ],
    );
  }
}

class RefreshButton extends StatelessWidget {
  const RefreshButton({
    required this.animationValue,
    super.key,
  });

  final double animationValue;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainScreenBloc, MainScreenState>(
      builder: (context, state) {
        return AnimatedOpacity(
          opacity: 1 - animationValue,
          duration: const Duration(milliseconds: 200),
          child: IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<MainScreenBloc>().add(RefreshRandomCoffee());
            },
          ),
        );
      },
    );
  }
}
