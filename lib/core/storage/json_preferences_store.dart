import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class JsonPreferencesStore {
  const JsonPreferencesStore(this._preferences);

  final SharedPreferences _preferences;

  Future<void> writeMap(String key, Map<String, dynamic> value) {
    return _preferences.setString(key, jsonEncode(value));
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> value) {
    return _preferences.setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? readMap(String key) {
    final rawValue = _preferences.getString(key);
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map) {
        return null;
      }

      return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> readList(String key) {
    final rawValue = _preferences.getString(key);
    if (rawValue == null || rawValue.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! List) {
        return const [];
      }

      return decoded
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> remove(String key) => _preferences.remove(key);

  bool readBool(String key) => _preferences.getBool(key) ?? false;

  Future<void> writeBool(String key, bool value) {
    return _preferences.setBool(key, value);
  }
}
