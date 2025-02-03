enum HttpMethod { get }

extension HttpMethodExtension on HttpMethod {
  String get value {
    return switch (this) {
      HttpMethod.get => 'GET',
    };
  }
}
