// File: test/core/app_routes_test.dart
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

// Mocks for use cases
class GetHistoryListMock extends Mock implements GetCoffeeList {}

class FetchCoffeeFromRemoteMock extends Mock implements FetchCoffeeFromRemote {}

class FetchCoffeeFromHistoryMock extends Mock implements FetchCoffeeFromHistory {}

class SaveCoffeeToHistoryMock extends Mock implements SaveCoffeeToHistory {}

/// Create a dummy Coffee instance.
Coffee createDummyCoffee() {
  return Coffee(
    id: 'dummy_id',
    imagePath: '/dummy/path/image.jpg',
    seenAt: DateTime(2025),
    comment: 'Dummy comment',
  );
}

/// Helper to pump the route with MultiBlocProvider.
/// This minimizes repeated code.
Future<void> pumpRoute(
  WidgetTester tester, {
  required RouteSettings settings,
  bool includeBlocs = true,
}) async {
  final route = AppRoutes.onGenerateRoute(settings);
  final pageRoute = route as MaterialPageRoute;
  Widget app = MaterialApp(
    home: Builder(builder: pageRoute.builder),
  );
  if (includeBlocs) {
    app = MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<HistoryListBloc>(
            create: (context) => HistoryListBloc(getHistoryList: sl.get<GetCoffeeList>()),
          ),
          BlocProvider<MainScreenBloc>(
            create: (context) => sl.get<MainScreenBloc>(),
          ),
        ],
        child: Builder(builder: pageRoute.builder),
      ),
    );
  }
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

void main() {
  late GetCoffeeList getHistoryListMock;
  late FetchCoffeeFromRemote fetchCoffeeFromRemoteMock;
  late FetchCoffeeFromHistory fetchCoffeeFromHistoryMock;
  late SaveCoffeeToHistory saveCoffeeToHistoryMock;

  setUp(() async {
    getHistoryListMock = GetHistoryListMock();
    fetchCoffeeFromRemoteMock = FetchCoffeeFromRemoteMock();
    fetchCoffeeFromHistoryMock = FetchCoffeeFromHistoryMock();
    saveCoffeeToHistoryMock = SaveCoffeeToHistoryMock();
    TestWidgetsFlutterBinding.ensureInitialized();
    await sl.reset();
    sl
      ..registerSingleton<GetCoffeeList>(getHistoryListMock)
      ..registerSingleton<FetchCoffeeFromRemote>(fetchCoffeeFromRemoteMock)
      ..registerSingleton<FetchCoffeeFromHistory>(fetchCoffeeFromHistoryMock)
      ..registerSingleton<SaveCoffeeToHistory>(saveCoffeeToHistoryMock)
      ..registerSingleton(
        HistoryListBloc(getHistoryList: getHistoryListMock),
      )
      ..registerSingleton<MainScreenBloc>(
        MainScreenBloc(
          apiFetchCoffee: sl.get<FetchCoffeeFromRemote>(),
          localFetchCoffee: sl.get<FetchCoffeeFromHistory>(),
          saveCoffeeToHistory: sl.get<SaveCoffeeToHistory>(),
          historyListBloc: sl.get<HistoryListBloc>(),
        ),
      );

    final dummyCoffee = Coffee(
      id: 'dummy_id',
      imagePath: '/dummy/path/image.jpg',
      seenAt: DateTime.now().subtract(const Duration(minutes: 5)),
      comment: 'Test comment',
      rating: CoffeeRating.threeStars,
    );

    when(() => fetchCoffeeFromRemoteMock()).thenAnswer((_) async => Result.success(dummyCoffee));

    when(() => fetchCoffeeFromHistoryMock()).thenAnswer((_) async => Result.success(dummyCoffee));

    when(() => saveCoffeeToHistoryMock(dummyCoffee)).thenAnswer((_) async => const Result.success(null));

    when(() => getHistoryListMock()).thenAnswer((_) async => Result.success([dummyCoffee]));

    await setUpTestHive();
    final box = await Hive.openBox<String>('coffee_box');
    sl.registerSingleton<Box<String>>(box);
  });

  tearDown(() async {
    await tearDownTestHive();
    await sl.reset();
  });

  group('onGenerateRoute', () {
    testWidgets(
      'returns MainScreen for AppRoutes.main',
      (WidgetTester tester) async {
        // Arrange & Act
        await pumpRoute(
          tester,
          settings: const RouteSettings(name: AppRoutes.main),
        );
        // Assert
        expect(find.byType(MainScreen), findsOneWidget);
      },
    );

    testWidgets(
      'returns Scaffold for details route when coffee is null',
      (WidgetTester tester) async {
        // Arrange & Act
        await pumpRoute(
          tester,
          settings: const RouteSettings(name: AppRoutes.details),
        );
        // Assert
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(DetailsScreen), findsNothing);
      },
    );

    testWidgets(
      'returns DetailsScreen for details route when coffee is provided',
      (WidgetTester tester) async {
        // Arrange
        final dummyCoffee = createDummyCoffee();
        // Act
        await pumpRoute(
          tester,
          settings: RouteSettings(
            name: AppRoutes.details,
            arguments: dummyCoffee,
          ),
        );
        // Assert
        expect(find.byType(DetailsScreen), findsOneWidget);
      },
    );

    testWidgets(
      'returns FavoritesScreen for AppRoutes.favorites',
      (WidgetTester tester) async {
        // Arrange & Act
        await pumpRoute(
          tester,
          settings: const RouteSettings(name: AppRoutes.favorites),
        );
        // Assert
        expect(find.byType(FavoritesScreen), findsOneWidget);
      },
    );

    testWidgets(
      'returns "Route Not Found" for unknown route',
      (WidgetTester tester) async {
        // Arrange & Act
        await pumpRoute(
          tester,
          settings: const RouteSettings(name: '/unknown'),
        );
        // Assert
        expect(find.text('Route Not Found'), findsOneWidget);
      },
    );
  });
}
