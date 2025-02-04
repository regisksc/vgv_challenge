import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

void main() {
  testWidgets(
    'CoffeeBookLogoWidget renders with correct style',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CoffeeBookLogoWidget()),
        ),
      );
      expect(find.text('Coffeebook'), findsOneWidget);
      final logoWidget = tester.widget<Container>(find.byType(Container));
      expect((logoWidget.decoration! as BoxDecoration).color, isNotNull);
    },
  );
}
