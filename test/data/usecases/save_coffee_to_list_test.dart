import 'dart:convert';

import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  final faker = Faker();

  final intGen = faker.randomGenerator.integer(CoffeeRating.values.length);
  Coffee generateFakeCoffee() {
    return Coffee(
      id: faker.guid.guid(),
      imagePath: faker.internet.ipv6Address(),
      seenAt: DateTime.now(),
      isFavorite: faker.randomGenerator.boolean(),
      comment: faker.lorem.sentence(),
      rating: CoffeeRating.values[intGen],
    );
  }

  late MockStorage mockStorage;
  late SaveCoffeeToHistory saveCoffeeToHistory;
  late SaveCoffeeToFavorites saveCoffeeToFavorites;

  setUp(() {
    mockStorage = MockStorage();
    saveCoffeeToHistory = SaveCoffeeToHistory(storage: mockStorage);
    saveCoffeeToFavorites = SaveCoffeeToFavorites(storage: mockStorage);
  });

  group('SaveCoffeeToHistory', () {
    test('saves a new coffee when storage is empty', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async => Future.value());

      // Act
      final result = await saveCoffeeToHistory.call(coffee);

      // Assert
      expect(result.isSuccess, isTrue);

      final captured = verify(
        () => mockStorage.write(
          key: captureAny(named: 'key'),
          value: captureAny(named: 'value'),
        ),
      ).captured;

      expect(captured[0], equals('history'));

      final writtenValue = captured[1] as String;
      final decoded = jsonDecode(writtenValue) as List;
      // ignore: strict_raw_type
      expect(decoded, isA<List>());
      expect(decoded.length, equals(1));
      final savedCoffeeJson = decoded.first;
      // ignore: avoid_dynamic_calls
      expect(savedCoffeeJson['id'], equals(coffee.id));
    });

    // ignore: lines_longer_than_80_chars
    test('appends a new coffee when a list exists and does not exceed the limit', () async {
      // Arrange
      final initialList = List.generate(5, (_) {
        final fakeCoffee = generateFakeCoffee();
        return CoffeeModel.fromEntity(fakeCoffee).toJson();
      });
      final existingJson = jsonEncode(initialList);

      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => existingJson);
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async => Future.value());

      final newCoffee = generateFakeCoffee();

      // Act
      final result = await saveCoffeeToHistory.call(newCoffee);

      // Assert
      expect(result.isSuccess, isTrue);

      final captured = verify(
        () => mockStorage.write(
          key: captureAny(named: 'key'),
          value: captureAny(named: 'value'),
        ),
      ).captured;
      expect(captured[0], equals('history'));

      final writtenValue = captured[1] as String;
      final decoded = jsonDecode(writtenValue) as List;
      expect(decoded.length, equals(6));
      final lastItem = decoded.last as Map<String, dynamic>;
      expect(lastItem['id'], equals(newCoffee.id));
    });

    test('removes the oldest coffee when limit is exceeded', () async {
      // Arrange
      final now = DateTime.now();
      final initialList = List.generate(6, (index) {
        final coffee = generateFakeCoffee();
        final adjustedCoffee = Coffee(
          id: coffee.id,
          imagePath: coffee.imagePath,
          seenAt: now.subtract(Duration(minutes: 10 * (6 - index))),
          isFavorite: coffee.isFavorite,
          comment: coffee.comment,
          rating: coffee.rating,
        );
        return CoffeeModel.fromEntity(adjustedCoffee).toJson();
      });
      final existingJson = jsonEncode(initialList);

      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => existingJson);
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async => Future.value());

      final newCoffee = generateFakeCoffee();

      // Act
      final result = await saveCoffeeToHistory.call(newCoffee);

      // Assert
      expect(result.isSuccess, isTrue);

      final captured = verify(
        () => mockStorage.write(
          key: captureAny(named: 'key'),
          value: captureAny(named: 'value'),
        ),
      ).captured;
      expect(captured[0], equals('history'));

      final writtenValue = captured[1] as String;
      final decoded = jsonDecode(writtenValue) as List;
      expect(decoded.length, equals(6));
      final firstCoffee = decoded.first as Map<String, dynamic>;
      final initialOldestCoffee = (jsonDecode(
        existingJson,
      ) as List)
          .first as Map<String, dynamic>;
      expect(firstCoffee['id'], isNot(equals(initialOldestCoffee['id'])));
      final lastCoffee = decoded.last as Map<String, dynamic>;
      expect(lastCoffee['id'], equals(newCoffee.id));
    });

    test('returns a WritingFailure when storage.write throws', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenThrow(WritingFailure(key: 'history'));

      // Act
      final result = await saveCoffeeToHistory.call(coffee);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<WritingFailure>());
    });
  });

  group('SaveCoffeeToFavorites', () {
    test('saves a new coffee when storage is empty', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async => Future.value());

      // Act
      final result = await saveCoffeeToFavorites.call(coffee);

      // Assert
      expect(result.isSuccess, isTrue);
      final captured = verify(
        () => mockStorage.write(
          key: captureAny(named: 'key'),
          value: captureAny(named: 'value'),
        ),
      ).captured;
      expect(captured[0], equals('favorites'));
      final writtenValue = captured[1] as String;
      final decoded = jsonDecode(writtenValue) as List;
      expect(decoded.length, equals(1));
      final savedCoffeeJson = decoded.first as Map<String, dynamic>;
      expect(savedCoffeeJson['id'], equals(coffee.id));
      expect(savedCoffeeJson['isFavorite'], isTrue);
    });

    test('enforces favorites limit when appending a new coffee', () async {
      // Arrange
      final initialList = List.generate(2, (_) {
        final coffee = generateFakeCoffee();
        return CoffeeModel.fromEntity(coffee).toJson();
      });
      final existingJson = jsonEncode(initialList);

      when(
        () => mockStorage.read(
          key: any(named: 'key'),
        ),
      ).thenAnswer((_) async => existingJson);
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async => Future.value());

      final newCoffee = generateFakeCoffee();

      // Act
      final result = await saveCoffeeToFavorites.call(newCoffee);

      // Assert
      expect(result.isSuccess, isTrue);
      final captured = verify(
        () => mockStorage.write(
          key: captureAny(named: 'key'),
          value: captureAny(named: 'value'),
        ),
      ).captured;
      expect(captured[0], equals('favorites'));
      final writtenValue = captured[1] as String;
      final decoded = jsonDecode(writtenValue) as List;
      expect(decoded.length, equals(3));
      final lastCoffee = decoded.last as Map<String, dynamic>;
      expect(lastCoffee['id'], equals(newCoffee.id));
    });

    test('returns a ReadingFailure when storage.read throws', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      when(
        () => mockStorage.read(
          key: any(named: 'key'),
        ),
      ).thenThrow(ReadingFailure(key: 'favorites'));

      // Act
      final result = await saveCoffeeToFavorites.call(coffee);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ReadingFailure>());
    });

    test('throws WritingFailure when storage.read throws', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenThrow(WritingFailure(key: 'history'));

      // Act
      final result = await saveCoffeeToHistory.call(coffee);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<WritingFailure>());
    });

    test('handles invalid JSON from storage.read gracefully', () async {
      // Arrange
      when(
        () => mockStorage.read(
          key: any(named: 'key'),
        ),
      ).thenAnswer((_) async => 'invalid json');
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async => Future.value());

      final coffee = generateFakeCoffee();

      // Act
      final result = await saveCoffeeToHistory.call(coffee);

      // Assert
      expect(result.isSuccess, isTrue);
    });

    test('throws WritingFailure when storage.read throws', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      when(
        () => mockStorage.read(
          key: any(named: 'key'),
        ),
      ).thenThrow(WritingFailure(key: 'favorites'));

      // Act
      final result = await saveCoffeeToFavorites.call(coffee);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<WritingFailure>());
    });

    test('handles invalid JSON from storage.read gracefully', () async {
      // Arrange
      when(
        () => mockStorage.read(
          key: any(named: 'key'),
        ),
      ).thenAnswer((_) async => 'invalid json');
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async => Future.value());

      final coffee = generateFakeCoffee();

      // Act
      final result = await saveCoffeeToFavorites.call(coffee);

      // Assert
      expect(result.isSuccess, isTrue);
    });
  });
}
