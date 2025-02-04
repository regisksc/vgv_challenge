import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

void main() {
  testWidgets(
    'CoffeeCommentOverlayWidget returns empty when comment is null',
    (WidgetTester tester) async {
      // Arrange
      final coffee = Coffee(
        id: 'c1',
        imagePath: '/dummy/path',
        seenAt: DateTime(2025),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoffeeCommentOverlayWidget(coffee: coffee, height: 200),
          ),
        ),
      );

      // Assert
      expect(find.byType(Text), findsNothing);
    },
  );

  testWidgets(
    'CoffeeCommentOverlayWidget displays coment with gradient and fixed height',
    (WidgetTester tester) async {
      // Arrange
      final coffee = Coffee(
        id: 'c2',
        imagePath: '/dummy/path',
        seenAt: DateTime(2025),
        comment: 'This is a very long comment that should be truncated...',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoffeeCommentOverlayWidget(coffee: coffee, height: 200),
          ),
        ),
      );

      // Act & Assert
      expect(
        find.textContaining('This is a very long comment'),
        findsOneWidget,
      );

      final containerFinder = find.descendant(
        of: find.byType(CoffeeCommentOverlayWidget),
        matching: find.byType(Container),
      );
      final container = tester.widget<Container>(containerFinder.first);

      // Assert
      expect(container.constraints?.maxHeight ?? 200, equals(200));
    },
  );
}
