import 'package:flutter/foundation.dart';

import '../../../profile/domain/models/profile.dart';
import '../../../profile/domain/usecases/get_stored_profile.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsActionResult {
  const SettingsActionResult({
    required this.success,
    this.message,
    this.backupPath,
  });

  final bool success;
  final String? message;
  final String? backupPath;
}

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required GetStoredProfileUseCase getStoredProfile,
    required SettingsRepository settingsRepository,
  }) : _getStoredProfile = getStoredProfile,
       _settingsRepository = settingsRepository;

  final GetStoredProfileUseCase _getStoredProfile;
  final SettingsRepository _settingsRepository;

  bool _isLoading = false;
  bool _isPerformingAction = false;
  String? _errorMessage;
  Profile? _profile;

  bool get isLoading => _isLoading;
  bool get isPerformingAction => _isPerformingAction;
  String? get errorMessage => _errorMessage;
  Profile? get profile => _profile;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _getStoredProfile();
    } catch (_) {
      _errorMessage = 'Unable to load settings right now.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<SettingsActionResult> deleteProfile() async {
    if (_isPerformingAction) {
      return const SettingsActionResult(success: false);
    }

    _isPerformingAction = true;
    notifyListeners();
    try {
      await _settingsRepository.deleteLocalProfileData();
      _profile = null;
      return const SettingsActionResult(success: true);
    } catch (_) {
      return const SettingsActionResult(
        success: false,
        message: 'Unable to delete the profile right now.',
      );
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<SettingsActionResult> backupAndDeleteProfile() async {
    if (_isPerformingAction) {
      return const SettingsActionResult(success: false);
    }

    _isPerformingAction = true;
    notifyListeners();
    try {
      final backupFile = await _settingsRepository.exportDatabaseBackup();
      await _settingsRepository.deleteLocalProfileData();
      _profile = null;
      return SettingsActionResult(success: true, backupPath: backupFile.path);
    } catch (_) {
      return const SettingsActionResult(
        success: false,
        message: 'Backup failed, so the profile was not deleted.',
      );
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }
}
