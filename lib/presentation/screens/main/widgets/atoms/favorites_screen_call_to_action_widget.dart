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
      onTap: () => context.read<MainScreenBloc>().add(
            TapFavoritesCallToAction(),
          ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.brown[200],
          borderRadius: BorderRadius.circular(10),
        ),
        width: 130,
        child: const Text(
          'my favorites',
          textAlign: TextAlign.center,
          maxLines: 1,
          style: TextStyle(
            fontSize: 12,
            color: facebookColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
