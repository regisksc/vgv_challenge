import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

import '../../../helpers/mocks.dart';

void main() {
  late UpdateCoffee commentCoffeeMock;
  late UpdateCoffee rateCoffeeMock;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await sl.reset();

    commentCoffeeMock = CommentCoffeeMock();
    rateCoffeeMock = RateCoffeeMock();
  });

  Future<void> pumpWidget(WidgetTester tester, {required Widget widget}) async {
    sl
      ..registerSingleton<UpdateCoffee>(
        commentCoffeeMock,
        instanceName: 'commentCoffee',
      )
      ..registerSingleton<UpdateCoffee>(
        rateCoffeeMock,
        instanceName: 'rateCoffee',
      );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<CoffeeInteractionBloc>(
            create: (context) => CoffeeInteractionBloc(
              commentCoffee: sl.get(instanceName: 'commentCoffee'),
              rateCoffee: sl.get(instanceName: 'rateCoffee'),
            ),
          ),
        ],
        child: MaterialApp(home: widget),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  testWidgets(
    'CoffeeRatingWidget displays 5 stars',
    (WidgetTester tester) async {
      // Arrange
      final coffee = Coffee(
        id: 'r1',
        imagePath: '/dummy/path',
        seenAt: DateTime(2025),
        rating: CoffeeRating.threeStars,
      );

      await pumpWidget(
        tester,
        widget: MaterialApp(
          home: Scaffold(
            body: CoffeeRatingWidget(coffee: coffee),
          ),
        ),
      );

      // Act
      final outerIcons = find.byWidgetPredicate((widget) {
        return widget is Icon && widget.size == 25;
      });

      // Assert
      expect(outerIcons, findsNWidgets(5));
    },
  );

  testWidgets(
    'CoffeeRatingWidget star tap prints debug message',
    (WidgetTester tester) async {
      // Arrange
      final coffee = Coffee(
        id: 'r2',
        imagePath: '/dummy/path',
        seenAt: DateTime(2025),
        rating: CoffeeRating.twoStars,
      );

      when(() => rateCoffeeMock.call(any())).thenAnswer(
        (_) => Future.value(
          const Result.success(null),
        ),
      );

      await pumpWidget(
        tester,
        widget: MaterialApp(
          home: Scaffold(
            body: CoffeeRatingWidget(coffee: coffee, canTap: true),
          ),
        ),
      );

      // Act
      await tester.tap(
        find.byWidgetPredicate((widget) {
          return widget is Icon && widget.size == 22;
        }).first,
      );
      await tester.pump();

      // Assert
    },
  );
}
