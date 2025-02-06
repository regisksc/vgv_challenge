import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class CoffeeCardListWidget extends StatelessWidget {
  const CoffeeCardListWidget({
    required this.title,
    this.onReturning,
    super.key,
  });
  final String title;
  final Function? onReturning;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoffeeCardListBloc, CoffeeCardListState>(
      builder: (context, state) {
        if (state is CoffeeCardListLoading) {
          return const _CoffeeCardListLoadingWidget();
        } else if (state is CoffeeCardListLoaded) {
          return _ListLoadedContainerWidget(state, onReturning);
        } else if (state is CoffeeCardListFailedLoading) {
          return _ListFailedLoadingContainerWidget(state.failure);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class _ListFailedLoadingContainerWidget extends StatelessWidget {
  const _ListFailedLoadingContainerWidget(this.failure);
  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final appBarHeight = AppBar().preferredSize.height;
    return SliverToBoxAdapter(
      child: Container(
        height: size.height - appBarHeight,
        width: size.width,
        color: Colors.brown[200],
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              () {
                // ignore: lines_longer_than_80_chars
                const noItemsMessage =
                    // ignore: lines_longer_than_80_chars
                    'No favorites yet. Tap on a card and then a star and it will appear here.';
                const unexpectedMessage = 'Oops... Something went wrong.';
                if (failure is ReadingFromEmptyFailure) return noItemsMessage;
                return unexpectedMessage;
              }(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.brown[500],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ListLoadedContainerWidget extends StatelessWidget {
  const _ListLoadedContainerWidget(this.state, this.onReturning);
  final CoffeeCardListLoaded state;
  final Function? onReturning;

  @override
  Widget build(BuildContext context) {
    if (state.list.isEmpty) {
      return const SliverToBoxAdapter(
        child: ColoredBox(
          color: Colors.white70,
          child: Center(
            child: Text('No coffees found.'),
          ),
        ),
      );
    }
    return CoffeeCardListSliverWidget(
      coffees: state.list,
      onReturning: onReturning,
    );
  }
}

class _CoffeeCardListLoadingWidget extends StatelessWidget {
  const _CoffeeCardListLoadingWidget();

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
  const CoffeeCardListSliverWidget({
    required this.coffees,
    this.onReturning,
    super.key,
  });

  final List<Coffee> coffees;
  final Function? onReturning;

  @override
  Widget build(BuildContext context) {
    final isHistory = coffees.length == StorageConstants.historyLimit;
    final indexOffset = isHistory ? 1 : 0;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final coffee = coffees[index + indexOffset];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CoffeeCard(
              coffee: coffee,
              onTap: () => context.read<NavigationBloc>().add(
                    NavigateTo(
                      routeName: AppRoutes.details,
                      arguments: coffee,
                    ),
                  ),
            ),
          );
        },
        childCount: coffees.length - indexOffset,
      ),
    );
  }
}
