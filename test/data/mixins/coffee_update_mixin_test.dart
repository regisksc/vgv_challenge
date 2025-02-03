import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

class MockStorage extends Mock implements Storage {}

class TestCoffeeUpdater extends UpdateCoffee with CoffeeUpdateHelper {
  TestCoffeeUpdater(this.storage);
  @override
  final Storage storage;

  @override
  Future<Result<Coffee, Failure>> call([UpdateCoffeeParams? params]) {
    throw UnimplementedError();
  }
}

void main() {
  late TestCoffeeUpdater updater;
  late MockStorage mockStorage;

  final testCoffee = CoffeeModel(
    id: '1',
    file: 'test.jpg',
    seenAt: DateTime(2025),
    comment: 'Original comment',
    rating: 3,
  );

  setUp(() {
    mockStorage = MockStorage();
    updater = TestCoffeeUpdater(mockStorage);
  });

  group('updateCoffeeIfPresent', () {
    test('successfully updates both comment and rating', () async {
      // Arrange
      const key = StorageConstants.favoritesKey;
      final jsonData = jsonEncode([testCoffee.toJson()]);
      when(
        () => mockStorage.read(
          key: any(named: 'key'),
        ),
      ).thenAnswer((_) async => jsonData);
      when(
        () => mockStorage.write(
          key: key,
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      // Act
      final result = await updater.updateCoffeeIfPresent(
        key: key,
        coffeeId: '1',
        newComment: 'Updated comment',
        newRating: CoffeeRating.fourStars,
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.successValue!.comment, 'Updated comment');
      expect(result.successValue!.rating, 4);

      final expectedJson = jsonEncode([
        testCoffee
            .copyWith(
              comment: 'Updated comment',
              rating: 4,
            )
            .toJson(),
      ]);
      verify(() => mockStorage.write(key: key, value: expectedJson)).called(1);
    });

    test('updates only comment when rating is not provided', () async {
      // Arrange
      const key = StorageConstants.favoritesKey;
      final jsonData = jsonEncode([testCoffee.toJson()]);
      when(
        () => mockStorage.read(
          key: any(named: 'key'),
        ),
      ).thenAnswer((_) async => jsonData);
      when(
        () => mockStorage.write(
          key: key,
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      // Act
      final result = await updater.updateCoffeeIfPresent(
        key: key,
        coffeeId: '1',
        newComment: 'Updated comment',
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.successValue!.comment, 'Updated comment');
      expect(result.successValue!.rating, testCoffee.rating);
    });

    test('updates only rating when comment is not provided', () async {
      // Arrange
      const key = StorageConstants.favoritesKey;
      final jsonData = jsonEncode([testCoffee.toJson()]);
      when(
        () => mockStorage.read(
          key: any(named: 'key'),
        ),
      ).thenAnswer((_) async => jsonData);
      when(
        () => mockStorage.write(
          key: key,
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      // Act
      final result = await updater.updateCoffeeIfPresent(
        key: key,
        coffeeId: '1',
        newRating: CoffeeRating.fiveStars,
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.successValue!.comment, testCoffee.comment);
      expect(result.successValue!.rating, 5);
    });

    test('=> LookedUpItemNotInListFailure when coffee not found', () async {
      // Arrange
      const key = StorageConstants.favoritesKey;
      final jsonData = jsonEncode([testCoffee.toJson()]);
      when(
        () => mockStorage.read(
          key: any(named: 'key'),
        ),
      ).thenAnswer((_) async => jsonData);

      // Act
      final result = await updater.updateCoffeeIfPresent(
        key: key,
        coffeeId: '2', // Non-existent ID
        newComment: 'Updated comment',
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<LookedUpItemNotInListFailure>());
    });

    test('returns ReadingFailure on storage read error', () async {
      // Arrange
      const key = StorageConstants.favoritesKey;
      when(
        () => mockStorage.read(
          key: any(named: 'key'),
        ),
      ).thenThrow(Exception('Read error'));

      // Act
      final result = await updater.updateCoffeeIfPresent(
        key: key,
        coffeeId: '1',
        newComment: 'Updated comment',
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ReadingFailure>());
    });

    test('returns ReadingFailure on storage write error', () async {
      // Arrange
      const key = StorageConstants.favoritesKey;
      final jsonData = jsonEncode([testCoffee.toJson()]);
      when(
        () => mockStorage.read(
          key: any(named: 'key'),
        ),
      ).thenAnswer((_) async => jsonData);
      when(
        () => mockStorage.write(
          key: key,
          value: any(named: 'value'),
        ),
      ).thenThrow(Exception('Write error'));

      // Act
      final result = await updater.updateCoffeeIfPresent(
        key: key,
        coffeeId: '1',
        newComment: 'Updated comment',
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ReadingFailure>());
    });
  });
}
