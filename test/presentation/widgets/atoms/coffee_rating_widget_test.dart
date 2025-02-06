// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

import '../../screens/main/bloc/main_screen_bloc_test.dart';

class MockCoffeeInteractionBloc extends MockBloc<CoffeeInteractionEvent, CoffeeInteractionState>
    implements CoffeeInteractionBloc {}

class FakeCoffeeInteractionEvent extends Fake implements CoffeeInteractionEvent {}

class FakeCoffeeInteractionState extends Fake implements CoffeeInteractionState {}

void main() {
  late CoffeeInteractionBloc coffeeInteractionBloc;

  setUpAll(() {
    registerFallbackValue(FakeCoffeeInteractionEvent());
    registerFallbackValue(FakeCoffeeInteractionState());
  });

  setUp(() {
    coffeeInteractionBloc = MockCoffeeInteractionBloc();
  });

  group('CoffeeRatingWidget', () {
    final testCoffee = Coffee(
      id: 'test1',
      imagePath: '/test/path.png',
      seenAt: DateTime.now(),
      rating: CoffeeRating.twoStars,
    );

    testWidgets('displays correct stars initially', (tester) async {
      when(() => coffeeInteractionBloc.state).thenReturn(CoffeeInteractionInitial());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CoffeeInteractionBloc>.value(
            value: coffeeInteractionBloc,
            child: Scaffold(
              body: CoffeeRatingWidget(coffee: testCoffee, canTap: true),
            ),
          ),
        ),
      );
      final filledStarFinder = find.descendant(
        of: find.byType(CoffeeRatingWidget),
        matching:
            find.byWidgetPredicate((widget) => widget is Icon && widget.size == 22 && widget.color == Colors.amber),
      );
      final unfilledStarFinder = find.descendant(
        of: find.byType(CoffeeRatingWidget),
        matching: find
            .byWidgetPredicate((widget) => widget is Icon && widget.size == 22 && widget.color == Colors.brown[100]),
      );
      expect(filledStarFinder, findsNWidgets(2));
      expect(unfilledStarFinder, findsNWidgets(3));
    });

    testWidgets('shows loading dialog then updates stars on rating success', (tester) async {
      final controller = StreamController<CoffeeInteractionState>();
      coffeeInteractionBloc = MockCoffeeInteractionBloc();
      when(() => coffeeInteractionBloc.state).thenReturn(CoffeeInteractionInitial());
      whenListen(coffeeInteractionBloc, controller.stream);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CoffeeInteractionBloc>.value(
            value: coffeeInteractionBloc,
            child: Scaffold(
              body: CoffeeRatingWidget(coffee: testCoffee, canTap: true),
            ),
          ),
        ),
      );

      final starFinder = find
          .descendant(
            of: find.byType(CoffeeRatingWidget),
            matching: find.byWidgetPredicate((widget) => widget is Icon && widget.size == 22),
          )
          .at(3);
      final center = tester.getCenter(starFinder);
      await tester.tapAt(center);
      await tester.pump();

      controller.add(RatingSubmissionInProgress());
      await tester.pump();

      controller.add(RatingSubmissionSuccess(rating: CoffeeRating.fourStars));
      await tester.pumpAndSettle();

      expect(find.byType(LoadingDialog), findsNothing);
      final filledStarFinder = find.descendant(
        of: find.byType(CoffeeRatingWidget),
        matching:
            find.byWidgetPredicate((widget) => widget is Icon && widget.size == 22 && widget.color == Colors.amber),
      );
      final unfilledStarFinder = find.descendant(
        of: find.byType(CoffeeRatingWidget),
        matching: find
            .byWidgetPredicate((widget) => widget is Icon && widget.size == 22 && widget.color == Colors.brown[100]),
      );
      expect(filledStarFinder, findsNWidgets(4));
      expect(unfilledStarFinder, findsNWidgets(1));

      await controller.close();
    });

    testWidgets('shows loading dialog then snack bar on rating failure', (tester) async {
      final controller = StreamController<CoffeeInteractionState>();
      coffeeInteractionBloc = MockCoffeeInteractionBloc();
      when(() => coffeeInteractionBloc.state).thenReturn(CoffeeInteractionInitial());
      whenListen(coffeeInteractionBloc, controller.stream);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CoffeeInteractionBloc>.value(
            value: coffeeInteractionBloc,
            child: Scaffold(
              body: CoffeeRatingWidget(coffee: testCoffee, canTap: true),
            ),
          ),
        ),
      );

      final starFinder = find
          .descendant(
            of: find.byType(CoffeeRatingWidget),
            matching: find.byWidgetPredicate((widget) => widget is Icon && widget.size == 22),
          )
          .at(3);
      final center = tester.getCenter(starFinder);
      await tester.tapAt(center);
      await tester.pump();

      controller.add(RatingSubmissionInProgress());
      await tester.pump();

      controller.add(RatingSubmissionFailure(failure: FakeFailure()));
      await tester.pumpAndSettle();

      expect(find.byType(LoadingDialog), findsNothing);
      expect(find.text('Rating failed'), findsOneWidget);

      await controller.close();
    });
  });
}
