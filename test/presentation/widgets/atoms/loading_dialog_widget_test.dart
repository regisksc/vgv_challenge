import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

void main() {
  group('LoadingDialog', () {
    // ignore: lines_longer_than_80_chars
    testWidgets('should display CircularProgressIndicator', (WidgetTester tester) async {
      // Arrange
      const loadingDialog = LoadingDialog();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: loadingDialog,
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // ignore: lines_longer_than_80_chars
    testWidgets('LoadingDialog should be centered', (WidgetTester tester) async {
      // Arrange
      const loadingDialog = LoadingDialog();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: loadingDialog,
        ),
      );

      // Assert
      expect(find.byType(Center), findsOneWidget);
    });
  });
}
