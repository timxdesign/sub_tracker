import 'dart:async';

import '../../domain/models/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';
import '../dto/profile_dto.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileLocalDataSource localDataSource,
    required ProfileRemoteDataSource remoteDataSource,
    Duration retryInterval = const Duration(seconds: 30),
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _retryInterval = retryInterval;

  final ProfileLocalDataSource _localDataSource;
  final ProfileRemoteDataSource _remoteDataSource;
  final Duration _retryInterval;

  Timer? _retryTimer;
  bool _isSyncing = false;

  @override
  Future<Profile> createProfile({
    required String fullName,
    required String email,
  }) async {
    final profile = Profile(
      fullName: fullName,
      email: email,
      createdAt: DateTime.now(),
    );
    final dto = ProfileDto.fromDomain(profile);

    await _localDataSource.saveStoredProfile(dto);
    await _localDataSource.savePendingProfile(dto);
    return profile;
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
  }

  @override
  Future<Profile?> getPendingProfile() async {
    return (await _localDataSource.getPendingProfile())?.toDomain();
  }

  @override
  Future<Profile?> getStoredProfile() async {
    return (await _localDataSource.getStoredProfile())?.toDomain();
  }

  @override
  Future<Profile?> updateProfile({
    required String fullName,
    required String email,
  }) async {
    final existingProfile = await _localDataSource.getStoredProfile();
    if (existingProfile == null) {
      return null;
    }

    final updatedProfile = Profile(
      fullName: fullName,
      email: email,
      createdAt: existingProfile.createdAt,
    );
    final dto = ProfileDto.fromDomain(updatedProfile);

    await _localDataSource.saveStoredProfile(dto);
    await _localDataSource.clearPendingProfile();
    return updatedProfile;
  }

  @override
  void startSyncLoop() {
    if (_retryTimer != null) {
      return;
    }

    _retryTimer = Timer.periodic(_retryInterval, (_) {
      unawaited(syncPendingProfile());
    });
  }

  @override
  Future<void> syncPendingProfile() async {
    if (_isSyncing || !_remoteDataSource.isConfigured) {
      return;
    }

    final pendingProfile = await _localDataSource.getPendingProfile();
    if (pendingProfile == null) {
      return;
    }

    _isSyncing = true;
    try {
      final didSync = await _remoteDataSource.syncProfile(pendingProfile);
      if (didSync) {
        await _localDataSource.clearPendingProfile();
      }
    } finally {
      _isSyncing = false;
    }
  }
}
