import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/json_preferences_store.dart';
import '../dto/profile_dto.dart';

class ProfileLocalDataSource {
  const ProfileLocalDataSource(this._store);

  final JsonPreferencesStore _store;

  Future<ProfileDto?> getStoredProfile() async {
    return _readProfile(StorageKeys.storedProfile);
  }

  Future<ProfileDto?> getPendingProfile() async {
    return _readProfile(StorageKeys.pendingProfileSubmission);
  }

  Future<void> saveStoredProfile(ProfileDto profile) {
    return _store.writeMap(StorageKeys.storedProfile, profile.toJson());
  }

  Future<void> savePendingProfile(ProfileDto profile) {
    return _store.writeMap(
      StorageKeys.pendingProfileSubmission,
      profile.toJson(),
    );
  }

  Future<void> clearPendingProfile() {
    return _store.remove(StorageKeys.pendingProfileSubmission);
  }

  Future<void> clearStoredProfile() {
    return _store.remove(StorageKeys.storedProfile);
  }

  Future<ProfileDto?> _readProfile(String key) async {
    final json = _store.readMap(key);
    if (json == null) {
      return null;
    }

    final profile = ProfileDto.fromJson(json);
    if (profile.fullName.isEmpty || profile.email.isEmpty) {
      return null;
    }

    return profile;
  }
}
