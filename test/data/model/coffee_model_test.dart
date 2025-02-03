import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

void main() {
  final faker = Faker();

  group('CoffeeModel', () {
    test('fromJson creates CoffeeModel from local JSON correctly', () {
      // Arrange
      final id = faker.guid.guid();
      final file = faker.internet.httpsUrl();
      final seenAt = faker.date.dateTime(minYear: 2025, maxYear: 2025);
      final isFavorite = faker.randomGenerator.boolean();
      final comment = faker.lorem.sentence();
      final rating = faker.randomGenerator.integer(6); // 0 to 5

      final localJson = {
        'id': id,
        'file': file,
        'seenAt': seenAt.toIso8601String(),
        'isFavorite': isFavorite,
        'comment': comment,
        'rating': rating,
      };

      // Act
      final coffeeModel = CoffeeModel.fromJson(localJson);

      // Assert
      expect(coffeeModel.id, id);
      expect(coffeeModel.file, file);
      expect(coffeeModel.seenAt, seenAt);
      expect(coffeeModel.isFavorite, isFavorite);
      expect(coffeeModel.comment, comment);
      expect(coffeeModel.rating, rating);
    });

    test('fromJson creates CoffeeModel from remote JSON correctly', () {
      // Arrange
      final file = faker.internet.httpsUrl();
      final remoteJson = {
        'file': file,
      };

      // Act
      final coffeeModel = CoffeeModel.fromJson(remoteJson);

      // Assert
      expect(coffeeModel.id, isNotEmpty);
      expect(coffeeModel.file, file);
      expect(coffeeModel.seenAt.isUtc, true);
      expect(coffeeModel.isFavorite, false);
      expect(coffeeModel.comment, isNull);
      expect(coffeeModel.rating, 0);
    });

    test('fromJson assigns default values correctly when keys are missing', () {
      // Arrange
      final file = faker.internet.httpsUrl();
      final incompleteJson = {
        'file': file,
        // 'seenAt' is missing
        // 'isFavorite' is missing
        // 'comment' is missing
        // 'rating' is missing
      };

      // Act
      final coffeeModel = CoffeeModel.fromJson(incompleteJson);

      // Assert
      expect(coffeeModel.id, isNotEmpty);
      expect(coffeeModel.file, file);
      expect(coffeeModel.seenAt.isUtc, true);
      expect(coffeeModel.isFavorite, false);
      expect(coffeeModel.comment, isNull);
      expect(coffeeModel.rating, 0);
    });

    test('toJson serializes CoffeeModel correctly', () {
      // Arrange
      final id = faker.guid.guid();
      final file = faker.internet.httpsUrl();
      final seenAt = faker.date.dateTime(minYear: 2025, maxYear: 2025);
      final isFavorite = faker.randomGenerator.boolean();
      final comment = faker.lorem.sentence();
      final rating = faker.randomGenerator.integer(6); // 0 to 5

      final coffeeModel = CoffeeModel(
        id: id,
        file: file,
        seenAt: seenAt,
        isFavorite: isFavorite,
        comment: comment,
        rating: rating,
      );

      // Act
      final json = coffeeModel.toJson();

      // Assert
      expect(json, {
        'id': id,
        'file': file,
        'seenAt': seenAt.toIso8601String(),
        'isFavorite': isFavorite,
        'comment': comment,
        'rating': rating,
      });
    });

    test('asEntity converts CoffeeModel to Coffee correctly', () {
      // Arrange
      final id = faker.guid.guid();
      final file = faker.internet.httpsUrl();
      final seenAt = faker.date.dateTime(minYear: 2025, maxYear: 2025);
      final isFavorite = faker.randomGenerator.boolean();
      final comment = faker.lorem.sentence();
      final rating = faker.randomGenerator.integer(6); // 0 to 5

      final coffeeModel = CoffeeModel(
        id: id,
        file: file,
        seenAt: seenAt,
        isFavorite: isFavorite,
        comment: comment,
        rating: rating,
      );

      // Act
      final coffee = coffeeModel.asEntity;

      // Assert
      expect(coffee.id, id);
      expect(coffee.imagePath, file);
      expect(coffee.seenAt, seenAt);
      expect(coffee.isFavorite, isFavorite);
      expect(coffee.comment, comment);
      expect(coffee.rating, CoffeeRating.values[rating]);
    });

    test('fromEntity creates CoffeeModel from Coffee correctly', () {
      // Arrange
      final id = faker.guid.guid();
      final file = faker.internet.httpsUrl();
      final seenAt = faker.date.dateTime(minYear: 2025, maxYear: 2025);
      final isFavorite = faker.randomGenerator.boolean();
      final comment = faker.lorem.sentence();
      final ratingEnum = CoffeeRating.values[faker.randomGenerator.integer(6)];

      final coffeeEntity = Coffee(
        id: id,
        imagePath: file,
        seenAt: seenAt,
        isFavorite: isFavorite,
        comment: comment,
        rating: ratingEnum,
      );

      // Act
      final coffeeModel = CoffeeModel.fromEntity(coffeeEntity);

      // Assert
      expect(coffeeModel.id, id);
      expect(coffeeModel.file, file);
      expect(coffeeModel.seenAt, seenAt);
      expect(coffeeModel.isFavorite, isFavorite);
      expect(coffeeModel.comment, comment);
      expect(coffeeModel.rating, ratingEnum.intValue);
    });

    test('equality works correctly', () {
      // Arrange
      final id = faker.guid.guid();
      final file = faker.internet.httpsUrl();
      final seenAt = faker.date.dateTime(minYear: 2025, maxYear: 2025);
      final isFavorite = faker.randomGenerator.boolean();
      final comment = faker.lorem.sentence();
      final rating = faker.randomGenerator.integer(6); // 0 to 5

      final coffeeModel1 = CoffeeModel(
        id: id,
        file: file,
        seenAt: seenAt,
        isFavorite: isFavorite,
        comment: comment,
        rating: rating,
      );

      final coffeeModel2 = CoffeeModel(
        id: id,
        file: file,
        seenAt: seenAt,
        isFavorite: isFavorite,
        comment: comment,
        rating: rating,
      );

      final coffeeModel3 = CoffeeModel(
        id: faker.guid.guid(),
        file: faker.internet.httpsUrl(),
        seenAt: faker.date.dateTime(minYear: 2025, maxYear: 2025),
        comment: faker.lorem.sentence(),
      );

      // Act & Assert
      expect(coffeeModel1, equals(coffeeModel2));
      expect(coffeeModel1, isNot(equals(coffeeModel3)));
    });

    group('CoffeeModel copyWith', () {
      // Arrange
      final now = DateTime.now().toUtc();
      final coffeeModel = CoffeeModel(
        id: 'test-id',
        file: 'test-file.jpg',
        seenAt: now,
        isFavorite: true,
        comment: 'test comment',
        rating: 4,
      );

      test('should create a new CoffeeModel with updated values', () {
        // Act
        final newCoffeeModel = coffeeModel.copyWith(
          file: 'new-file.png',
          isFavorite: false,
          rating: 2,
        );

        // Assert
        expect(newCoffeeModel.id, 'test-id');
        expect(newCoffeeModel.file, 'new-file.png');
        expect(newCoffeeModel.seenAt, now);
        expect(newCoffeeModel.isFavorite, false);
        expect(newCoffeeModel.comment, 'test comment');
        expect(newCoffeeModel.rating, 2);
      });

      test('should return a new object', () {
        // Act
        final newCoffeeModel = coffeeModel.copyWith();

        // Assert
        expect(identical(coffeeModel, newCoffeeModel), false);
      });

      test('should return the same object if no values are changed', () {
        // Act
        final newCoffeeModel = coffeeModel.copyWith();

        // Assert
        expect(identical(coffeeModel, newCoffeeModel), false);
        expect(coffeeModel == newCoffeeModel, true);
      });

      test('should handle null values correctly', () {
        // Arrange
        final coffeeModelCommentBefore = coffeeModel.comment;

        // Act
        // ignore: avoid_redundant_argument_values
        final newCoffeeModel = coffeeModel.copyWith(comment: null);

        // Assert
        expect(newCoffeeModel.comment, coffeeModelCommentBefore);
      });
    });
  });

  group('CoffeeModelListExtension', () {
    // ignore: lines_longer_than_80_chars
    test('asEntities converts a list of CoffeeModel to a list of Coffee correctly', () {
      // Arrange
      final coffeeModels = List.generate(5, (_) {
        final id = faker.guid.guid();
        final file = faker.internet.httpsUrl();
        final seenAt = faker.date.dateTime(minYear: 2025, maxYear: 2025);
        final isFavorite = faker.randomGenerator.boolean();
        final comment = faker.lorem.sentence();
        final rating = faker.randomGenerator.integer(6); // 0 to 5

        return CoffeeModel(
          id: id,
          file: file,
          seenAt: seenAt,
          isFavorite: isFavorite,
          comment: comment,
          rating: rating,
        );
      });

      // Act
      final coffees = coffeeModels.asEntities;

      // Assert
      expect(coffees.length, coffeeModels.length);

      for (var i = 0; i < coffeeModels.length; i++) {
        final model = coffeeModels[i];
        final coffee = coffees[i];

        expect(coffee.id, model.id);
        expect(coffee.imagePath, model.file);
        expect(coffee.seenAt, model.seenAt);
        expect(coffee.isFavorite, model.isFavorite);
        expect(coffee.comment, model.comment);
        expect(coffee.rating, CoffeeRating.values[model.rating]);
      }
    });
  });
}
