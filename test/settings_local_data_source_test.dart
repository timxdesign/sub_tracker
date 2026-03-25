import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sub_tracker/core/constants/storage_keys.dart';
import 'package:sub_tracker/core/database/app_database.dart';
import 'package:sub_tracker/core/storage/app_backup_file_store.dart';
import 'package:sub_tracker/core/storage/json_preferences_store.dart';
import 'package:sub_tracker/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:sub_tracker/features/profile/data/dto/profile_dto.dart';
import 'package:sub_tracker/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:sub_tracker/features/subscriptions/data/datasources/subscriptions_local_data_source.dart';
import 'package:sub_tracker/features/subscriptions/data/dto/subscription_dto.dart';

void main() {
  late Directory tempDirectory;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.preferredCurrency: 'USD',
      StorageKeys.preferredThemeMode: 'dark',
      StorageKeys.hasSeenWelcome: true,
    });
    tempDirectory = await Directory.systemTemp.createTemp(
      'sub_tracker_backup_test',
    );
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test(
    'exports and imports backup snapshots with preferences and database data',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final store = JsonPreferencesStore(preferences);
      final database = AppDatabase.inMemory();
      addTearDown(database.close);

      final profileLocalDataSource = ProfileLocalDataSource(database);
      final subscriptionsLocalDataSource = SubscriptionsLocalDataSource(
        database,
      );
      final backupFileStore = AppBackupFileStore(
        appSupportDirectory: () async => tempDirectory,
        downloadsDirectory: () async => tempDirectory,
      );
      final settingsLocalDataSource = SettingsLocalDataSource(
        store: store,
        backupFileStore: backupFileStore,
        profileLocalDataSource: profileLocalDataSource,
        subscriptionsLocalDataSource: subscriptionsLocalDataSource,
      );

      await profileLocalDataSource.saveStoredProfile(
        ProfileDto(
          fullName: 'Backup Doe',
          email: 'backup@example.com',
          createdAt: DateTime(2026, 1, 1),
        ),
      );
      await subscriptionsLocalDataSource.saveSubscriptions([
        SubscriptionDto(
          id: 'netflix',
          name: 'Netflix',
          category: 'apps',
          price: 8000,
          currencyCode: 'NGN',
          billingCycle: 'monthly',
          nextBillingDate: DateTime(2026, 4, 20),
          createdAt: DateTime(2026, 1, 5),
        ),
      ]);

      final backupFile = await settingsLocalDataSource.exportDatabaseBackup();

      await store.writeString(StorageKeys.preferredCurrency, 'NGN');
      await settingsLocalDataSource.deleteLocalProfileData();
      await settingsLocalDataSource.importDatabaseBackup(backupFile.path);

      final restoredProfile = await profileLocalDataSource.getStoredProfile();
      final restoredSubscriptions = await subscriptionsLocalDataSource
          .getSubscriptions();

      expect(store.readString(StorageKeys.preferredCurrency), 'USD');
      expect(store.readString(StorageKeys.preferredThemeMode), 'dark');
      expect(store.readBool(StorageKeys.hasSeenWelcome), isTrue);
      expect(restoredProfile?.email, 'backup@example.com');
      expect(restoredSubscriptions.single.name, 'Netflix');
    },
  );
}
