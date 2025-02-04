import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

void main() {
  Future<File> createTestImageFile() async {
    final file = File('${Directory.systemTemp.path}/test_bg.jpg');
    await file.writeAsBytes([0, 1, 2, 3, 4]);
    return file;
  }

  testWidgets(
    'CoffeeBackgroundWidget displays image if file exists',
    (WidgetTester tester) async {
      final file = await createTestImageFile();
      final coffee = Coffee(
        id: 'bg1',
        imagePath: file.path,
        seenAt: DateTime.now(),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoffeeBackgroundWidget(coffee: coffee, height: 400),
          ),
        ),
      );
      expect(find.byType(Image), findsOneWidget);
    },
  );

  testWidgets(
    'CoffeeBackgroundWidget is hidden if file does not exist',
    (WidgetTester tester) async {
      final coffee = Coffee(
        id: 'bg2',
        imagePath: '/non/existent/path.jpg',
        seenAt: DateTime.now(),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoffeeBackgroundWidget(coffee: coffee, height: 400),
          ),
        ),
      );
      expect(find.byType(Image), findsNothing);
    },
  );
}
