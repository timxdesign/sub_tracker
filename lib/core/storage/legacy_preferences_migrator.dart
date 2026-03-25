import '../../features/profile/data/datasources/profile_local_data_source.dart';
import '../../features/profile/data/dto/profile_dto.dart';
import '../../features/subscriptions/data/datasources/subscriptions_local_data_source.dart';
import '../../features/subscriptions/data/dto/subscription_dto.dart';
import '../constants/storage_keys.dart';
import 'json_preferences_store.dart';

class LegacyPreferencesMigrator {
  const LegacyPreferencesMigrator({
    required JsonPreferencesStore store,
    required ProfileLocalDataSource profileLocalDataSource,
    required SubscriptionsLocalDataSource subscriptionsLocalDataSource,
  }) : _store = store,
       _profileLocalDataSource = profileLocalDataSource,
       _subscriptionsLocalDataSource = subscriptionsLocalDataSource;

  final JsonPreferencesStore _store;
  final ProfileLocalDataSource _profileLocalDataSource;
  final SubscriptionsLocalDataSource _subscriptionsLocalDataSource;

  Future<void> migrate() async {
    final hasStoredProfile =
        _store.readString(StorageKeys.storedProfile) != null;
    final hasPendingProfile =
        _store.readString(StorageKeys.pendingProfileSubmission) != null;
    final hasSubscriptions =
        _store.readString(StorageKeys.subscriptions) != null;

    if (!hasStoredProfile && !hasPendingProfile && !hasSubscriptions) {
      return;
    }

    final storedProfileJson = _store.readMap(StorageKeys.storedProfile);
    final pendingProfileJson = _store.readMap(
      StorageKeys.pendingProfileSubmission,
    );
    final subscriptionsJson = _store.readList(StorageKeys.subscriptions);

    final existingStoredProfile = await _profileLocalDataSource
        .getStoredProfile();
    final existingPendingProfile = await _profileLocalDataSource
        .getPendingProfile();
    final existingSubscriptions = await _subscriptionsLocalDataSource
        .getSubscriptions();

    if (existingStoredProfile == null && storedProfileJson != null) {
      await _profileLocalDataSource.saveStoredProfile(
        ProfileDto.fromJson(storedProfileJson),
      );
    }

    if (existingPendingProfile == null && pendingProfileJson != null) {
      await _profileLocalDataSource.savePendingProfile(
        ProfileDto.fromJson(pendingProfileJson),
      );
    }

    if (existingSubscriptions.isEmpty && subscriptionsJson.isNotEmpty) {
      await _subscriptionsLocalDataSource.saveSubscriptions(
        subscriptionsJson
            .map(SubscriptionDto.fromJson)
            .where((subscription) => subscription.id.isNotEmpty)
            .toList(growable: false),
      );
    }

    await _store.removeMany(const [
      StorageKeys.storedProfile,
      StorageKeys.pendingProfileSubmission,
      StorageKeys.subscriptions,
    ]);
  }
}
