// File: test/core/app_routes_test.dart

// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

void main() {
  Coffee createDummyCoffee() {
    return Coffee(
      id: 'dummy_id',
      imagePath: '/dummy/path/image.jpg',
      seenAt: DateTime(2025),
      comment: 'Dummy comment',
    );
  }

  testWidgets('onGenerateRoute returns MainScreen for AppRoutes.main', (WidgetTester tester) async {
    // Arrange
    final route = AppRoutes.onGenerateRoute(const RouteSettings(name: AppRoutes.main));
    final pageRoute = route as MaterialPageRoute;

    // Act
    await tester.pumpWidget(MaterialApp(home: Builder(builder: pageRoute.builder)));

    // Assert
    expect(find.byType(MainScreen), findsOneWidget);
  });

  testWidgets('onGenerateRoute returns Scaffold for details route when coffee is null', (WidgetTester tester) async {
    // Arrange
    final route = AppRoutes.onGenerateRoute(
      const RouteSettings(name: AppRoutes.details),
    );
    final pageRoute = route as MaterialPageRoute;

    // Act
    await tester.pumpWidget(MaterialApp(home: Builder(builder: pageRoute.builder)));

    // Assert
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(DetailsScreen), findsNothing);
  });

  testWidgets('onGenerateRoute returns DetailsScreen for details route when coffee is provided',
      (WidgetTester tester) async {
    // Arrange
    final dummyCoffee = createDummyCoffee();
    final route = AppRoutes.onGenerateRoute(
      RouteSettings(name: AppRoutes.details, arguments: dummyCoffee),
    );
    final pageRoute = route as MaterialPageRoute;

    // Act
    await tester.pumpWidget(MaterialApp(home: Builder(builder: pageRoute.builder)));

    // Assert
    expect(find.byType(DetailsScreen), findsOneWidget);
  });

  testWidgets('onGenerateRoute returns FavoritesScreen for AppRoutes.favorites', (WidgetTester tester) async {
    // Arrange
    final route = AppRoutes.onGenerateRoute(const RouteSettings(name: AppRoutes.favorites));
    final pageRoute = route as MaterialPageRoute;

    // Act
    await tester.pumpWidget(MaterialApp(home: Builder(builder: pageRoute.builder)));

    // Assert
    expect(find.byType(FavoritesScreen), findsOneWidget);
  });

  testWidgets('onGenerateRoute returns "Route Not Found" for unknown route', (WidgetTester tester) async {
    // Arrange
    final route = AppRoutes.onGenerateRoute(const RouteSettings(name: '/unknown'));
    final pageRoute = route as MaterialPageRoute;

    // Act
    await tester.pumpWidget(MaterialApp(home: Builder(builder: pageRoute.builder)));

    // Assert
    expect(find.text('Route Not Found'), findsOneWidget);
  });
}
