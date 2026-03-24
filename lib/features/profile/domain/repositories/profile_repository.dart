import '../models/profile.dart';

abstract interface class ProfileRepository {
  Future<Profile?> getStoredProfile();

  Future<Profile?> getPendingProfile();

  Future<Profile> createProfile({
    required String fullName,
    required String email,
  });

  Future<Profile?> updateProfile({
    required String fullName,
    required String email,
  });

  Future<void> syncPendingProfile();

  void startSyncLoop();

  void dispose();
}
