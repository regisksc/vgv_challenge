import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

void main() {
  group('WidgetExtensions', () {
    // ignore: lines_longer_than_80_chars
    testWidgets('overBlackBackground applies correct styling', (WidgetTester tester) async {
      // Arrange
      const testWidget = Text('Test');

      // Act
      final widgetWithBackground = testWidget.overBlackBackground();

      await tester.pumpWidget(
        MaterialApp(
          // Wrap with MaterialApp
          home: widgetWithBackground,
        ),
      );

      // Assert
      final container = find.byType(Container);
      expect(container, findsOneWidget);

      // ignore: lines_longer_than_80_chars
      final decoration = tester.widget<Container>(container).decoration! as BoxDecoration;
      expect(decoration.color, Colors.black45);
      expect(decoration.borderRadius, BorderRadius.circular(8));

      final padding = tester.widget<Container>(container).padding;
      expect(padding, const EdgeInsets.all(8));

      expect(find.text('Test'), findsOneWidget);
    });

    // ignore: lines_longer_than_80_chars
    testWidgets('overBlackBackground with custom padding', (WidgetTester tester) async {
      // Arrange
      const testWidget = Text('Test');

      // Act
      final widgetWithBackground = testWidget.overBlackBackground(padding: 16);

      await tester.pumpWidget(
        MaterialApp(
          home: widgetWithBackground,
        ),
      );

      // Assert
      final container = find.byType(Container);
      expect(container, findsOneWidget);

      final padding = tester.widget<Container>(container).padding;
      expect(padding, const EdgeInsets.all(16)); // Custom padding
    });

    // ignore: lines_longer_than_80_chars
    testWidgets('copyWithColor applies correct color', (WidgetTester tester) async {
      // Arrange
      const testIcon = Icon(Icons.star);

      // Act
      final coloredIcon = testIcon.copyWithColor(Colors.red);

      await tester.pumpWidget(
        MaterialApp(home: coloredIcon),
      );

      // Assert
      final iconTheme = find.byKey(const ValueKey('copyWithColorIconTheme'));
      expect(iconTheme, findsOneWidget);

      final iconThemeData = tester.widget<IconTheme>(iconTheme).data;
      expect(iconThemeData.color, Colors.red);
    });

    testWidgets('copyWithColor with null color', (WidgetTester tester) async {
      // Arrange
      const testIcon = Icon(Icons.star);

      // Act
      final coloredIcon = testIcon.copyWithColor(null);

      await tester.pumpWidget(
        MaterialApp(
          home: coloredIcon,
        ),
      );

      // Assert
      final iconTheme = find.byKey(const ValueKey('copyWithColorIconTheme'));
      expect(iconTheme, findsOneWidget);

      final iconThemeData = tester.widget<IconTheme>(iconTheme).data;
      expect(iconThemeData.color, null);
    });
  });
}
