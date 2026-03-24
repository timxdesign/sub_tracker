import '../../../../core/viewmodels/app_view_model.dart';
import '../../domain/repositories/settings_repository.dart';

class ImportExistingProfileResult {
  const ImportExistingProfileResult({required this.success, this.message});

  final bool success;
  final String? message;
}

class ImportExistingProfileViewModel extends AppViewModel {
  ImportExistingProfileViewModel({
    required SettingsRepository settingsRepository,
  }) : _settingsRepository = settingsRepository;

  final SettingsRepository _settingsRepository;

  bool _isBusy = false;

  bool get isBusy => _isBusy;

  Future<ImportExistingProfileResult> importFromFile(String filePath) async {
    if (_isBusy) {
      return const ImportExistingProfileResult(success: false);
    }

    _isBusy = true;
    notifyListeners();
    try {
      await _settingsRepository.importDatabaseBackup(filePath);
      return const ImportExistingProfileResult(success: true);
    } catch (error, stackTrace) {
      reportError(
        error,
        stackTrace,
        context: 'ImportExistingProfileViewModel.importFromFile',
      );
      return const ImportExistingProfileResult(
        success: false,
        message: 'Unable to import that backup file.',
      );
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}
