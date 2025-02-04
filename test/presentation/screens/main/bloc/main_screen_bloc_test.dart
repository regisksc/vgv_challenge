import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class MockGetCoffee extends Mock implements GetCoffee {}

class MockSaveCoffee extends Mock implements SaveCoffee {}

class MockHistoryListBloc extends Mock implements HistoryListBloc {}

void main() {
  late MockHistoryListBloc mockHistoryListBloc;
  late MockGetCoffee mockApiFetchCoffee;
  late MockGetCoffee mockLocalFetchCoffee;
  late MockSaveCoffee mockSaveCoffeeToHistory;
  late MainScreenBloc bloc;
  late Coffee dummyCoffee;

  setUpAll(() {
    registerFallbackValue(LoadHistory());
  });

  setUp(() {
    mockHistoryListBloc = MockHistoryListBloc();
    mockApiFetchCoffee = MockGetCoffee();
    mockLocalFetchCoffee = MockGetCoffee();
    mockSaveCoffeeToHistory = MockSaveCoffee();
    dummyCoffee = Coffee(
      id: 'dummy_id',
      imagePath: '/dummy/path.jpg',
      seenAt: DateTime(2025),
      comment: 'Test comment',
      rating: CoffeeRating.threeStars,
    );

    when(
      () => mockApiFetchCoffee(),
    ).thenAnswer((_) async => Result.success(dummyCoffee));
    when(
      () => mockLocalFetchCoffee(),
    ).thenAnswer((_) async => Result.success(dummyCoffee));
    when(
      () => mockSaveCoffeeToHistory(dummyCoffee),
    ).thenAnswer((_) async => const Result.success(null));

    bloc = MainScreenBloc(
      historyListBloc: mockHistoryListBloc,
      apiFetchCoffee: mockApiFetchCoffee,
      localFetchCoffee: mockLocalFetchCoffee,
      saveCoffeeToHistory: mockSaveCoffeeToHistory,
    );
  });

  blocTest<MainScreenBloc, MainScreenState>(
    'emits [MainScreenLoading, MainScreenLoaded] when api fetch succeeds',
    build: () => bloc,
    act: (bloc) => bloc.add(FetchRandomCoffee()),
    expect: () => <MainScreenState>[
      MainScreenLoading(),
      MainScreenLoaded(coffee: dummyCoffee),
    ],
    verify: (_) {
      verify(() => mockApiFetchCoffee()).called(1);
      verify(() => mockSaveCoffeeToHistory(dummyCoffee)).called(1);
      verify(
        () => mockHistoryListBloc.add(any(that: isA<LoadHistory>())),
      ).called(1);
    },
  );

  blocTest<MainScreenBloc, MainScreenState>(
    // ignore: lines_longer_than_80_chars
    'emits [MainScreenLoading, MainScreenLoaded] when api fetch fails and local fetch succeeds',
    build: () {
      when(() => mockApiFetchCoffee()).thenAnswer(
        (_) async => Result.failure(ServerFailure()),
      );
      return bloc;
    },
    act: (bloc) => bloc.add(FetchRandomCoffee()),
    expect: () => <MainScreenState>[
      MainScreenLoading(),
      MainScreenLoaded(coffee: dummyCoffee),
    ],
    verify: (_) {
      verify(() => mockApiFetchCoffee()).called(1);
      verify(() => mockLocalFetchCoffee()).called(1);
    },
  );

  blocTest<MainScreenBloc, MainScreenState>(
    // ignore: lines_longer_than_80_chars
    'emits [MainScreenLoading, MainScreenFailure] when both api and local fetch fail',
    build: () {
      when(() => mockApiFetchCoffee()).thenAnswer(
        (_) async => Result.failure(ServerFailure()),
      );
      when(() => mockLocalFetchCoffee()).thenAnswer(
        (_) async => Result.failure(ReadingFailure()),
      );
      return bloc;
    },
    act: (bloc) => bloc.add(FetchRandomCoffee()),
    expect: () => <Matcher>[
      isA<MainScreenLoading>(),
      predicate<MainScreenFailure>(
        (state) => state.failure is ReadingFailure,
        'state.failure is ReadingFailure',
      ),
    ],
    verify: (_) {
      verify(() => mockApiFetchCoffee()).called(1);
      verify(() => mockLocalFetchCoffee()).called(1);
    },
  );

  blocTest<MainScreenBloc, MainScreenState>(
    'RefreshRandomCoffee triggers same behavior as FetchRandomCoffee',
    build: () => bloc,
    act: (bloc) => bloc.add(RefreshRandomCoffee()),
    expect: () => <MainScreenState>[
      MainScreenLoading(),
      MainScreenLoaded(coffee: dummyCoffee),
    ],
  );

  blocTest<MainScreenBloc, MainScreenState>(
    'TapCoffee emits IsNavigating with details destination',
    build: () {
      // Arrange
      final bloc = MainScreenBloc(
        historyListBloc: mockHistoryListBloc,
        apiFetchCoffee: mockApiFetchCoffee,
        localFetchCoffee: mockLocalFetchCoffee,
        saveCoffeeToHistory: mockSaveCoffeeToHistory,
      )..emit(MainScreenLoaded(coffee: dummyCoffee));
      return bloc;
    },
    act: (bloc) => bloc.add(const TapCoffee()),
    expect: () => <Matcher>[
      predicate<IsNavigating>(
        (state) => state.destination == AppRoutes.details && state.coffee == dummyCoffee,
        'IsNavigating with destination details and correct coffee',
      ),
    ],
  );

  blocTest<MainScreenBloc, MainScreenState>(
    'TapFavoritesCallToAction emits IsNavigating with favorites destination',
    build: () => bloc,
    act: (bloc) => bloc.add(TapFavoritesCallToAction()),
    expect: () => <Matcher>[
      predicate<IsNavigating>(
        // ignore: lines_longer_than_80_chars
        (state) => state.destination == AppRoutes.favorites && state.coffee == null,
        'IsNavigating with destination favorites and no coffee',
      ),
    ],
  );
}
