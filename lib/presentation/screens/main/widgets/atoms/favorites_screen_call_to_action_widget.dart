import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class FavoritesScreenCallToActionWidget extends StatelessWidget {
  const FavoritesScreenCallToActionWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const ValueKey('FavoritesScreenCallToActionWidget'),
      onTap: () => context.read<NavigationBloc>().add(
            NavigateTo(
              routeName: AppRoutes.favorites,
              onComplete: () {
                if (context.mounted) {
                  context.read<CoffeeCardListBloc>().add(
                        LoadCoffeeCardList(),
                      );
                }
              },
            ),
          ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.brown[200],
          borderRadius: BorderRadius.circular(10),
        ),
        width: 130,
        child: Text(
          context.l10n.myFavoritesButtonText,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 12,
            color: facebookColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
