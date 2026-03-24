import 'dart:io';

import '../models/app_preferences.dart';

abstract interface class SettingsRepository {
  Future<AppPreferences> getPreferences();

  Future<void> saveCurrencyCode(String currencyCode);

  Future<void> saveThemePreference(SettingsThemePreference preference);

  Future<File> exportDatabaseBackup();

  Future<void> importDatabaseBackup(String filePath);

  Future<void> deleteLocalProfileData();
}
