import 'package:get_storage/get_storage.dart';

class StorageService {
  static final GetStorage _box = GetStorage();

  static T read<T>(String key, T defaultValue) {
    final value = _box.read(key);
    if (value == null) return defaultValue;
    return value as T;
  }

  static void write(String key, dynamic value) {
    _box.write(key, value);
  }

  static void remove(String key) {
    _box.remove(key);
  }

  static void clear() {
    _box.erase();
  }
}