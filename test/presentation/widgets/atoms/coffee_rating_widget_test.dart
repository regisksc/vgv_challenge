import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

void main() {
  testWidgets(
    'CoffeeRatingWidget displays 5 stars',
    (WidgetTester tester) async {
      // Arrange: Create a coffee with a specific rating.
      final coffee = Coffee(
        id: 'r1',
        imagePath: '/dummy/path',
        seenAt: DateTime(2025),
        rating: CoffeeRating.threeStars,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoffeeRatingWidget(coffee: coffee),
          ),
        ),
      );

      // Act: Use a predicate to find only the outer icons (size 25).
      final outerIcons = find.byWidgetPredicate((widget) {
        return widget is Icon && widget.size == 25;
      });

      // Assert: Expect exactly 5 icons of the outer type.
      expect(outerIcons, findsNWidgets(5));
    },
  );

  testWidgets(
    'CoffeeRatingWidget star tap prints debug message',
    (WidgetTester tester) async {
      // Arrange: Create a coffee with two stars.
      final coffee = Coffee(
        id: 'r2',
        imagePath: '/dummy/path',
        seenAt: DateTime(2025),
        rating: CoffeeRating.twoStars,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoffeeRatingWidget(coffee: coffee, canTap: true),
          ),
        ),
      );

      // Act: Tap on the first star.
      await tester.tap(find.byWidgetPredicate((widget) {
        return widget is Icon && widget.size == 25;
      }).first,);
      await tester.pump();
      // Assert: No errors should be thrown.
    },
  );
}
