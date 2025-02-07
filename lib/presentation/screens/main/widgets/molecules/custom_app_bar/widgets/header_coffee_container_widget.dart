import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class HeaderCoffeeContainerWidget extends StatelessWidget {
  const HeaderCoffeeContainerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: BlocBuilder<MainScreenBloc, MainScreenState>(
        builder: (context, state) {
          if (state is MainScreenLoading) {
            return Shimmer.fromColors(
              key: const ValueKey('shimmer'),
              baseColor: Colors.brown[300]!,
              highlightColor: Colors.brown[100]!,
              period: const Duration(milliseconds: 500),
              direction: ShimmerDirection.ttb,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.brown[300],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
              ),
            );
          } else if (state is MainScreenLoaded) {
            final file = state.coffee.asFile;
            if (file.existsSync()) {
              return Image.file(
                file,
                key: const ValueKey('headerPhoto'),
                fit: BoxFit.fill,
              );
            } else {
              return Center(
                child: Text(
                  context.l10n.imageNotAvailableText,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.brown[900]),
                ),
              );
            }
          }
          return Container(color: Colors.brown[300]);
        },
      ),
    );
  }
}
