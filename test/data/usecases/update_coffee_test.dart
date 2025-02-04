import 'dart:convert';

import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  final faker = Faker();

  Coffee generateFakeCoffee() {
    return Coffee(
      id: faker.guid.guid(),
      imagePath: faker.internet.httpsUrl(),
      seenAt: DateTime.now(),
      isFavorite: faker.randomGenerator.boolean(),
      comment: faker.lorem.sentence(),
      rating: CoffeeRating.values[faker.randomGenerator.integer(
        CoffeeRating.values.length,
        min: faker.randomGenerator.integer(5),
      )],
    );
  }

  CoffeeModel generateCoffeeModel(Coffee coffee) {
    return CoffeeModel.fromEntity(coffee);
  }

  String generateJsonFromList(List<CoffeeModel> models) {
    final list = models.map((model) => model.toJson()).toList();
    return jsonEncode(list);
  }

  late MockStorage mockStorage;
  late RateCoffee rateCoffee;
  late CommentCoffee commentCoffee;

  setUp(() {
    mockStorage = MockStorage();
    rateCoffee = RateCoffee(storage: mockStorage);
    commentCoffee = CommentCoffee(storage: mockStorage);
  });

  group('RateCoffee', () {
    // ignore: lines_longer_than_80_chars
    test('returns Result.failure(UnexpectedInputFailure()) when params is null', () async {
      // Act
      final result = await rateCoffee.call();

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<UnexpectedInputFailure>());
    });

    // ignore: lines_longer_than_80_chars
    test('returns Result.failure(UnexpectedInputFailure()) when newRating is null', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      final params = UpdateCoffeeParams(coffee: coffee);

      // Act
      final result = await rateCoffee.call(params);

      // Act & Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<UnexpectedInputFailure>());
    });

    // ignore: lines_longer_than_80_chars
    test('returns failure if update fails in favorites with non-LookedUpItemNotInListFailure', () async {
      // Arrange
      when(
        () => mockStorage.read(key: StorageConstants.favoritesKey),
      ).thenThrow(Exception('Favorites read error'));
      when(
        () => mockStorage.read(key: StorageConstants.historyKey),
      ).thenAnswer((_) async => generateJsonFromList([]));

      final coffee = generateFakeCoffee();
      final params = UpdateCoffeeParams(
        coffee: coffee,
        newRating: CoffeeRating.fiveStars,
      );

      // Act
      final result = await rateCoffee.call(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ReadingFailure>());
    });

    // ignore: lines_longer_than_80_chars
    test('returns failure if update fails in history with non-LookedUpItemNotInListFailure', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      final coffeeModel = generateCoffeeModel(coffee);

      when(() => mockStorage.read(key: StorageConstants.favoritesKey))
          .thenAnswer((_) async => generateJsonFromList([coffeeModel]));
      when(
        () => mockStorage.read(key: StorageConstants.historyKey),
      ).thenThrow(Exception('History read error'));
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      final params = UpdateCoffeeParams(
        coffee: coffee,
        newRating: CoffeeRating.fourStars,
      );

      // Act
      final result = await rateCoffee.call(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ReadingFailure>());
    });

    // ignore: lines_longer_than_80_chars
    test('returns ItemNeverStoredFailure when coffee not found in both lists', () async {
      // Arrange
      when(() => mockStorage.read(key: StorageConstants.favoritesKey))
          .thenAnswer((_) async => generateJsonFromList([]));
      when(
        () => mockStorage.read(key: StorageConstants.historyKey),
      ).thenAnswer((_) async => generateJsonFromList([]));

      final coffee = generateFakeCoffee();
      final params = UpdateCoffeeParams(
        coffee: coffee,
        newRating: CoffeeRating.threeStars,
      );

      // Act
      final result = await rateCoffee.call(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ItemNeverStoredFailure>());
    });

    test('returns updated coffee from favorites if available', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      final coffeeModel = generateCoffeeModel(coffee);

      when(() => mockStorage.read(key: StorageConstants.favoritesKey))
          .thenAnswer((_) async => generateJsonFromList([coffeeModel]));
      when(
        () => mockStorage.read(key: StorageConstants.historyKey),
      ).thenAnswer((_) async => generateJsonFromList([]));
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      final params = UpdateCoffeeParams(
        coffee: coffee,
        newRating: CoffeeRating.fiveStars,
      );

      // Act
      final result = await rateCoffee.call(params);

      // Assert
      expect(result.isSuccess, isTrue);
      final updatedCoffee = result.successValue!;
      expect(updatedCoffee.rating, equals(CoffeeRating.fiveStars));
    });

    // ignore: lines_longer_than_80_chars
    test('returns updated coffee from history if favorites not updated', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      final coffeeModel = generateCoffeeModel(coffee);

      when(() => mockStorage.read(key: StorageConstants.favoritesKey))
          .thenAnswer((_) async => generateJsonFromList([]));
      when(() => mockStorage.read(key: StorageConstants.historyKey))
          .thenAnswer((_) async => generateJsonFromList([coffeeModel]));
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      final params = UpdateCoffeeParams(
        coffee: coffee,
        newRating: CoffeeRating.threeStars,
      );

      // Act
      final result = await rateCoffee.call(params);

      // Assert
      expect(result.isSuccess, isTrue);
      final updatedCoffee = result.successValue!;
      expect(updatedCoffee.rating, equals(CoffeeRating.threeStars));
    });

    // ignore: lines_longer_than_80_chars
    test('returns ReadingFailure when an unexpected exception is thrown', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      final coffeeModel = generateCoffeeModel(coffee);

      when(() => mockStorage.read(key: StorageConstants.favoritesKey))
          .thenAnswer((_) async => generateJsonFromList([coffeeModel]));
      when(() => mockStorage.read(key: StorageConstants.historyKey))
          .thenAnswer((_) async => generateJsonFromList([coffeeModel]));
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenThrow(Exception('Write error'));

      final params = UpdateCoffeeParams(
        coffee: coffee,
        newRating: CoffeeRating.fiveStars,
      );

      // Act
      final result = await rateCoffee.call(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ReadingFailure>());
    });
  });

  group('CommentCoffee', () {
    test('returns Result.failure(UnexpectedInputFailure()) when params is null', () async {
      // Act
      final result = await rateCoffee.call();

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<UnexpectedInputFailure>());
    });

    // ignore: lines_longer_than_80_chars
    test('returns Result.failure(UnexpectedInputFailure()) when newComment is null', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      final params = UpdateCoffeeParams(coffee: coffee);

      // Act
      final result = await rateCoffee.call(params);

      // Act & Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<UnexpectedInputFailure>());
    });

    // ignore: lines_longer_than_80_chars
    test('returns failure if update fails in favorites with non-LookedUpItemNotInListFailure', () async {
      // Arrange
      when(
        () => mockStorage.read(key: StorageConstants.favoritesKey),
      ).thenThrow(Exception('Favorites read error'));
      when(
        () => mockStorage.read(key: StorageConstants.historyKey),
      ).thenAnswer((_) async => generateJsonFromList([]));

      final coffee = generateFakeCoffee();
      final params = UpdateCoffeeParams(
        coffee: coffee,
        newComment: faker.lorem.sentence(),
      );

      // Act
      final result = await commentCoffee.call(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ReadingFailure>());
    });

    // ignore: lines_longer_than_80_chars
    test('returns failure if update fails in history with non-LookedUpItemNotInListFailure', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      final coffeeModel = generateCoffeeModel(coffee);

      when(() => mockStorage.read(key: StorageConstants.favoritesKey))
          .thenAnswer((_) async => generateJsonFromList([coffeeModel]));
      when(
        () => mockStorage.read(key: StorageConstants.historyKey),
      ).thenThrow(Exception('History read error'));
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      final params = UpdateCoffeeParams(
        coffee: coffee,
        newComment: faker.lorem.sentence(),
      );

      // Act
      final result = await commentCoffee.call(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ReadingFailure>());
    });

    // ignore: lines_longer_than_80_chars
    test('returns ItemNeverStoredFailure when coffee not found in both lists', () async {
      // Arrange
      when(() => mockStorage.read(key: StorageConstants.favoritesKey))
          .thenAnswer((_) async => generateJsonFromList([]));
      when(
        () => mockStorage.read(key: StorageConstants.historyKey),
      ).thenAnswer((_) async => generateJsonFromList([]));

      final coffee = generateFakeCoffee();
      final params = UpdateCoffeeParams(
        coffee: coffee,
        newComment: faker.lorem.sentence(),
      );

      // Act
      final result = await commentCoffee.call(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ItemNeverStoredFailure>());
    });

    test('returns updated coffee from favorites if available', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      final coffeeModel = generateCoffeeModel(coffee);

      when(() => mockStorage.read(key: StorageConstants.favoritesKey))
          .thenAnswer((_) async => generateJsonFromList([coffeeModel]));
      when(
        () => mockStorage.read(key: StorageConstants.historyKey),
      ).thenAnswer((_) async => generateJsonFromList([]));
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      final newComment = faker.lorem.sentence();
      final params = UpdateCoffeeParams(coffee: coffee, newComment: newComment);

      // Act
      final result = await commentCoffee.call(params);

      // Assert
      expect(result.isSuccess, isTrue);
      final updatedCoffee = result.successValue!;
      expect(updatedCoffee.comment, equals(newComment));
    });

    // ignore: lines_longer_than_80_chars
    test('returns updated coffee from history if favorites not updated', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      final coffeeModel = generateCoffeeModel(coffee);

      when(() => mockStorage.read(key: StorageConstants.favoritesKey))
          .thenAnswer((_) async => generateJsonFromList([]));
      when(() => mockStorage.read(key: StorageConstants.historyKey))
          .thenAnswer((_) async => generateJsonFromList([coffeeModel]));
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      final newComment = faker.lorem.sentence();
      final params = UpdateCoffeeParams(coffee: coffee, newComment: newComment);

      // Act
      final result = await commentCoffee.call(params);

      // Assert
      expect(result.isSuccess, isTrue);
      final updatedCoffee = result.successValue!;
      expect(updatedCoffee.comment, equals(newComment));
    });

    // ignore: lines_longer_than_80_chars
    test('returns ReadingFailure when an unexpected exception is thrown', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      final coffeeModel = generateCoffeeModel(coffee);

      when(() => mockStorage.read(key: StorageConstants.favoritesKey))
          .thenAnswer((_) async => generateJsonFromList([coffeeModel]));
      when(() => mockStorage.read(key: StorageConstants.historyKey))
          .thenAnswer((_) async => generateJsonFromList([coffeeModel]));
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenThrow(Exception('Write error'));

      final params = UpdateCoffeeParams(
        coffee: coffee,
        newComment: faker.lorem.sentence(),
      );

      // Act
      final result = await commentCoffee.call(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ReadingFailure>());
    });
  });
}
