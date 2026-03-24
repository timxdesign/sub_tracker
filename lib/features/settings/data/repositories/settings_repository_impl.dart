import 'dart:io';

import '../../domain/models/app_preferences.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl({
    required SettingsLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final SettingsLocalDataSource _localDataSource;

  @override
  Future<AppPreferences> getPreferences() {
    return _localDataSource.getPreferences();
  }

  @override
  Future<void> saveCurrencyCode(String currencyCode) {
    return _localDataSource.saveCurrencyCode(currencyCode);
  }

  @override
  Future<void> saveThemePreference(SettingsThemePreference preference) {
    return _localDataSource.saveThemePreference(preference);
  }

  @override
  Future<File> exportDatabaseBackup() {
    return _localDataSource.exportDatabaseBackup();
  }

  @override
  Future<void> importDatabaseBackup(String filePath) {
    return _localDataSource.importDatabaseBackup(filePath);
  }

  @override
  Future<void> deleteLocalProfileData() {
    return _localDataSource.deleteLocalProfileData();
  }
}
