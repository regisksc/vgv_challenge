import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class HistoryListWidget extends StatelessWidget {
  const HistoryListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryListBloc, HistoryListState>(
      builder: (context, state) {
        if (state is HistoryListLoading) {
          return const HistoryListLoadingWidget();
        } else if (state is HistoryListLoaded) {
          return HistoryListSliverWidget(coffees: state.list);
        } else {
          return const SliverToBoxAdapter(
            child: SizedBox(
              child: Text('Oops... Something went wrong when trying that.'),
            ),
          );
        }
      },
    );
  }
}

class HistoryListLoadingWidget extends StatelessWidget {
  const HistoryListLoadingWidget({
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

class HistoryListSliverWidget extends StatelessWidget {
  const HistoryListSliverWidget({required this.coffees, super.key});

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
