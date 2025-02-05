import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class CustomAppBarWidget extends StatelessWidget {
  const CustomAppBarWidget({required this.scrollController, super.key});

  final ScrollController scrollController;

  double _calculateAnimationValue({
    required double currentHeight,
    required double expandedHeight,
    required double collapsedHeight,
  }) {
    final range = expandedHeight - collapsedHeight;
    final value = (currentHeight - collapsedHeight) / range;
    return value.clamp(0.0, 1.0);
  }

  void _onNewCoffee(BuildContext context) {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
    final bloc = context.read<MainScreenBloc>();
    if (bloc.state is! MainScreenLoading) {
      bloc.add(RefreshRandomCoffee());
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = _getMaxHeight(screenHeight);
    final minHeight = max(screenHeight * 0.08, kToolbarHeight + 10);

    return SliverAppBar(
      expandedHeight: maxHeight,
      collapsedHeight: minHeight,
      stretch: true,
      pinned: true,
      elevation: 0,
      shadowColor: Colors.brown[300],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(4),
        ),
      ),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final currentHeight = constraints.maxHeight;
          final animationValue = _calculateAnimationValue(
            currentHeight: currentHeight,
            expandedHeight: maxHeight,
            collapsedHeight: minHeight,
          );
          const kMaxMargin = 25.0;
          final margin = kMaxMargin * animationValue;
          return FlexibleSpaceBar(
            title: AnimatedAppBarStateWidget(
              animationValue: animationValue,
              leftChild: const CoffeeBookLogoWidget(),
              rightChild: IconButton.outlined(
                color: Colors.brown[700],
                onPressed: () => _onNewCoffee(context),
                icon: const Icon(
                  Icons.coffee_outlined,
                  size: 20,
                  color: facebookColor,
                ),
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedOpacity(
                  opacity: animationValue,
                  duration: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: margin,
                      vertical: margin,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppBarHeaderSectionWidget(
                          onTapButton: _onNewCoffee,
                          animationValue: animationValue,
                        ),
                        SizedBox(height: margin),
                        const Expanded(child: HeaderCoffeeContainerWidget()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _getMaxHeight(double screenHeight) {
    const smallScreenHeightThreshold = 700.0;
    const largeScreenHeightThreshold = 1000.0;
    const smallScreenHeightFactor = 0.85;
    const largeScreenHeightFactor = 0.6;
    const defaultHeightFactor = 0.7;

    final small = screenHeight * smallScreenHeightFactor;
    final large = screenHeight * largeScreenHeightFactor;

    return switch (screenHeight) {
      _ when screenHeight < smallScreenHeightThreshold => small,
      _ when screenHeight > largeScreenHeightThreshold => large,
      _ => screenHeight * defaultHeightFactor,
    };
  }
}
