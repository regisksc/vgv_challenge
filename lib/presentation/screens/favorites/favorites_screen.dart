import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CoffeeCardListBloc(
        getList: sl.get<GetCoffeeList>(instanceName: 'favorites'),
      )..add(LoadCoffeeCardList()),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Favorite coffees'),
          ),
          body: const CustomScrollView(
            slivers: [CoffeeCardListWidget(title: '')],
          ),
        ),
      ),
    );
  }
}
