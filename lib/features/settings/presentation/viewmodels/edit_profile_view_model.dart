import '../../../../core/viewmodels/app_view_model.dart';
import '../../../profile/domain/models/profile.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../profile/domain/usecases/get_stored_profile.dart';

class EditProfileViewModel extends AppViewModel {
  EditProfileViewModel({
    required GetStoredProfileUseCase getStoredProfile,
    required ProfileRepository profileRepository,
  }) : _getStoredProfile = getStoredProfile,
       _profileRepository = profileRepository;

  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final GetStoredProfileUseCase _getStoredProfile;
  final ProfileRepository _profileRepository;

  String _name = '';
  String _email = '';
  bool _nameTouched = false;
  bool _emailTouched = false;
  bool _showErrors = false;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _screenError;

  String get name => _name;
  String get email => _email;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get screenError => _screenError;

  String? get nameError {
    if (!_showErrors && !_nameTouched) {
      return null;
    }
    return _name.trim().isEmpty ? 'Please enter your name' : null;
  }

  String? get emailError {
    if (!_showErrors && !_emailTouched) {
      return null;
    }

    final email = _email.trim();
    if (email.isEmpty) {
      return 'Please enter your email address';
    }
    if (!_emailPattern.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> load() async {
    _isLoading = true;
    _screenError = null;
    notifyListeners();

    try {
      final profile = await _getStoredProfile();
      if (profile == null) {
        _screenError = 'No profile found.';
      } else {
        _applyProfile(profile);
      }
    } catch (error, stackTrace) {
      reportError(error, stackTrace, context: 'EditProfileViewModel.load');
      _screenError = 'Unable to load your profile right now.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateName(String value) {
    _name = value;
    notifyListeners();
  }

  void updateEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void markNameTouched() {
    _nameTouched = true;
    notifyListeners();
  }

  void markEmailTouched() {
    _emailTouched = true;
    notifyListeners();
  }

  Future<bool> save() async {
    _showErrors = true;
    _nameTouched = true;
    _emailTouched = true;
    notifyListeners();

    if (nameError != null || emailError != null || _isSaving) {
      return false;
    }

    _isSaving = true;
    _screenError = null;
    notifyListeners();
    try {
      final updatedProfile = await _profileRepository.updateProfile(
        fullName: _name.trim(),
        email: _email.trim(),
      );
      if (updatedProfile == null) {
        _screenError = 'No profile found.';
        return false;
      }
      _applyProfile(updatedProfile);
      return true;
    } catch (error, stackTrace) {
      reportError(error, stackTrace, context: 'EditProfileViewModel.save');
      _screenError = 'Unable to save your profile right now.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void _applyProfile(Profile profile) {
    _name = profile.fullName;
    _email = profile.email;
  }
}
