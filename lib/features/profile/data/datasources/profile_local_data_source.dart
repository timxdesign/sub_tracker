import '../../../../core/database/app_database.dart';
import '../dto/profile_dto.dart';

class ProfileLocalDataSource {
  const ProfileLocalDataSource(this._database);

  static const _storedProfileSlot = 'stored';
  static const _pendingProfileSlot = 'pending';

  final AppDatabase _database;

  Future<ProfileDto?> getStoredProfile() async {
    return _readProfile(_storedProfileSlot);
  }

  Future<ProfileDto?> getPendingProfile() async {
    return _readProfile(_pendingProfileSlot);
  }

  Future<void> saveStoredProfile(ProfileDto profile) {
    return _saveProfile(_storedProfileSlot, profile);
  }

  Future<void> savePendingProfile(ProfileDto profile) {
    return _saveProfile(_pendingProfileSlot, profile);
  }

  Future<void> clearPendingProfile() {
    return _clearProfile(_pendingProfileSlot);
  }

  Future<void> clearStoredProfile() {
    return _clearProfile(_storedProfileSlot);
  }

  Future<void> clearAllProfileData() {
    return _database.transaction(() async {
      await _clearProfile(_storedProfileSlot);
      await _clearProfile(_pendingProfileSlot);
    });
  }

  Future<void> replaceProfiles({
    ProfileDto? storedProfile,
    ProfileDto? pendingProfile,
  }) {
    return _database.transaction(() async {
      await _clearProfile(_storedProfileSlot);
      await _clearProfile(_pendingProfileSlot);

      if (storedProfile != null) {
        await _saveProfile(_storedProfileSlot, storedProfile);
      }

      if (pendingProfile != null) {
        await _saveProfile(_pendingProfileSlot, pendingProfile);
      }
    });
  }

  Future<ProfileDto?> _readProfile(String key) async {
    final record = await (_database.select(
      _database.profileRecords,
    )..where((profile) => profile.slot.equals(key))).getSingleOrNull();
    if (record == null) {
      return null;
    }

    final profile = ProfileDto(
      fullName: record.fullName,
      email: record.email,
      createdAt: record.createdAt,
    );
    if (profile.fullName.isEmpty || profile.email.isEmpty) {
      return null;
    }

    return profile;
  }

  Future<void> _saveProfile(String slot, ProfileDto profile) {
    return _database
        .into(_database.profileRecords)
        .insertOnConflictUpdate(
          ProfileRecordsCompanion.insert(
            slot: slot,
            fullName: profile.fullName,
            email: profile.email,
            createdAt: profile.createdAt,
          ),
        );
  }

  Future<void> _clearProfile(String slot) {
    return (_database.delete(
      _database.profileRecords,
    )..where((profile) => profile.slot.equals(slot))).go();
  }
}
