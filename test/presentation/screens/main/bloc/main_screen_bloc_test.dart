import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

import '../../../../helpers/helpers.dart';

class MockCoffeeCardListBloc extends Mock implements CoffeeCardListBloc {}

class MockGetCoffee extends Mock implements GetCoffee {}

class MockSaveCoffeeToHistory extends Mock implements SaveCoffee {}

class FakeCoffee extends Fake implements Coffee {}

class FakeFailure extends Fake implements Failure {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCoffee());
    registerFallbackValue(FakeFailure());
  });

  late Coffee coffee;
  late Failure failure;

  group('MainScreenBloc', () {
    late CoffeeCardListBloc historyListBloc;
    late GetCoffee apiFetchCoffee;
    late GetCoffee localFetchCoffee;
    late SaveCoffee saveCoffeeToHistory;
    late MainScreenBloc bloc;

    setUp(() {
      historyListBloc = MockCoffeeCardListBloc();
      apiFetchCoffee = MockGetCoffee();
      localFetchCoffee = MockGetCoffee();
      saveCoffeeToHistory = MockSaveCoffeeToHistory();

      coffee = dummyCoffee;
      failure = FakeFailure();

      bloc = MainScreenBloc(
        historyListBloc: historyListBloc,
        apiFetchCoffee: apiFetchCoffee,
        localFetchCoffee: localFetchCoffee,
        saveCoffeeToHistory: saveCoffeeToHistory,
      );
    });

    blocTest<MainScreenBloc, MainScreenState>(
      // ignore: lines_longer_than_80_chars
      'emits [MainScreenLoading, MainScreenLoaded] when API fetch succeeds and save succeeds',
      build: () {
        when(
          () => apiFetchCoffee(),
        ).thenAnswer((_) async => Result.success(dummyCoffee));
        when(
          () => saveCoffeeToHistory(dummyCoffee),
        ).thenAnswer((_) async => const Result.success(null));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchRandomCoffee()),
      expect: () => [
        MainScreenLoading(),
        MainScreenLoaded(coffee: dummyCoffee),
      ],
      verify: (_) {
        verify(() => historyListBloc.add(LoadCoffeeCardList())).called(1);
      },
    );

    blocTest<MainScreenBloc, MainScreenState>(
      // ignore: lines_longer_than_80_chars
      'emits [MainScreenLoading, MainScreenFailure] when API fetch succeeds but save fails',
      build: () {
        when(
          () => apiFetchCoffee(),
        ).thenAnswer((_) async => Result.success(coffee));
        when(
          () => saveCoffeeToHistory(coffee),
        ).thenAnswer((_) async => Result.failure(failure));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchRandomCoffee()),
      expect: () => [
        MainScreenLoading(),
        MainScreenFailure(failure),
        MainScreenLoaded(coffee: coffee),
      ],
    );

    blocTest<MainScreenBloc, MainScreenState>(
      // ignore: lines_longer_than_80_chars
      'emits [MainScreenLoading, MainScreenLoaded] when API fetch fails and local fetch succeeds',
      build: () {
        when(
          () => apiFetchCoffee(),
        ).thenAnswer((_) async => Result.failure(failure));
        when(
          () => localFetchCoffee(),
        ).thenAnswer((_) async => Result.success(dummyCoffee));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchRandomCoffee()),
      expect: () => [
        MainScreenLoading(),
        MainScreenLoaded(coffee: dummyCoffee),
      ],
    );

    blocTest<MainScreenBloc, MainScreenState>(
      // ignore: lines_longer_than_80_chars
      'emits [MainScreenLoading, MainScreenFailure] when API fetch fails and local fetch fails',
      build: () {
        when(
          () => apiFetchCoffee(),
        ).thenAnswer((_) async => Result.failure(failure));
        when(
          () => localFetchCoffee(),
        ).thenAnswer((_) async => Result.failure(failure));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchRandomCoffee()),
      expect: () => [
        MainScreenLoading(),
        MainScreenFailure(failure),
      ],
    );

    blocTest<MainScreenBloc, MainScreenState>(
      'RefreshRandomCoffee triggers the same behavior as FetchRandomCoffee',
      build: () {
        when(
          () => apiFetchCoffee(),
        ).thenAnswer((_) async => Result.success(dummyCoffee));
        when(
          () => saveCoffeeToHistory(dummyCoffee),
        ).thenAnswer((_) async => const Result.success(null));
        return bloc;
      },
      act: (bloc) => bloc.add(RefreshRandomCoffee()),
      expect: () => [
        MainScreenLoading(),
        MainScreenLoaded(coffee: dummyCoffee),
      ],
      verify: (_) {
        verify(() => historyListBloc.add(LoadCoffeeCardList())).called(1);
      },
    );
  });
}
