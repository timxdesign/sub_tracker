import 'package:flutter/foundation.dart';

import '../../domain/usecases/create_profile.dart';
import '../../domain/usecases/sync_pending_profile.dart';

class CreateProfileViewModel extends ChangeNotifier {
  CreateProfileViewModel({
    required CreateProfileUseCase createProfile,
    required SyncPendingProfileUseCase syncPendingProfile,
  })  : _createProfile = createProfile,
        _syncPendingProfile = syncPendingProfile;

  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final CreateProfileUseCase _createProfile;
  final SyncPendingProfileUseCase _syncPendingProfile;

  String _name = '';
  String _email = '';
  bool _hasTriedSubmit = false;
  bool _nameTouched = false;
  bool _emailTouched = false;
  bool _isSubmitting = false;

  String get name => _name;
  String get email => _email;
  bool get isSubmitting => _isSubmitting;

  bool get canSubmit =>
      _validateName(_name) == null && _validateEmail(_email) == null;

  String? get nameError {
    if (!_hasTriedSubmit && !_nameTouched) {
      return null;
    }

    return _validateName(_name);
  }

  String? get emailError {
    if (!_hasTriedSubmit && !_emailTouched) {
      return null;
    }

    return _validateEmail(_email);
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

  Future<bool> submit() async {
    if (!canSubmit) {
      _hasTriedSubmit = true;
      _nameTouched = true;
      _emailTouched = true;
      notifyListeners();
      return false;
    }

    if (_isSubmitting) {
      return false;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      await _createProfile(
        fullName: _name.trim(),
        email: _email.trim(),
      );
      await _syncPendingProfile();
      return true;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  String? _validateName(String value) {
    if (value.trim().isEmpty) {
      return 'Please enter your name';
    }

    return null;
  }

  String? _validateEmail(String value) {
    final email = value.trim();
    if (email.isEmpty) {
      return 'Please enter your email address';
    }

    if (!_emailPattern.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }
}
