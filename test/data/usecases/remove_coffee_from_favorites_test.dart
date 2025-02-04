// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  late RemoveCoffeeFromFavorites usecase;
  late MockStorage mockStorage;

  setUp(() {
    mockStorage = MockStorage();
    usecase = RemoveCoffeeFromFavorites(storage: mockStorage);
  });

  final testCoffee = Coffee(
    id: 'id',
    imagePath: 'path',
    seenAt: DateTime.now(),
  );

  CoffeeModel testCoffeeModel() => CoffeeModel.fromEntity(testCoffee);

  group('RemoveCoffeeFromFavorites', () {
    group('when coffee is in favorites', () {
      final mockCoffeeList = [testCoffeeModel()];
      final initialJson = jsonEncode(
        mockCoffeeList.map((e) => e.toJson()).toList(),
      );
      final updatedJson = jsonEncode([]);

      setUp(() {
        // Arrange
        when(
          () => mockStorage.read(key: StorageConstants.favoritesKey),
        ).thenAnswer((_) async => initialJson);
        when(
          () => mockStorage.write(
            key: StorageConstants.favoritesKey,
            value: updatedJson,
          ),
        ).thenAnswer((_) async => Future.value());
      });

      test('should remove coffee and return success', () async {
        // Act
        final result = await usecase(testCoffee);

        // Assert
        expect(result.isSuccess, isTrue);
        verify(
          () => mockStorage.read(key: StorageConstants.favoritesKey),
        ).called(1);
        verify(
          () => mockStorage.write(
            key: StorageConstants.favoritesKey,
            value: updatedJson,
          ),
        ).called(1);
      });
    });

    group('when coffee is not in favorites', () {
      final emptyList = <CoffeeModel>[];
      final initialJson = jsonEncode(emptyList.map((e) => e.toJson()).toList());

      setUp(() {
        when(
          () => mockStorage.read(key: StorageConstants.favoritesKey),
        ).thenAnswer((_) async => initialJson);
      });

      test('should not modify storage and return success', () async {
        final result = await usecase(testCoffee);

        expect(result.isSuccess, isFalse);
        verify(
          () => mockStorage.read(key: StorageConstants.favoritesKey),
        ).called(1);
        verifyNever(
          () => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        );
      });
    });

    group('failure cases', () {
      test('should handle read errors', () async {
        // Arrange
        when(
          () => mockStorage.read(key: 'StorageConstants.favoritesKey'),
        ).thenThrow(Exception('Read error'));

        final result = await usecase(testCoffee);

        expect(result.isFailure, isTrue);
        expect(result.failure, isA<ReadingOrWritingFailure>());
      });

      test('should handle write errors', () async {
        // Arrange
        when(() => mockStorage.read(key: StorageConstants.favoritesKey))
            .thenAnswer((_) async => jsonEncode([testCoffeeModel().toJson()]));
        when(
          () => mockStorage.write(
            key: StorageConstants.favoritesKey,
            value: any(named: 'value'),
          ),
        ).thenThrow(Exception('Write error'));

        // Act
        final result = await usecase(testCoffee);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<ReadingOrWritingFailure>());
      });

      // ignore: lines_longer_than_80_chars
      test('should return UnexpectedInputFailure when params is null', () async {
        final result = await usecase();

        expect(result.isFailure, isTrue);
        expect(result.failure, isA<UnexpectedInputFailure>());
      });
    });
  });
}
