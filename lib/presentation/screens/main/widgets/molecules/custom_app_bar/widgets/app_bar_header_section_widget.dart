import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class AppBarHeaderSectionWidget extends StatelessWidget {
  const AppBarHeaderSectionWidget({
    required this.onTapButton,
    required this.animationValue,
    super.key,
  });

  final void Function(BuildContext) onTapButton;
  final double animationValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: HeaderTitleWidget(animationValue: animationValue)),
        const SizedBox(width: 12),
        NewCoffeeButtonWidget(onTapButton: onTapButton),
      ],
    );
  }
}

class HeaderTitleWidget extends StatelessWidget {
  const HeaderTitleWidget({required this.animationValue, super.key});

  final double animationValue;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Trending coffee',
        maxLines: 1,
        style: TextStyle(
          color: Colors.brown[900],
          fontSize: 20 + animationValue,
          fontWeight: FontWeight.bold,
          overflow: TextOverflow.ellipsis,
          height: 1.8,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class NewCoffeeButtonWidget extends StatelessWidget {
  const NewCoffeeButtonWidget({required this.onTapButton, super.key});

  final void Function(BuildContext p1) onTapButton;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainScreenBloc, MainScreenState>(
      builder: (context, state) {
        return AnimatedOpacity(
          opacity: state is! MainScreenLoading ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: FilledButton(
            onPressed: () => onTapButton(context),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.brown[400],
              foregroundColor: Colors.white,
            ),
            child: SizedBox(
              width: 75,
              height: 25,
              child: FittedBox(
                child: Text(
                  'New coffee',
                  style: TextStyle(
                    color: Colors.brown[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
