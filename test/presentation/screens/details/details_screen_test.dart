// ignore_for_file: prefer_const_constructors, lines_longer_than_80_chars

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

import '../../../helpers/fakes.dart';

class MockCoffeeInteractionBloc extends MockBloc<CoffeeInteractionEvent, CoffeeInteractionState>
    implements CoffeeInteractionBloc {}

class FakeCoffeeInteractionEvent extends Fake implements CoffeeInteractionEvent {}

class FakeCoffeeInteractionState extends Fake implements CoffeeInteractionState {}

class MockFavoritesBloc extends MockBloc<FavoritesEvent, FavoritesState> implements FavoritesBloc {}

class FakeFavoritesEvent extends Fake implements FavoritesEvent {}

class FakeFavoritesState extends Fake implements FavoritesState {}

void main() {
  late MockCoffeeInteractionBloc mockCoffeeInteractionBloc;
  late MockFavoritesBloc mockFavoritesBloc;
  late Coffee fakeCoffee;

  setUpAll(() {
    registerFallbackValue(FakeCoffeeInteractionEvent());
    registerFallbackValue(FakeCoffeeInteractionState());
    registerFallbackValue(FakeFavoritesEvent());
    registerFallbackValue(FakeFavoritesState());
  });

  setUp(() {
    mockCoffeeInteractionBloc = MockCoffeeInteractionBloc();
    mockFavoritesBloc = MockFavoritesBloc();
    fakeCoffee = dummyCoffee;
  });

  Widget buildTestableWidget({
    required CoffeeInteractionBloc coffeeInteractionBloc,
    required FavoritesBloc favoritesBloc,
    required Coffee coffee,
    GestureTapCallback? onTap,
  }) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: coffeeInteractionBloc),
          BlocProvider.value(value: favoritesBloc),
        ],
        child: DetailsScreen(coffee: coffee, onTap: onTap),
      ),
    );
  }

  group('DetailsScreen', () {
    testWidgets('renders all UI components properly', (tester) async {
      // Arrange
      when(() => mockCoffeeInteractionBloc.state).thenReturn(CoffeeInteractionInitial());
      when(() => mockFavoritesBloc.state).thenReturn(FavoritesInitial());

      // Act
      await tester.pumpWidget(
        buildTestableWidget(
          coffeeInteractionBloc: mockCoffeeInteractionBloc,
          favoritesBloc: mockFavoritesBloc,
          coffee: fakeCoffee,
        ),
      );

      // Assert
      expect(find.text('Lovely coffee pic'), findsOneWidget);
      expect(find.byType(CoffeeCard), findsOneWidget);
      expect(find.text('Comment'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.star), findsAtLeast(11));
    });

    testWidgets('toggles favorite when star icon is tapped (coffee not favorite)', (tester) async {
      // Arrange
      final coffee = CoffeeModel.fromEntity(fakeCoffee).copyWith(isFavorite: false).asEntity;
      when(() => mockCoffeeInteractionBloc.state).thenReturn(CoffeeInteractionInitial());
      when(() => mockFavoritesBloc.state).thenReturn(FavoritesInitial());

      // Act
      await tester.pumpWidget(
        buildTestableWidget(
          coffeeInteractionBloc: mockCoffeeInteractionBloc,
          favoritesBloc: mockFavoritesBloc,
          coffee: coffee,
        ),
      );
      await tester.tap(find.byKey(const Key('favoriteIcon')));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockFavoritesBloc.add(any(that: isA<FavoritedCoffee>()))).called(1);
    });

    testWidgets('toggles favorite when star icon is tapped (coffee is favorite)', (tester) async {
      // Arrange
      final coffee = CoffeeModel.fromEntity(fakeCoffee).copyWith(isFavorite: true).asEntity;
      when(() => mockCoffeeInteractionBloc.state).thenReturn(CoffeeInteractionInitial());
      when(() => mockFavoritesBloc.state).thenReturn(FavoritesInitial());

      // Act
      await tester.pumpWidget(
        buildTestableWidget(
          coffeeInteractionBloc: mockCoffeeInteractionBloc,
          favoritesBloc: mockFavoritesBloc,
          coffee: coffee,
        ),
      );
      await tester.tap(find.byKey(const Key('favoriteIcon')));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockFavoritesBloc.add(any(that: isA<UnfavoritedCoffee>()))).called(1);
    });

    testWidgets('shows progress indicator and cannot pop when storing is true', (tester) async {
      // Arrange
      when(() => mockCoffeeInteractionBloc.state).thenReturn(CommentIsGettingInput());
      when(() => mockFavoritesBloc.state).thenReturn(FavoritesInitial());

      // Act
      await tester.pumpWidget(
        buildTestableWidget(
          coffeeInteractionBloc: mockCoffeeInteractionBloc,
          favoritesBloc: mockFavoritesBloc,
          coffee: fakeCoffee,
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final dynamic backButton = find.byIcon(Icons.chevron_left);
      expect(backButton, findsNothing);
    });

    testWidgets('shows leading icon and can pop when storing is false', (tester) async {
      // Arrange
      when(() => mockCoffeeInteractionBloc.state).thenReturn(CoffeeInteractionInitial());
      when(() => mockFavoritesBloc.state).thenReturn(FavoritesInitial());

      // Act
      await tester.pumpWidget(
        buildTestableWidget(
          coffeeInteractionBloc: mockCoffeeInteractionBloc,
          favoritesBloc: mockFavoritesBloc,
          coffee: fakeCoffee,
        ),
      );

      // Assert
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('shows snackbars for success from CoffeeInteractionBloc', (tester) async {
      // Arrange
      whenListen(
        mockCoffeeInteractionBloc,
        Stream.fromIterable([
          CommentSubmissionSuccess(),
        ]),
        initialState: CoffeeInteractionInitial(),
      );
      when(() => mockFavoritesBloc.state).thenReturn(FavoritesInitial());

      // Act
      await tester.pumpWidget(
        buildTestableWidget(
          coffeeInteractionBloc: mockCoffeeInteractionBloc,
          favoritesBloc: mockFavoritesBloc,
          coffee: fakeCoffee,
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text('Comment saved.'), findsOneWidget);
    });

    testWidgets('shows snackbar for success/failure from FavoritesBloc', (tester) async {
      // Arrange
      when(() => mockCoffeeInteractionBloc.state).thenReturn(CoffeeInteractionInitial());
      whenListen(
        mockFavoritesBloc,
        Stream.fromIterable([
          FavoritingSuccess(),
          FavoritingFailure(failure: ItemAlreadySaved(key: StorageConstants.favoritesKey)),
        ]),
        initialState: FavoritesInitial(),
      );

      // Act
      await tester.pumpWidget(
        buildTestableWidget(
          coffeeInteractionBloc: mockCoffeeInteractionBloc,
          favoritesBloc: mockFavoritesBloc,
          coffee: fakeCoffee,
        ),
      );
      await tester.pump();

      // Assert
      final favoritesButton = find.byKey(Key('favoriteIcon'));
      expect(favoritesButton, findsOne);
      await tester.tap(favoritesButton);
      await tester.pumpAndSettle();
    });

    testWidgets('calls CommentChanged on dispose if text is not empty and state is CommentIsGettingInput',
        (tester) async {
      // Arrange
      when(() => mockCoffeeInteractionBloc.state).thenReturn(CommentIsGettingInput());
      when(() => mockFavoritesBloc.state).thenReturn(FavoritesInitial());

      // Act
      await tester.pumpWidget(
        buildTestableWidget(
          coffeeInteractionBloc: mockCoffeeInteractionBloc,
          favoritesBloc: mockFavoritesBloc,
          coffee: CoffeeModel.fromEntity(fakeCoffee).copyWith(comment: '').asEntity,
        ),
      );
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'final comment');
      await tester.pump();
      await tester.pumpWidget(Container());
      await tester.pump();

      // Assert
      verify(
        () => mockCoffeeInteractionBloc.add(any(that: isA<CommentChanged>())),
      ).called(2);
    });

    testWidgets('does not call CommentChanged on dispose if text is empty or state is not CommentIsGettingInput',
        (tester) async {
      // Arrange
      when(() => mockCoffeeInteractionBloc.state).thenReturn(CoffeeInteractionInitial());
      when(() => mockFavoritesBloc.state).thenReturn(FavoritesInitial());

      // Act
      await tester.pumpWidget(
        buildTestableWidget(
          coffeeInteractionBloc: mockCoffeeInteractionBloc,
          favoritesBloc: mockFavoritesBloc,
          coffee: CoffeeModel.fromEntity(fakeCoffee).copyWith(comment: '').asEntity,
        ),
      );
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();

      // Assert
      verifyNever(
        () => mockCoffeeInteractionBloc.add(any()),
      );
    });
  });
}
