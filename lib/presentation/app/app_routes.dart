import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class AppRoutes {
  static const String main = '/';
  static const String details = '/details';
  static const String favorites = '/favorites';

  static Route<MaterialPageRoute<dynamic>> onGenerateRoute(
    RouteSettings settings,
  ) {
    switch (settings.name) {
      case main:
        return MaterialPageRoute(builder: (_) =>  MainScreen());
      case details:
        final args = settings.arguments as ({
          Coffee coffee,
          CoffeeCardListBloc historyBloc,
          CoffeeCardListBloc favoritesBloc,
        })?;

        return MaterialPageRoute(
          builder: (context) => () {
            if (args == null) return const Scaffold();
            return DetailsScreen(
              coffee: args.coffee,
              historyListBloc: args.historyBloc,
              favoritesListBloc: args.favoritesBloc,
            );
          }(),
        );
      case favorites:
        return MaterialPageRoute(
          builder: (context) {
            return BlocProvider(
              create: (_) => CoffeeCardListBloc(
                getList: sl.get<GetCoffeeList>(instanceName: 'favorites'),
              )..add(LoadCoffeeCardList()),
              child: const FavoritesScreen(),
            );
          },
        );
      default:
        const message = 'Route Not Found';
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text(message))),
        );
    }
  }
}
