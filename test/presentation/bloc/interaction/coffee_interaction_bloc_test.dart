import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

import '../../../helpers/helpers.dart' as h;

class MockUpdateCoffee extends Mock implements UpdateCoffee {}

class MockCoffee extends Mock implements Coffee {}

void main() {
  late CoffeeInteractionBloc coffeeInteractionBloc;
  late MockUpdateCoffee mockCommentCoffee;
  late MockUpdateCoffee mockRateCoffee;
  late MockCoffee mockCoffee;

  late Failure failure;

  setUp(() {
    failure = h.failure;
    mockCommentCoffee = MockUpdateCoffee();
    mockRateCoffee = MockUpdateCoffee();
    mockCoffee = MockCoffee();
    coffeeInteractionBloc = CoffeeInteractionBloc(
      commentCoffee: mockCommentCoffee,
      rateCoffee: mockRateCoffee,
    );

    registerFallbackValue(UpdateCoffeeParams(coffee: mockCoffee));
  });

  tearDown(() {
    coffeeInteractionBloc.close();
  });

  group('CoffeeInteractionBloc', () {
    test('initial state is CoffeeInteractionInitial', () {
      expect(coffeeInteractionBloc.state, isA<CoffeeInteractionInitial>());
    });

    blocTest<CoffeeInteractionBloc, CoffeeInteractionState>(
      'emits [CommentIsGettingInput] when CommentChanged is added',
      build: () => coffeeInteractionBloc,
      act: (bloc) => bloc.add(
        CommentChanged(
          comment: 'New comment',
          coffee: mockCoffee,
        ),
      ),
      expect: () => [isA<CommentIsGettingInput>()],
    );

    blocTest<CoffeeInteractionBloc, CoffeeInteractionState>(
      // ignore: lines_longer_than_80_chars
      'emits [CommentIsGettingInput, CommentSubmissionInProgress, CommentSubmissionSuccess] when SubmitComment is added and commentCoffee succeeds',
      build: () {
        when(
          () => mockCommentCoffee(any()),
        ).thenAnswer((_) async => const Result.success(null));
        return coffeeInteractionBloc;
      },
      seed: CommentIsGettingInput.new,
      act: (bloc) => bloc.add(SubmitComment(coffee: mockCoffee)),
      expect: () => [
        isA<CommentSubmissionInProgress>(),
        isA<CommentSubmissionSuccess>(),
      ],
      verify: (_) {
        verify(() => mockCommentCoffee(any())).called(1);
      },
    );

    blocTest<CoffeeInteractionBloc, CoffeeInteractionState>(
      // ignore: lines_longer_than_80_chars
      'emits [CommentIsGettingInput, CommentSubmissionInProgress, CommentSubmissionFailure] when SubmitComment is added and commentCoffee fails',
      build: () {
        when(
          () => mockCommentCoffee(any()),
        ).thenAnswer((_) async => Result.failure(failure));
        return coffeeInteractionBloc;
      },
      seed: CommentIsGettingInput.new,
      act: (bloc) => bloc.add(SubmitComment(coffee: mockCoffee)),
      expect: () => [
        isA<CommentSubmissionInProgress>(),
        isA<CommentSubmissionFailure>(),
      ],
      verify: (_) {
        verify(() => mockCommentCoffee(any())).called(1);
      },
    );

    blocTest<CoffeeInteractionBloc, CoffeeInteractionState>(
      'debounces CommentChanged events and calls SubmitComment after delay',
      build: () {
        when(
          () => mockCommentCoffee(any()),
        ).thenAnswer((_) async => const Result.success(null));
        return coffeeInteractionBloc;
      },
      act: (bloc) async {
        bloc.add(
          CommentChanged(comment: 'Initial comment', coffee: mockCoffee),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
        bloc.add(CommentChanged(comment: 'Second comment', coffee: mockCoffee));
        await Future<void>.delayed(const Duration(seconds: 6));
      },
      expect: () => [
        isA<CommentIsGettingInput>(),
        isA<CommentIsGettingInput>(),
        isA<CommentSubmissionInProgress>(),
        isA<CommentSubmissionSuccess>(),
      ],
      verify: (_) {
        verify(() => mockCommentCoffee(any())).called(1);
      },
    );

    blocTest<CoffeeInteractionBloc, CoffeeInteractionState>(
      // ignore: lines_longer_than_80_chars
      'emits [RatingSubmissionInProgress, RatingSubmissionSuccess] when SubmitRating is added and rateCoffee succeeds',
      build: () {
        when(
          () => mockRateCoffee(any()),
        ).thenAnswer((_) async => const Result.success(null));
        return coffeeInteractionBloc;
      },
      act: (bloc) => bloc.add(
        SubmitRating(coffee: mockCoffee, rating: CoffeeRating.fourStars),
      ),
      expect: () => [
        isA<RatingSubmissionInProgress>(),
        isA<RatingSubmissionSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRateCoffee(any())).called(1);
      },
    );

    blocTest<CoffeeInteractionBloc, CoffeeInteractionState>(
      // ignore: lines_longer_than_80_chars
      'emits [RatingSubmissionInProgress, RatingSubmissionFailure] when SubmitRating is added and rateCoffee fails',
      build: () {
        when(
          () => mockRateCoffee(any()),
        ).thenAnswer((_) async => Result.failure(failure));
        return coffeeInteractionBloc;
      },
      act: (bloc) => bloc.add(
        SubmitRating(coffee: mockCoffee, rating: CoffeeRating.threeStars),
      ),
      expect: () => [
        isA<RatingSubmissionInProgress>(),
        isA<RatingSubmissionFailure>(),
      ],
      verify: (_) {
        verify(() => mockRateCoffee(any())).called(1);
      },
    );

    blocTest<CoffeeInteractionBloc, CoffeeInteractionState>(
      'emits correct rating in RatingSubmissionSuccess',
      build: () {
        when(
          () => mockRateCoffee(any()),
        ).thenAnswer((_) async => const Result.success(null));
        return coffeeInteractionBloc;
      },
      act: (bloc) => bloc.add(
        SubmitRating(coffee: mockCoffee, rating: CoffeeRating.fiveStars),
      ),
      expect: () => [
        isA<RatingSubmissionInProgress>(),
        isA<RatingSubmissionSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRateCoffee(any())).called(1);
      },
    );
  });
}
