import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class NavigationListenerWidget extends StatelessWidget {
  const NavigationListenerWidget({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (innerContext) => BlocListener<NavigationBloc, NavigationState>(
        listener: (blocContext, state) {
          if (state is NavigationRequested) {
            Navigator.pushNamed(
              innerContext,
              state.routeName,
              arguments: state.arguments,
            );
            
          }
        },
        child: child,
      ),
    );
  }
}
