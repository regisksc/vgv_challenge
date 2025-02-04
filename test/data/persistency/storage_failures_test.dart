import 'package:equatable/equatable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vgv_challenge/data/data.dart';

void main() {
  setUp(() => EquatableConfig.stringify = false);

  group('StorageFailure Tests', () {
    test('ReadingFailure creates instance with correct message', () {
      // Arrange
      const key = 'testKey';

      // Act
      final failure = ReadingFailure(key: key);

      // Assert
      expect(failure.message, 'Storage: No value was found for key $key');
      expect(failure.key, key);
      expect(failure.props, <Object?>[]);
      expect(failure.stringify, false);
    });

    test('ReadingFromEmptyFailure creates instance with correct message', () {
      // Arrange
      const key = 'testKey';

      // Act
      final failure = ReadingFromEmptyFailure(key: key);

      // Assert
      expect(failure.message, 'Storage: No value was found for key $key');
      expect(failure.key, key);
      expect(failure.props, <Object?>[]);
      expect(failure.stringify, false);
    });

    // ignore: lines_longer_than_80_chars
    test('LookedUpItemNotInListFailure creates instance with correct message', () {
      // Arrange
      const key = 'testKey';

      // Act
      final failure = LookedUpItemNotInListFailure(key: key);

      // Assert
      expect(failure.message, 'Storage: No value was found for key $key');
      expect(failure.key, key);
      expect(failure.props, <Object?>[]);
      expect(failure.stringify, false);
    });

    test('ItemNeverStoredFailure creates instance with correct message', () {
      // Arrange
      const key = 'testKey';

      // Act
      final failure = ItemNeverStoredFailure(key: key);

      // Assert
      expect(failure.message, 'Storage: No value was found for key $key');
      expect(failure.key, key);
      expect(failure.props, <Object?>[]);
      expect(failure.stringify, false);
    });

    test('ReadingOrWritingFailure creates instance with correct message', () {
      // Arrange
      const key = 'testKey';

      // Act
      final failure = ReadingOrWritingFailure(key: key);

      // Assert
      expect(failure.message, 'Storage: Could not operate on key $key');
      expect(failure.props, <Object?>[]);
      expect(failure.stringify, false);
    });

    test('WritingFailure creates instance with correct message', () {
      // Arrange
      const key = 'testKey';

      // Act
      final failure = WritingFailure(key: key);

      // Assert
      expect(failure.message, 'Storage: Could not save value for key $key');
      expect(failure.props, <Object?>[]);
      expect(failure.stringify, false);
    });
  });
}
