import 'dart:convert';

import 'package:vgv_challenge/data/data.dart';

extension StorageExtensions on Storage {
  Future<List<CoffeeModel>?> getCoffeeList(String key) async {
    final storedJson = await read(key: key);
    if (storedJson == null) return null;
    final decoded = jsonDecode(storedJson) as List<dynamic>;
    return decoded
        .map(
          (item) => CoffeeModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
