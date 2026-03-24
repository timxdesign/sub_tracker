import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../logging/app_logger.dart';
import 'app_database_file_store.dart';

class JsonPreferencesStore {
  const JsonPreferencesStore(
    this._preferences, {
    AppDatabaseFileStore? databaseFileStore,
  }) : _databaseFileStore = databaseFileStore;

  final SharedPreferences _preferences;
  final AppDatabaseFileStore? _databaseFileStore;

  Future<void> writeMap(String key, Map<String, dynamic> value) async {
    await _preferences.setString(key, jsonEncode(value));
    await _syncDatabaseSnapshot();
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> value) async {
    await _preferences.setString(key, jsonEncode(value));
    await _syncDatabaseSnapshot();
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
    } catch (error, stackTrace) {
      AppLogger.error(
        context: 'JsonPreferencesStore.readMap($key)',
        error: error,
        stackTrace: stackTrace,
      );
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
    } catch (error, stackTrace) {
      AppLogger.error(
        context: 'JsonPreferencesStore.readList($key)',
        error: error,
        stackTrace: stackTrace,
      );
      return const [];
    }
  }

  Future<void> remove(String key) async {
    await _preferences.remove(key);
    await _syncDatabaseSnapshot();
  }

  Future<void> removeMany(Iterable<String> keys) async {
    for (final key in keys) {
      await _preferences.remove(key);
    }
    await _syncDatabaseSnapshot();
  }

  bool readBool(String key) => _preferences.getBool(key) ?? false;

  Future<void> writeBool(String key, bool value) async {
    await _preferences.setBool(key, value);
    await _syncDatabaseSnapshot();
  }

  String? readString(String key) => _preferences.getString(key);

  Future<void> writeString(String key, String value) async {
    await _preferences.setString(key, value);
    await _syncDatabaseSnapshot();
  }

  Map<String, dynamic> exportValues() {
    final snapshot = <String, dynamic>{};
    for (final key in _preferences.getKeys()) {
      final value = _preferences.get(key);
      if (value is String || value is bool || value is int || value is double) {
        snapshot[key] = value;
      }
    }
    return snapshot;
  }

  Future<void> replaceValues(Map<String, dynamic> values) async {
    await _preferences.clear();
    for (final entry in values.entries) {
      final value = entry.value;
      if (value is bool) {
        await _preferences.setBool(entry.key, value);
      } else if (value is int) {
        await _preferences.setInt(entry.key, value);
      } else if (value is double) {
        await _preferences.setDouble(entry.key, value);
      } else if (value is String) {
        await _preferences.setString(entry.key, value);
      }
    }
    await _syncDatabaseSnapshot();
  }

  Future<File> writeDatabaseSnapshot() async {
    final store = _databaseFileStore;
    if (store == null) {
      throw StateError('Database file store is not configured.');
    }

    return store.writeSnapshot(exportValues());
  }

  Future<File> exportDatabaseSnapshot() async {
    final store = _databaseFileStore;
    if (store == null) {
      throw StateError('Database file store is not configured.');
    }

    return store.exportSnapshot(exportValues());
  }

  Future<Map<String, dynamic>> readDatabaseSnapshot(File file) async {
    final store = _databaseFileStore;
    if (store == null) {
      throw StateError('Database file store is not configured.');
    }

    return store.readSnapshotFromFile(file);
  }

  Future<void> _syncDatabaseSnapshot() async {
    final store = _databaseFileStore;
    if (store == null) {
      return;
    }

    await store.writeSnapshot(exportValues());
  }
}
