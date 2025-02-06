import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

import '../../../helpers/helpers.dart' as h;

// Mock class using Mocktail
class MockGetCoffeeList extends Mock implements GetCoffeeList {}

void main() {
  late MockGetCoffeeList mockGetCoffeeList;
  late CoffeeCardListBloc coffeeCardListBloc;
  late Failure failure;
  late Failure unexpectedInputFailure;

  setUp(() {
    mockGetCoffeeList = MockGetCoffeeList();
    coffeeCardListBloc = CoffeeCardListBloc(getList: mockGetCoffeeList);

    failure = h.failure;
    unexpectedInputFailure = h.unexpectedInputFailure;
  });

  tearDown(() {
    coffeeCardListBloc.close();
  });

  group('CoffeeCardListBloc', () {
    test('initial state should be CoffeeCardListLoading', () {
      expect(coffeeCardListBloc.state, const CoffeeCardListLoading());
    });

    blocTest<CoffeeCardListBloc, CoffeeCardListState>(
      // ignore: lines_longer_than_80_chars
      'emits [CoffeeCardListLoading, CoffeeCardListLoaded] when LoadCoffeeCardList is added and getList returns success',
      build: () {
        when(
          () => mockGetCoffeeList.call(),
        ).thenAnswer((_) async => Result.success(h.dummyCoffeeList));
        return coffeeCardListBloc;
      },
      act: (bloc) => bloc.add(LoadCoffeeCardList()),
      expect: () => [
        const CoffeeCardListLoading(),
        CoffeeCardListLoaded(list: h.dummyCoffeeList),
      ],
      verify: (_) {
        verify(() => mockGetCoffeeList.call()).called(1);
      },
    );

    blocTest<CoffeeCardListBloc, CoffeeCardListState>(
      // ignore: lines_longer_than_80_chars
      'emits [CoffeeCardListLoading, CoffeeCardListFailedLoading] when LoadCoffeeCardList is added and getList returns failure',
      build: () {
        when(() => mockGetCoffeeList.call()).thenAnswer(
          (_) async => Result.failure(failure),
        );
        return coffeeCardListBloc;
      },
      act: (bloc) => bloc.add(LoadCoffeeCardList()),
      expect: () => [
        const CoffeeCardListLoading(),
        CoffeeCardListFailedLoading(failure),
      ],
      verify: (_) {
        verify(() => mockGetCoffeeList.call()).called(1);
      },
    );

    blocTest<CoffeeCardListBloc, CoffeeCardListState>(
      // ignore: lines_longer_than_80_chars
      'emits [CoffeeCardListLoading, CoffeeCardListFailedLoading] when LoadCoffeeCardList is added and getList returns a different failure',
      build: () {
        when(() => mockGetCoffeeList.call()).thenAnswer(
          (_) async => Result.failure(unexpectedInputFailure),
        );
        return coffeeCardListBloc;
      },
      act: (bloc) => bloc.add(LoadCoffeeCardList()),
      expect: () => [
        const CoffeeCardListLoading(),
        CoffeeCardListFailedLoading(unexpectedInputFailure),
      ],
      verify: (_) {
        verify(() => mockGetCoffeeList.call()).called(1);
      },
    );

    blocTest<CoffeeCardListBloc, CoffeeCardListState>(
      // ignore: lines_longer_than_80_chars
      'emits [CoffeeCardListLoading, CoffeeCardListFailedLoading] when LoadCoffeeCardList is added and getList returns failure with message',
      build: () {
        when(() => mockGetCoffeeList.call()).thenAnswer(
          (_) async => Result.failure(failure),
        );
        return coffeeCardListBloc;
      },
      act: (bloc) => bloc.add(LoadCoffeeCardList()),
      expect: () => [
        const CoffeeCardListLoading(),
        CoffeeCardListFailedLoading(failure),
      ],
      verify: (_) {
        verify(() => mockGetCoffeeList.call()).called(1);
      },
    );
  });
}
