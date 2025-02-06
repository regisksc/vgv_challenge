import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

import '../../../helpers/helpers.dart' as h;

class MockSaveCoffee extends Mock implements SaveCoffee {}

class MockUnfavorite extends Mock implements Unfavorite {}

void main() {
  late FavoritesBloc favoritesBloc;
  late MockSaveCoffee mockSaveCoffee;
  late MockUnfavorite mockUnfavoriteCoffee;

  late Failure failure;
  late Failure unexpectedInputFailure;

  setUp(() {
    failure = h.failure;
    unexpectedInputFailure = h.unexpectedInputFailure;

    mockSaveCoffee = MockSaveCoffee();
    mockUnfavoriteCoffee = MockUnfavorite();
    favoritesBloc = FavoritesBloc(
      coffee: h.dummyCoffee,
      saveCoffee: mockSaveCoffee,
      unfavoriteCoffee: mockUnfavoriteCoffee,
    );
  });

  tearDown(() {
    favoritesBloc.close();
  });

  group('FavoritesBloc', () {
    test('initial state is FavoritesInitial', () {
      expect(favoritesBloc.state, isA<FavoritesInitial>());
    });

    blocTest<FavoritesBloc, FavoritesState>(
      // ignore: lines_longer_than_80_chars
      'emits [FavoritingInProgress, FavoritingSuccess] when FavoritedCoffee is added and saveCoffee succeeds',
      build: () {
        when(
          () => mockSaveCoffee(h.dummyCoffee),
        ).thenAnswer((_) async => const Result.success(null));
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(FavoritedCoffee()),
      expect: () => [
        isA<FavoritingInProgress>(),
        isA<FavoritingSuccess>(),
      ],
      verify: (_) {
        verify(() => mockSaveCoffee(h.dummyCoffee)).called(1);
      },
    );

    blocTest<FavoritesBloc, FavoritesState>(
      // ignore: lines_longer_than_80_chars
      'emits [FavoritingInProgress, FavoritingFailure] when FavoritedCoffee is added and saveCoffee fails',
      build: () {
        when(
          () => mockSaveCoffee(h.dummyCoffee),
        ).thenAnswer((_) async => Result.failure(failure));
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(FavoritedCoffee()),
      expect: () => [
        isA<FavoritingInProgress>(),
        isA<FavoritingFailure>(),
      ],
      verify: (_) => verify(() => mockSaveCoffee(h.dummyCoffee)).called(1),
    );

    blocTest<FavoritesBloc, FavoritesState>(
      // ignore: lines_longer_than_80_chars
      'emits [FavoritingInProgress, FavoritingFailure] when FavoritedCoffee is added and saveCoffee fails with different failure',
      build: () {
        when(
          () => mockSaveCoffee(h.dummyCoffee),
        ).thenAnswer((_) async => Result.failure(unexpectedInputFailure));
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(FavoritedCoffee()),
      expect: () => [
        isA<FavoritingInProgress>(),
        isA<FavoritingFailure>(),
      ],
      verify: (_) {
        verify(() => mockSaveCoffee(h.dummyCoffee)).called(1);
      },
    );

    blocTest<FavoritesBloc, FavoritesState>(
      // ignore: lines_longer_than_80_chars
      'emits [FavoritingInProgress, FavoritingFailure] when FavoritedCoffee is added and saveCoffee fails with message',
      build: () {
        when(
          () => mockSaveCoffee(h.dummyCoffee),
        ).thenAnswer((_) async => Result.failure(failure));
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(FavoritedCoffee()),
      expect: () => [
        isA<FavoritingInProgress>(),
        isA<FavoritingFailure>(),
      ],
      verify: (_) {
        verify(() => mockSaveCoffee(h.dummyCoffee)).called(1);
      },
    );

    blocTest<FavoritesBloc, FavoritesState>(
      // ignore: lines_longer_than_80_chars
      'emits [UnfavoritingInProgress, UnfavoritingSuccess] when UnfavoritedCoffee is added and unfavoriteCoffee succeeds',
      build: () {
        when(
          () => mockUnfavoriteCoffee(h.dummyCoffee),
        ).thenAnswer((_) async => const Result.success(null));
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(UnfavoritedCoffee()),
      expect: () => [
        isA<UnfavoritingInProgress>(),
        isA<UnfavoritingSuccess>(),
      ],
      verify: (_) {
        verify(() => mockUnfavoriteCoffee(h.dummyCoffee)).called(1);
      },
    );

    blocTest<FavoritesBloc, FavoritesState>(
      // ignore: lines_longer_than_80_chars
      'emits [UnfavoritingInProgress, UnfavoritingFailure] when UnfavoritedCoffee is added and unfavoriteCoffee fails',
      build: () {
        when(
          () => mockUnfavoriteCoffee(h.dummyCoffee),
        ).thenAnswer((_) async => Result.failure(failure));
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(UnfavoritedCoffee()),
      expect: () => [
        isA<UnfavoritingInProgress>(),
        isA<UnfavoritingFailure>(),
      ],
      verify: (_) {
        verify(() => mockUnfavoriteCoffee(h.dummyCoffee)).called(1);
      },
    );
    blocTest<FavoritesBloc, FavoritesState>(
      // ignore: lines_longer_than_80_chars
      'emits [UnfavoritingInProgress, UnfavoritingFailure] when UnfavoritedCoffee is added and unfavoriteCoffee fails message',
      build: () {
        when(
          () => mockUnfavoriteCoffee(h.dummyCoffee),
        ).thenAnswer((_) async => Result.failure(failure));
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(UnfavoritedCoffee()),
      expect: () => [
        isA<UnfavoritingInProgress>(),
        isA<UnfavoritingFailure>(),
      ],
      verify: (_) {
        verify(() => mockUnfavoriteCoffee(h.dummyCoffee)).called(1);
      },
    );

    blocTest<FavoritesBloc, FavoritesState>(
      // ignore: lines_longer_than_80_chars
      'emits [UnfavoritingInProgress, UnfavoritingFailure] when UnfavoritedCoffee is added and unfavoriteCoffee fails with different failure',
      build: () {
        final failure = UnexpectedInputFailure();
        when(
          () => mockUnfavoriteCoffee(h.dummyCoffee),
        ).thenAnswer((_) async => Result.failure(failure));
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(UnfavoritedCoffee()),
      expect: () => [
        isA<UnfavoritingInProgress>(),
        isA<UnfavoritingFailure>(),
      ],
      verify: (_) {
        verify(() => mockUnfavoriteCoffee(h.dummyCoffee)).called(1);
      },
    );
  });
}
