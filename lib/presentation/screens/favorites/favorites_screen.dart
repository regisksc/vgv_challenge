import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.brown[200],
        appBar: AppBar(
          title: const Text('Favorite coffees'),
        ),
        body: CustomScrollView(
          slivers: [
            CoffeeCardListWidget(
              isHistory: false,
              onReturning: () {
                context.read<CoffeeCardListBloc>().add(LoadCoffeeCardList());
              },
            ),
          ],
        ),
      ),
    );
  }
}
