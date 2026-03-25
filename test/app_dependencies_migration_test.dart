import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sub_tracker/app/di/providers.dart';
import 'package:sub_tracker/core/constants/storage_keys.dart';
import 'package:sub_tracker/core/database/app_database.dart';

void main() {
  test('migrates legacy profile and subscriptions into the database', () async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.storedProfile: jsonEncode({
        'fullName': 'Legacy Doe',
        'email': 'legacy@example.com',
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
      }),
      StorageKeys.pendingProfileSubmission: jsonEncode({
        'fullName': 'Legacy Doe',
        'email': 'legacy@example.com',
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
      }),
      StorageKeys.subscriptions: jsonEncode([
        {
          'id': 'spotify',
          'name': 'Spotify',
          'category': 'apps',
          'price': 3500,
          'currencyCode': 'NGN',
          'billingCycle': 'monthly',
          'nextBillingDate': DateTime(2026, 4, 1).toIso8601String(),
          'createdAt': DateTime(2026, 1, 2).toIso8601String(),
          'description': '',
          'serviceProvider': '',
          'website': '',
          'startDate': DateTime(2026, 1, 2).toIso8601String(),
        },
      ]),
      StorageKeys.preferredCurrency: 'USD',
    });

    final preferences = await SharedPreferences.getInstance();
    final dependencies = await buildAppDependencies(
      preferences: preferences,
      httpClient: MockClient((request) async => http.Response('', 200)),
      appDatabase: AppDatabase.inMemory(),
    );
    addTearDown(dependencies.dispose);

    final storedProfile = await dependencies.profileRepository
        .getStoredProfile();
    final pendingProfile = await dependencies.profileRepository
        .getPendingProfile();
    final subscriptions = await dependencies.subscriptionsRepository
        .getSubscriptions();
    final appPreferences = await dependencies.settingsRepository
        .getPreferences();

    expect(storedProfile?.email, 'legacy@example.com');
    expect(pendingProfile?.email, 'legacy@example.com');
    expect(subscriptions.single.name, 'Spotify');
    expect(appPreferences.currencyCode, 'USD');
    expect(preferences.getString(StorageKeys.storedProfile), isNull);
    expect(preferences.getString(StorageKeys.pendingProfileSubmission), isNull);
    expect(preferences.getString(StorageKeys.subscriptions), isNull);
  });
}
