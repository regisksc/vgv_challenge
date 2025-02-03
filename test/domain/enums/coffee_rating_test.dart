import 'package:flutter_test/flutter_test.dart';
import 'package:vgv_challenge/domain/domain.dart';

void main() {
  group('CoffeeRating', () {
    test('unrated should have intValue 0', () {
      expect(CoffeeRating.unrated.intValue, equals(0));
    });

    test('oneStar should have intValue 1', () {
      expect(CoffeeRating.oneStar.intValue, equals(1));
    });

    test('twoStars should have intValue 2', () {
      expect(CoffeeRating.twoStars.intValue, equals(2));
    });

    test('threeStars should have intValue 3', () {
      expect(CoffeeRating.threeStars.intValue, equals(3));
    });

    test('fourStars should have intValue 4', () {
      expect(CoffeeRating.fourStars.intValue, equals(4));
    });

    test('fiveStars should have intValue 5', () {
      expect(CoffeeRating.fiveStars.intValue, equals(5));
    });
  });
}
