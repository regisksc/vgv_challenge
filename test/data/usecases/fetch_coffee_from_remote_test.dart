import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

class MockHttpClient extends Mock implements HttpClient {}

void main() {
  late FetchCoffeeFromRemote fetchCoffeeFromRemote;
  late MockHttpClient mockHttpClient;

  // ignore: unnecessary_lambdas

  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel('plugins.flutter.io/path_provider')
      // ignore: deprecated_member_use
      .setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'getApplicationDocumentsDirectory') {
      return '/tmp';
    }
    return null;
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    fetchCoffeeFromRemote = FetchCoffeeFromRemote(httpClient: mockHttpClient);
  });

  tearDown(() {
    reset(mockHttpClient);
  });

  group('FetchCoffeeFromRemote', () {
    test('returns success with a valid Coffee JSON response', () async {
      final jsonResponse = {'file': '/images/test.png'};

      when(
        () => mockHttpClient.request(url: any(named: 'url')),
      ).thenAnswer((_) async => jsonResponse);

      // Act
      final result = await fetchCoffeeFromRemote.call();

      // Assert
      expect(result.isSuccess, isTrue);
      final coffee = result.successValue!;
      expect(coffee.imagePath, '/images/test.png');
      expect(coffee.id, isNotEmpty);
      expect(coffee.isFavorite, isFalse);
      expect(coffee.comment, isNull);
      expect(coffee.rating, CoffeeRating.unrated);

      verify(() => mockHttpClient.request(url: any(named: 'url'))).called(1);
    });

    test('returns failure if response is not a valid map', () async {
      // Arrange
      when(
        () => mockHttpClient.request(url: any(named: 'url')),
      ).thenAnswer((_) async => ['not', 'a', 'map']);

      // Act
      final result = await fetchCoffeeFromRemote.call();

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ServerFailure>());

      verify(() => mockHttpClient.request(url: any(named: 'url'))).called(1);
    });

    test('returns failure if request throws a Failure', () async {
      // Arrange
      when(
        () => mockHttpClient.request(url: any(named: 'url')),
      ).thenThrow(ServerFailure());

      // Act
      final result = await fetchCoffeeFromRemote.call();

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ServerFailure>());

      verify(() => mockHttpClient.request(url: any(named: 'url'))).called(1);
    });

    // ignore: lines_longer_than_80_chars
    test('returns failure if an unexpected, non-Failure exception is thrown', () async {
      // Arrange
      when(
        () => mockHttpClient.request(url: any(named: 'url')),
      ).thenThrow(Exception('Some unknown error'));

      // Act
      final result = await fetchCoffeeFromRemote.call();

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ServerFailure>());

      verify(() => mockHttpClient.request(url: any(named: 'url'))).called(1);
    });

    group('FetchCoffeeFromRemote - _downloadAndSaveImage branch', () {
      // ignore: lines_longer_than_80_chars
      test('downloads image when imageUrl starts with "http" and returns local file path', () async {
        // Arrange
        const imageUrl = 'http://example.com/image.png';
        final coffeeData = {'file': imageUrl};

        final imageBytes = [1, 2, 3, 4, 5];
        when(
          () => mockHttpClient.request(url: any(named: 'url')),
        ).thenAnswer((_) async => coffeeData);
        when(
          () => mockHttpClient.request(
            url: imageUrl,
            isData: true,
          ),
        ).thenAnswer((_) async => imageBytes);

        // Act
        final result = await fetchCoffeeFromRemote.call();

        // Assert
        expect(result.isSuccess, isTrue);
        final coffee = result.successValue!;

        expect(p.basename(coffee.imagePath), equals('image.png'));

        final file = File(coffee.imagePath);
        if (file.existsSync()) await file.delete();

        verify(() => mockHttpClient.request(url: any(named: 'url'))).called(1);
        verify(
          () => mockHttpClient.request(url: imageUrl, isData: true),
        ).called(1);
      });
    });
  });
}
