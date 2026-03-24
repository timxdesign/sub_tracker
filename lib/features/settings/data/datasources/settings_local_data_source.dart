import 'dart:io';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/json_preferences_store.dart';
import '../../domain/models/app_preferences.dart';

class SettingsLocalDataSource {
  const SettingsLocalDataSource(this._store);

  final JsonPreferencesStore _store;

  Future<AppPreferences> getPreferences() async {
    return AppPreferences(
      currencyCode: _store.readString(StorageKeys.preferredCurrency) ?? 'NGN',
      themePreference: SettingsThemePreference.fromStorage(
        _store.readString(StorageKeys.preferredThemeMode),
      ),
      biometricsEnabled: _store.readBool(StorageKeys.biometricsEnabled),
    );
  }

  Future<void> saveCurrencyCode(String currencyCode) {
    return _store.writeString(StorageKeys.preferredCurrency, currencyCode);
  }

  Future<void> saveThemePreference(SettingsThemePreference preference) {
    return _store.writeString(
      StorageKeys.preferredThemeMode,
      preference.storageValue,
    );
  }

  Future<File> exportDatabaseBackup() {
    return _store.exportDatabaseSnapshot();
  }

  Future<void> importDatabaseBackup(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw const FileSystemException('Backup file does not exist.');
    }

    final snapshot = await _store.readDatabaseSnapshot(file);
    await _store.replaceValues(snapshot);
  }

  Future<void> deleteLocalProfileData() {
    return _store.removeMany(const [
      StorageKeys.storedProfile,
      StorageKeys.pendingProfileSubmission,
      StorageKeys.subscriptions,
    ]);
  }
}
