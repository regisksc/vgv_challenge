import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class CoffeeCardListWidget extends StatelessWidget {
  const CoffeeCardListWidget({
    this.onReturning,
    this.isHistory = true,
    super.key,
  });
  final Function? onReturning;
  final bool isHistory;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoffeeCardListBloc, CoffeeCardListState>(
      builder: (context, state) {
        if (state is CoffeeCardListLoading) {
          return const _CoffeeCardListLoadingWidget();
        } else if (state is CoffeeCardListLoaded) {
          return state.list.isNotEmpty
              ? _ListLoadedContainerWidget(
                  state,
                  onReturning,
                  isHistory: isHistory,
                )
              : _ListFailedLoadingContainerWidget(ReadingFromEmptyFailure());
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
      child: SizedBox(
        height: size.height - appBarHeight,
        width: size.width,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.brown.withValues(alpha: 0.4),
                      Colors.brown.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * .2),
                child: Text(
                  () {
                    const noItemsMessage = 'No favorites yet. Tap on a card, star it and it will appear here.';
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
          ],
        ),
      ),
    );
  }
}

class _ListLoadedContainerWidget extends StatelessWidget {
  const _ListLoadedContainerWidget(
    this.state,
    this.onReturning, {
    required this.isHistory,
  });
  final CoffeeCardListLoaded state;
  final Function? onReturning;
  final bool isHistory;

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
    return _CoffeeCardListSliverWidget(
      coffees: state.list,
      onReturning: onReturning,
      isHistory: isHistory,
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

class _CoffeeCardListSliverWidget extends StatelessWidget {
  const _CoffeeCardListSliverWidget({
    required this.coffees,
    required this.isHistory,
    this.onReturning,
  });

  final List<Coffee> coffees;
  final Function? onReturning;
  final bool isHistory;

  @override
  Widget build(BuildContext context) {
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
