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
  static const String main = '/';
  static const String details = '/details';
  static const String favorites = '/favorites';

  static Route<MaterialPageRoute<dynamic>> onGenerateRoute(
    RouteSettings settings,
  ) {
    switch (settings.name) {
      case main:
        return _buildMainRoute();
      case details:
        final args = settings.arguments as ({
          Coffee coffee,
          CoffeeCardListBloc historyBloc,
          CoffeeCardListBloc favoritesBloc,
        })?;
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

  static MaterialPageRoute<MaterialPageRoute<dynamic>> _buildMainRoute() {
    return MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => CoffeeCardListBloc(
              getList: sl.get<GetCoffeeList>(instanceName: 'history'),
            )..add(LoadCoffeeCardList()),
          ),
          BlocProvider<CoffeeInteractionBloc>(
            create: (_) => CoffeeInteractionBloc(
              commentCoffee: sl.get<UpdateCoffee>(
                instanceName: 'comment',
              ),
              rateCoffee: sl.get<UpdateCoffee>(
                instanceName: 'rating',
              ),
            ),
          ),
        ],
        child: MainScreen(),
      ),
    );
  }

  static MaterialPageRoute<MaterialPageRoute<dynamic>> _buildFavoritesRoute() {
    return MaterialPageRoute(
      builder: (context) {
        return BlocProvider(
          create: (_) => CoffeeCardListBloc(
            getList: sl.get<GetFavoriteCoffeeList>(
              instanceName: 'favorites',
            ),
          )..add(LoadCoffeeCardList()),
          child: const FavoritesScreen(),
        );
      },
    );
  }

  static MaterialPageRoute<MaterialPageRoute<dynamic>> _buildDetailsRoute(
    DetailsRouteParams? args,
  ) {
    return MaterialPageRoute(
      builder: (context) {
        if (args == null) return const Scaffold();
        return MultiBlocProvider(
          providers: [
            BlocProvider<CoffeeInteractionBloc>(
              create: (_) => CoffeeInteractionBloc(
                commentCoffee: sl.get<UpdateCoffee>(
                  instanceName: 'commentCoffee',
                ),
                rateCoffee: sl.get<UpdateCoffee>(
                  instanceName: 'rateCoffee',
                ),
              ),
            ),
            BlocProvider<FavoritesBloc>(
              create: (_) => FavoritesBloc(
                coffee: args.coffee,
                saveCoffee: sl.get<SaveCoffee>(
                  instanceName: 'saveFavorite',
                ),
                unfavoriteCoffee: sl.get<Unfavorite>(),
              ),
            ),
          ],
          child: DetailsScreen(
            coffee: args.coffee,
            historyListBloc: args.historyBloc,
            favoritesListBloc: args.favoritesBloc,
          ),
        );
      },
    );
  }
}
