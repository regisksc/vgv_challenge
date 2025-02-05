import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class CoffeeCardListWidget extends StatelessWidget {
  const CoffeeCardListWidget({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoffeeCardListBloc, CoffeeCardListState>(
      builder: (context, state) {
        if (state is CoffeeCardListLoading) {
          return const CoffeeCardListLoadingWidget();
        } else if (state is CoffeeCardListLoaded) {
          return CoffeeCardListSliverWidget(coffees: state.list);
        } else {
          return const SliverToBoxAdapter(
            child: Scaffold(
              body: ColoredBox(
                color: Colors.white70,
                child: Center(child: Text('Oops... Something went wrong.')),
              ),
            ),
          );
        }
      },
    );
  }
}

class CoffeeCardListLoadingWidget extends StatelessWidget {
  const CoffeeCardListLoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        alignment: Alignment.center,
        height: 50,
        width: 50,
        padding: const EdgeInsets.all(8),
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

class CoffeeCardListSliverWidget extends StatelessWidget {
  const CoffeeCardListSliverWidget({required this.coffees, super.key});

  final List<Coffee> coffees;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final coffee = coffees[index + 1];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CoffeeCard(coffee: coffee),
          );
        },
        childCount: coffees.length - 1,
      ),
    );
  }
}
