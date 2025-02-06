import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

class FetchCoffeeFromRemote implements GetCoffee {
  FetchCoffeeFromRemote({required this.httpClient});
  final HttpClient httpClient;

  static const String _remoteUrl = 'https://coffee.alexflipnote.dev/random.json';

  @override
  Future<Result<Coffee, Failure>> call([void _]) async {
    try {
      final coffeeData = await _fetchCoffeeData();
      final imageUrl = coffeeData['file'] as String;
      final localFilePath = await _downloadAndSaveImage(imageUrl);

      final coffeeModel = CoffeeModel.fromJson({'file': localFilePath});
      return Result.success(coffeeModel.asEntity);
    } on Failure catch (failure) {
      return Result.failure(failure);
    } catch (e) {
      return Result.failure(ServerFailure());
    }
  }

  Future<Map<String, dynamic>> _fetchCoffeeData() async {
    final response = await httpClient.request(url: _remoteUrl);
    final decoded = jsonDecode(jsonEncode(response));
    const invalid = 'Invalid response format';
    if (decoded is! Map<String, dynamic>) throw const FormatException(invalid);
    return decoded;
  }

  Future<String> _downloadAndSaveImage(String imageUrl) async {
    if (!imageUrl.startsWith('http')) return imageUrl;

    try {
      final response = await httpClient.request(
        url: imageUrl,
        isData: true,
      ) as List<int>;
      final fileName = p.basename(imageUrl);

      final directory = await getApplicationDocumentsDirectory();
      final localFilePath = p.join(directory.path, fileName);
      final localFile = File(localFilePath);
      await localFile.writeAsBytes(response);
      final fileExists = localFile.existsSync();
      if (!fileExists) throw Exception('File removed right after saving');
      return localFilePath;
    } catch (e) {
      throw Exception('Failed to download and save image: $e');
    }
  }
}
