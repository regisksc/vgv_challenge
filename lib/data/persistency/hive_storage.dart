import 'package:hive/hive.dart';
import 'package:vgv_challenge/data/data.dart';

// is an adapter
class HiveStorage implements Storage {
  HiveStorage({required this.box});

  final Box<String> box;

  @override
  Future<String?> read({required String key}) async {
    try {
      final value = box.get(key);
      return value;
    } catch (error) {
      throw ReadingFailure(key: key, );
    }
  }

  @override
  Future<void> write({required String key, required String value}) async {
    try {
      await box.put(key, value);
    } catch (error) {
      throw WritingFailure(key: key);
    }
  }
}
