import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static late Box _box;
  static late SharedPreferences _prefs;

  static Future<void> initialize() async {
    _box = await Hive.openBox('karmgyan_storage');
    _prefs = await SharedPreferences.getInstance();
  }

  // Hive operations
  static Future<void> save(String key, dynamic value) async {
    await _box.put(key, value);
  }

  static dynamic get(String key) {
    return _box.get(key);
  }

  static Future<void> delete(String key) async {
    await _box.delete(key);
  }

  static Future<void> clear() async {
    await _box.clear();
  }

  // SharedPreferences operations
  static Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs.getString(key);
  }

  static Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  static Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  static Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  static Future<void> clearAll() async {
    await _prefs.clear();
    await _box.clear();
  }
}
