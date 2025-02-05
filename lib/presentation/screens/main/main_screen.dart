import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

// ignore: must_be_immutable
class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  MainScreenLoaded? _cachedState;

  @override
  Widget build(BuildContext context) {
    return BlocListener<MainScreenBloc, MainScreenState>(
      listener: (context, state) {
        if (state is MainScreenLoaded) _cachedState = state;
        if (state is IsNavigating) {
          Navigator.pushNamed(
            context,
            state.destination,
            arguments: (
              coffee: state.coffee,
              historyBloc: context.read<CoffeeCardListBloc>(),
              favoritesBloc: context.read<CoffeeCardListBloc>(),
            ),
          ).then((_) {
            if (context.mounted) {
              context.read<MainScreenBloc>().add(
                    _cachedState == null
                        ? FetchRandomCoffee()
                        : ReloadLoadedImage(
                            coffee: _cachedState!.coffee,
                          ),
                  );
            }
          });
        }
      },
      child: const MainScreenContentWidget(),
    );
  }
}
