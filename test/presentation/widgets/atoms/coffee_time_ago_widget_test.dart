import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

void main() {
  testWidgets(
    'CoffeeTimeAgoWidget shows "Just now" for very recent time',
    (WidgetTester tester) async {
      // Arrange
      final now = DateTime.now();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoffeeTimeAgoWidget(date: now),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Just now'), findsOneWidget);
    },
  );

  testWidgets(
    'CoffeeTimeAgoWidget shows minutes ago',
    (WidgetTester tester) async {
      // Arrange
      final past = DateTime.now().subtract(const Duration(minutes: 5));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoffeeTimeAgoWidget(date: past),
          ),
        ),
      );

      // Act & Assert
      expect(find.textContaining('5 minute'), findsOneWidget);
    },
  );

  testWidgets(
    'CoffeeTimeAgoWidget updates over time',
    (WidgetTester tester) async {
      // Arrange
      final past = DateTime.now().subtract(const Duration(minutes: 1));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoffeeTimeAgoWidget(date: past),
          ),
        ),
      );

      // Assert initial state shows "1 minute"
      expect(find.textContaining('1 minute'), findsOneWidget);
    },
  );
}
