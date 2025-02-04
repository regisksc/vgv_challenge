import 'package:flutter/material.dart';
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
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case details:
        final coffee = settings.arguments as Coffee?;
        return MaterialPageRoute(
          builder: (_) => () {
            if (coffee == null) return const Scaffold();
            return DetailsScreen(coffee: coffee);
          }(),
        );
      case favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route Not Found')),
          ),
        );
    }
  }
}
