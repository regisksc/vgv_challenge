// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

import '../../helpers/mocks.dart';

Coffee createDummyCoffee() => Coffee(
      id: 'dummy_id',
      imagePath: '/dummy/path/image.jpg',
      seenAt: DateTime(2025),
      comment: 'Dummy comment',
    );

Future<void> pumpRoute(
  WidgetTester tester, {
  required RouteSettings settings,
}) async {
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
  late UpdateCoffee commentCoffeeMock;
  late UpdateCoffee rateCoffeeMock;

  late CoffeeCardListBloc favoritesBloc;
  late CoffeeCardListBloc historyBloc;

  late Box<String> box;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await setUpTestHive();
    box = await Hive.openBox<String>('coffee_box');
  });

  tearDownAll(() async {
    await tearDownTestHive();
  });

  setUp(() async {
    await sl.reset();

    getFavoritesListMock = GetFavoritesListMock();
    getHistoryListMock = GetHistoryListMock();
    fetchCoffeeFromRemoteMock = FetchCoffeeFromRemoteMock();
    fetchCoffeeFromHistoryMock = FetchCoffeeFromHistoryMock();
    saveCoffeeToHistoryMock = SaveCoffeeToHistoryMock();
    commentCoffeeMock = CommentCoffeeMock();
    rateCoffeeMock = RateCoffeeMock();

    favoritesBloc = CoffeeCardListBloc(getList: getFavoritesListMock);
    historyBloc = CoffeeCardListBloc(getList: getHistoryListMock);

    sl
      ..registerSingleton<Box<String>>(box)
      ..registerSingleton<GetCoffeeList>(getFavoritesListMock, instanceName: StorageConstants.favoritesKey)
      ..registerSingleton<GetCoffeeList>(getHistoryListMock, instanceName: 'history')
      ..registerSingleton<FetchCoffeeFromRemote>(fetchCoffeeFromRemoteMock)
      ..registerSingleton<FetchCoffeeFromHistory>(fetchCoffeeFromHistoryMock)
      ..registerSingleton<SaveCoffeeToHistory>(saveCoffeeToHistoryMock)
      ..registerSingleton<UpdateCoffee>(commentCoffeeMock, instanceName: 'commentCoffee')
      ..registerSingleton<UpdateCoffee>(rateCoffeeMock, instanceName: 'rateCoffee')
      ..registerSingleton(favoritesBloc, instanceName: StorageConstants.favoritesKey)
      ..registerSingleton(historyBloc, instanceName: 'history')
      ..registerSingleton(
        MainScreenBloc(
          apiFetchCoffee: fetchCoffeeFromRemoteMock,
          localFetchCoffee: fetchCoffeeFromHistoryMock,
          saveCoffeeToHistory: saveCoffeeToHistoryMock,
          historyListBloc: historyBloc,
        ),
      );

    tearDown(() async {
      await tearDownTestHive();
      await sl.reset();
    });

    group('AppRoutes', () {
      testWidgets('renders DetailsScreen with valid arguments', (tester) async {
        await pumpRoute(
          tester,
          settings: RouteSettings(
            name: AppRoutes.details,
            arguments: (
              coffee: createDummyCoffee(),
              historyBloc: historyBloc,
              favoritesBloc: favoritesBloc,
            ),
          ),
        );
        expect(find.byType(DetailsScreen), findsOneWidget);
      });

      testWidgets('renders fallback for invalid details route', (tester) async {
        await pumpRoute(
          tester,
          settings: const RouteSettings(name: AppRoutes.details),
        );
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });
  });
}
