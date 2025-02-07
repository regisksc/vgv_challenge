import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.brown[200],
        appBar: AppBar(
          leading: IconButton(
            key: const ValueKey('FavoritesScreenBackButton'),
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.chevron_left,
              color: Colors.brown[900],
            ),
          ),
          title: Text(context.l10n.favoriteCoffeesScreenTitle),
        ),
        body: CustomScrollView(
          slivers: [
            CoffeeCardListWidget(
              key: const ValueKey(StorageConstants.favoritesKey),
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
