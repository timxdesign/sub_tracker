import 'dart:io';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/app_backup_file_store.dart';
import '../../../../core/storage/json_preferences_store.dart';
import '../../../profile/data/datasources/profile_local_data_source.dart';
import '../../../profile/data/dto/profile_dto.dart';
import '../../../subscriptions/data/datasources/subscriptions_local_data_source.dart';
import '../../../subscriptions/data/dto/subscription_dto.dart';
import '../../domain/models/app_preferences.dart';

class SettingsLocalDataSource {
  const SettingsLocalDataSource({
    required JsonPreferencesStore store,
    required AppBackupFileStore backupFileStore,
    required ProfileLocalDataSource profileLocalDataSource,
    required SubscriptionsLocalDataSource subscriptionsLocalDataSource,
  }) : _store = store,
       _backupFileStore = backupFileStore,
       _profileLocalDataSource = profileLocalDataSource,
       _subscriptionsLocalDataSource = subscriptionsLocalDataSource;

  final JsonPreferencesStore _store;
  final AppBackupFileStore _backupFileStore;
  final ProfileLocalDataSource _profileLocalDataSource;
  final SubscriptionsLocalDataSource _subscriptionsLocalDataSource;

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

  Future<File> exportDatabaseBackup() async {
    final snapshot = _store.exportValues();

    final storedProfile = await _profileLocalDataSource.getStoredProfile();
    if (storedProfile != null) {
      snapshot[StorageKeys.storedProfile] = storedProfile.toJson();
    }

    final pendingProfile = await _profileLocalDataSource.getPendingProfile();
    if (pendingProfile != null) {
      snapshot[StorageKeys.pendingProfileSubmission] = pendingProfile.toJson();
    }

    final subscriptions = await _subscriptionsLocalDataSource
        .getSubscriptions();
    if (subscriptions.isNotEmpty) {
      snapshot[StorageKeys.subscriptions] = subscriptions
          .map((subscription) => subscription.toJson())
          .toList(growable: false);
    }

    return _backupFileStore.exportSnapshot(snapshot);
  }

  Future<void> importDatabaseBackup(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw const FileSystemException('Backup file does not exist.');
    }

    final snapshot = await _backupFileStore.readSnapshotFromFile(file);
    await _store.replaceValues(_preferencesSnapshot(snapshot));
    await _profileLocalDataSource.replaceProfiles(
      storedProfile: _readProfile(snapshot, StorageKeys.storedProfile),
      pendingProfile: _readProfile(
        snapshot,
        StorageKeys.pendingProfileSubmission,
      ),
    );
    await _subscriptionsLocalDataSource.saveSubscriptions(
      _readSubscriptions(snapshot),
    );
  }

  Future<void> deleteLocalProfileData() async {
    await _store.removeMany(const [
      StorageKeys.storedProfile,
      StorageKeys.pendingProfileSubmission,
      StorageKeys.subscriptions,
    ]);
    await _profileLocalDataSource.clearAllProfileData();
    await _subscriptionsLocalDataSource.clearSubscriptions();
  }

  Map<String, dynamic> _preferencesSnapshot(Map<String, dynamic> snapshot) {
    final values = Map<String, dynamic>.from(snapshot);
    values.remove(StorageKeys.storedProfile);
    values.remove(StorageKeys.pendingProfileSubmission);
    values.remove(StorageKeys.subscriptions);
    return values;
  }

  ProfileDto? _readProfile(Map<String, dynamic> snapshot, String key) {
    final rawValue = snapshot[key];
    if (rawValue is! Map) {
      return null;
    }

    final profile = ProfileDto.fromJson(Map<String, dynamic>.from(rawValue));
    if (profile.fullName.isEmpty || profile.email.isEmpty) {
      return null;
    }

    return profile;
  }

  List<SubscriptionDto> _readSubscriptions(Map<String, dynamic> snapshot) {
    final rawValue = snapshot[StorageKeys.subscriptions];
    if (rawValue is! List) {
      return const [];
    }

    return rawValue
        .whereType<Map>()
        .map(
          (entry) => SubscriptionDto.fromJson(Map<String, dynamic>.from(entry)),
        )
        .where((subscription) => subscription.id.isNotEmpty)
        .toList(growable: false);
  }
}
