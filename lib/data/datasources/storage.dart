abstract class Storage implements Read, Write {}

abstract class Write {
  Future<void> write({required String key, required String value});
}

abstract class Read {
  Future<String?> read({required String key});
}
