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

class GetHistoryListMock extends Mock implements GetCoffeeList {}

class GetFavoritesListMock extends Mock implements GetCoffeeList {}

class FetchCoffeeFromRemoteMock extends Mock implements FetchCoffeeFromRemote {}

class FetchCoffeeFromHistoryMock extends Mock implements FetchCoffeeFromHistory {}

class SaveCoffeeToHistoryMock extends Mock implements SaveCoffeeToHistory {}

class CommentCoffeeMock extends Mock implements CommentCoffee {}

Coffee createDummyCoffee() => Coffee(
      id: 'dummy_id',
      imagePath: '/dummy/path/image.jpg',
      seenAt: DateTime(2025),
      comment: 'Dummy comment',
    );

Future<void> pumpRoute(WidgetTester tester, {required RouteSettings settings}) async {
  final route = AppRoutes.onGenerateRoute(settings);
  final pageRoute = route as MaterialPageRoute;

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<CoffeeCardListBloc>(
          create: (context) => sl.get<CoffeeCardListBloc>(),
        ),
        BlocProvider<MainScreenBloc>(
          create: (context) => sl.get<MainScreenBloc>(),
        ),
      ],
      child: MaterialApp(home: Builder(builder: pageRoute.builder)),
    ),
  );
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

void main() {
  late GetCoffeeList getFavoritesListMock;
  late GetCoffeeList getHistoryListMock;
  late FetchCoffeeFromRemote fetchCoffeeFromRemoteMock;
  late FetchCoffeeFromHistory fetchCoffeeFromHistoryMock;
  late SaveCoffeeToHistory saveCoffeeToHistoryMock;
  late CommentCoffee commentCoffeeMock;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await sl.reset();

    getFavoritesListMock = GetFavoritesListMock();
    getHistoryListMock = GetHistoryListMock();
    fetchCoffeeFromRemoteMock = FetchCoffeeFromRemoteMock();
    fetchCoffeeFromHistoryMock = FetchCoffeeFromHistoryMock();
    saveCoffeeToHistoryMock = SaveCoffeeToHistoryMock();
    commentCoffeeMock = CommentCoffeeMock();

    await setUpTestHive();
    final box = await Hive.openBox<String>('coffee_box');

    sl
      ..registerSingleton<Box<String>>(box)
      ..registerSingleton<GetCoffeeList>(getFavoritesListMock, instanceName: 'favorites')
      ..registerSingleton<GetCoffeeList>(getHistoryListMock, instanceName: 'history')
      ..registerSingleton<FetchCoffeeFromRemote>(fetchCoffeeFromRemoteMock)
      ..registerSingleton<FetchCoffeeFromHistory>(fetchCoffeeFromHistoryMock)
      ..registerSingleton<SaveCoffeeToHistory>(saveCoffeeToHistoryMock)
      ..registerSingleton<CommentCoffee>(commentCoffeeMock)
      ..registerSingleton(CoffeeCardListBloc(getList: getHistoryListMock))
      ..registerSingleton(
        MainScreenBloc(
          apiFetchCoffee: fetchCoffeeFromRemoteMock,
          localFetchCoffee: fetchCoffeeFromHistoryMock,
          saveCoffeeToHistory: saveCoffeeToHistoryMock,
          historyListBloc: sl.get<CoffeeCardListBloc>(),
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
    when(() => commentCoffeeMock(any())).thenAnswer((_) async => const Result.success(null));
  });

  tearDown(() async {
    await tearDownTestHive();
    await sl.reset();
  });

  group('AppRoutes', () {
    testWidgets('renders MainScreen for root route', (tester) async {
      await pumpRoute(tester, settings: const RouteSettings(name: AppRoutes.main));
      expect(find.byType(MainScreen), findsOneWidget);
    });

    testWidgets('renders DetailsScreen with valid arguments', (tester) async {
      final historyBloc = sl.get<CoffeeCardListBloc>();
      await pumpRoute(
        tester,
        settings: RouteSettings(
          name: AppRoutes.details,
          arguments: (
            coffee: createDummyCoffee(),
            historyBloc: historyBloc,
          ),
        ),
      );
      expect(find.byType(DetailsScreen), findsOneWidget);
    });

    testWidgets('renders fallback for invalid details route', (tester) async {
      await pumpRoute(tester, settings: const RouteSettings(name: AppRoutes.details));
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
