// File: test/data/hive_storage_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/data/persistency/persistency.dart';

class MockBox extends Mock implements Box<String> {}

void main() {
  late MockBox mockBox;
  late HiveStorage hiveStorage;

  setUp(() {
    mockBox = MockBox();
    hiveStorage = HiveStorage(box: mockBox);
  });

  group('HiveStorage.read', () {
    test('returns the stored value when box.get succeeds', () async {
      // Arrange
      when(() => mockBox.get('myKey')).thenReturn('someValue');

      // Act
      final result = await hiveStorage.read(key: 'myKey');

      // Assert
      expect(result, equals('someValue'));
      verify(() => mockBox.get('myKey')).called(1);
    });

    test('throws ReadingFailure when box.get throws', () async {
      // Arrange
      when(() => mockBox.get('myKey')).thenThrow(Exception('Hive get error'));

      // Act & Assert
      expect(
        () => hiveStorage.read(key: 'myKey'),
        throwsA(isA<ReadingFailure>()),
      );
      verify(() => mockBox.get('myKey')).called(1);
    });
  });

  group('HiveStorage.write', () {
    test('succeeds when box.put works', () async {
      // Arrange
      when(() => mockBox.put('myKey', 'myValue')).thenAnswer((_) async => {});

      // Act
      await hiveStorage.write(key: 'myKey', value: 'myValue');

      // Assert
      verify(() => mockBox.put('myKey', 'myValue')).called(1);
    });

    test('throws WritingFailure when box.put throws', () async {
      // Arrange
      when(
        () => mockBox.put('myKey', 'myValue'),
      ).thenThrow(Exception('Hive put error'));

      // Act & Assert
      expect(
        () => hiveStorage.write(key: 'myKey', value: 'myValue'),
        throwsA(isA<WritingFailure>()),
      );
      verify(() => mockBox.put('myKey', 'myValue')).called(1);
    });
  });
}
