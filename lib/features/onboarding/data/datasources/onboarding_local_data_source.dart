import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/json_preferences_store.dart';

class OnboardingLocalDataSource {
  const OnboardingLocalDataSource(this._store);

  final JsonPreferencesStore _store;

  Future<bool> hasCompletedOnboarding() async {
    return _store.readBool(StorageKeys.hasSeenWelcome);
  }

  Future<void> completeOnboarding() {
    return _store.writeBool(StorageKeys.hasSeenWelcome, true);
  }
}
