import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

typedef DetailsRouteParams = ({
  Coffee coffee,
  CoffeeCardListBloc favoritesBloc,
  CoffeeCardListBloc historyBloc,
});

class AppRoutes {
  static const String details = '/details';
  static const String favorites = '/favorites';

  static Route<MaterialPageRoute<dynamic>> onGenerateRoute(
    RouteSettings settings,
  ) {
    switch (settings.name) {
      case details:
        final args = settings.arguments as Coffee?;
        return _buildDetailsRoute(args);
      case favorites:
        return _buildFavoritesRoute();
      default:
        const message = 'Route Not Found';
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text(message)),
          ),
        );
    }
  }

  static MaterialPageRoute<MaterialPageRoute<dynamic>> _buildFavoritesRoute() {
    return MaterialPageRoute(
      builder: (context) {
        return BlocProvider(
          create: (_) => CoffeeCardListBloc(
            getList: sl.get<GetCoffeeList>(
              instanceName: StorageConstants.favoritesKey,
            ),
          )..add(LoadCoffeeCardList()),
          child: const FavoritesScreen(),
        );
      },
    );
  }

  static MaterialPageRoute<MaterialPageRoute<dynamic>> _buildDetailsRoute(
    Coffee? coffee,
  ) {
    return MaterialPageRoute(
      builder: (context) {
        if (coffee == null) return const Scaffold();
        return BlocProvider<FavoritesBloc>(
          create: (_) => FavoritesBloc(
            coffee: coffee,
            saveCoffee: sl<SaveCoffee>(instanceName: 'saveFavorite'),
            unfavoriteCoffee: sl<Unfavorite>(),
          ),
          child: DetailsScreen(coffee: coffee),
        );
      },
    );
  }
}
