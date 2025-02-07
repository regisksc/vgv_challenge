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

import '../../helpers/fakes.dart';

class GetFavoritesListMock extends Mock implements GetCoffeeList {}

class GetHistoryListMock extends Mock implements GetCoffeeList {}

class FetchCoffeeFromRemoteMock extends Mock implements FetchCoffeeFromRemote {}

class FetchCoffeeFromHistoryMock extends Mock implements FetchCoffeeFromHistory {}

class SaveCoffeeToHistoryMock extends Mock implements SaveCoffeeToHistory {}

class CommentCoffeeMock extends Mock implements CommentCoffee {}

class RateCoffeeMock extends Mock implements RateCoffee {}

class UnfavoriteCoffeeMock extends Mock implements Unfavorite {}

Future<void> pumpRoute(
  WidgetTester tester, {
  required RouteSettings settings,
}) async {
  final route = AppRoutes.onGenerateRoute(settings);
  final pageRoute = route as MaterialPageRoute;
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<CoffeeCardListBloc>.value(
          value: sl.get<CoffeeCardListBloc>(instanceName: 'history'),
        ),
        BlocProvider<MainScreenBloc>.value(
          value: sl.get<MainScreenBloc>(),
        ),
        BlocProvider<CoffeeInteractionBloc>.value(
          value: sl.get<CoffeeInteractionBloc>(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: pageRoute.builder),
      ),
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
  late RateCoffee rateCoffeeMock;
  late Unfavorite unfavoriteCoffeeMock;

  late Coffee fakeCoffee;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await setUpTestHive();
  });

  tearDownAll(() async {
    await tearDownTestHive();
  });

  setUp(() async {
    fakeCoffee = dummyCoffee;
    await sl.reset();
    getFavoritesListMock = GetFavoritesListMock();
    getHistoryListMock = GetHistoryListMock();
    fetchCoffeeFromRemoteMock = FetchCoffeeFromRemoteMock();
    fetchCoffeeFromHistoryMock = FetchCoffeeFromHistoryMock();
    saveCoffeeToHistoryMock = SaveCoffeeToHistoryMock();
    commentCoffeeMock = CommentCoffeeMock();
    rateCoffeeMock = RateCoffeeMock();
    unfavoriteCoffeeMock = UnfavoriteCoffeeMock();

    final box = await Hive.openBox<String>('coffee_box');

    sl
      ..registerSingleton<Box<String>>(box)
      ..registerSingleton<GetCoffeeList>(getFavoritesListMock, instanceName: StorageConstants.favoritesKey)
      ..registerSingleton<GetCoffeeList>(getHistoryListMock, instanceName: 'history')
      ..registerSingleton<FetchCoffeeFromRemote>(fetchCoffeeFromRemoteMock)
      ..registerSingleton<FetchCoffeeFromHistory>(fetchCoffeeFromHistoryMock)
      ..registerSingleton<SaveCoffee>(saveCoffeeToHistoryMock, instanceName: 'saveHistory')
      ..registerSingleton<SaveCoffee>(saveCoffeeToHistoryMock, instanceName: 'saveFavorite')
      ..registerSingleton<CommentCoffee>(commentCoffeeMock)
      ..registerSingleton<Unfavorite>(unfavoriteCoffeeMock)
      ..registerSingleton<RateCoffee>(rateCoffeeMock)
      ..registerSingleton<CoffeeCardListBloc>(
        CoffeeCardListBloc(getList: getHistoryListMock),
        instanceName: 'history',
      )
      ..registerSingleton<CoffeeCardListBloc>(
        CoffeeCardListBloc(getList: getHistoryListMock),
        instanceName: 'favorites',
      )
      ..registerSingleton<CoffeeInteractionBloc>(
        CoffeeInteractionBloc(commentCoffee: sl<CommentCoffee>(), rateCoffee: sl<RateCoffee>()),
      )
      ..registerSingleton<MainScreenBloc>(
        MainScreenBloc(
          apiFetchCoffee: fetchCoffeeFromRemoteMock,
          localFetchCoffee: fetchCoffeeFromHistoryMock,
          saveCoffeeToHistory: saveCoffeeToHistoryMock,
          historyListBloc: sl.get<CoffeeCardListBloc>(instanceName: 'history'),
        ),
      );

    when(() => fetchCoffeeFromRemoteMock()).thenAnswer((_) async => Result.success(fakeCoffee));
    when(() => fetchCoffeeFromHistoryMock()).thenAnswer((_) async => Result.success(fakeCoffee));
    when(() => saveCoffeeToHistoryMock(any())).thenAnswer((_) async => const Result.success(null));
    when(() => getHistoryListMock()).thenAnswer((_) async => Result.success([fakeCoffee]));
    when(() => commentCoffeeMock(any())).thenAnswer((_) async => const Result.success(null));
  });

  tearDown(() async {
    await sl.reset();
  });

  group('AppRoutes', () {
    testWidgets('renders DetailsScreen with valid arguments', (tester) async {
      final historyListBloc = sl.get<CoffeeCardListBloc>(instanceName: 'history');
      when(() => historyListBloc.getList(any())).thenAnswer((_) async => Result.success([dummyCoffee]));
      await pumpRoute(
        tester,
        settings: RouteSettings(
          name: AppRoutes.details,
          arguments: fakeCoffee,
        ),
      );
      expect(find.byType(DetailsScreen), findsOneWidget);
    });

    testWidgets('renders fallback for invalid details route', (tester) async {
      await pumpRoute(tester, settings: const RouteSettings(name: AppRoutes.details));
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(DetailsScreen), findsNothing);
    });

    testWidgets('renders FavoritesScreen for AppRoutes.favorites', (tester) async {
      final favoritesListMock = sl.get<GetCoffeeList>(instanceName: 'favorites');
      when(() => favoritesListMock.call(any())).thenAnswer((_) async => Result.success([dummyCoffee]));

      await pumpRoute(tester, settings: const RouteSettings(name: AppRoutes.favorites));
      await tester.pumpAndSettle(const Duration(minutes: 1));
      expect(find.byType(FavoritesScreen), findsOneWidget);
    });

    testWidgets('renders fallback for unknown route', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          onGenerateRoute: AppRoutes.onGenerateRoute,
          initialRoute: '/unknown',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Route Not Found'), findsOneWidget);
    });
  });
}
