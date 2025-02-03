import 'package:vgv_challenge/data/data.dart';

abstract class HttpClient {
  Future<dynamic> request({
    required String url,
    HttpMethod method = HttpMethod.get,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool isData,
  });
}
