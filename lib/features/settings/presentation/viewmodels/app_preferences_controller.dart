import 'package:flutter/material.dart';

import '../../domain/models/app_preferences.dart';
import '../../domain/repositories/settings_repository.dart';

class AppPreferencesController extends ChangeNotifier {
  AppPreferencesController({required SettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository;

  final SettingsRepository _settingsRepository;

  String _currencyCode = 'NGN';
  SettingsThemePreference _themePreference = SettingsThemePreference.system;
  bool _biometricsEnabled = false;
  bool _isLoading = false;

  String get currencyCode => _currencyCode;
  SettingsThemePreference get themePreference => _themePreference;
  ThemeMode get themeMode => _themePreference.themeMode;
  bool get biometricsEnabled => _biometricsEnabled;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      final preferences = await _settingsRepository.getPreferences();
      _currencyCode = preferences.currencyCode;
      _themePreference = preferences.themePreference;
      _biometricsEnabled = preferences.biometricsEnabled;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reload() => load();

  Future<void> updateCurrencyCode(String currencyCode) async {
    if (_currencyCode == currencyCode) {
      return;
    }

    await _settingsRepository.saveCurrencyCode(currencyCode);
    _currencyCode = currencyCode;
    notifyListeners();
  }

  Future<void> updateThemePreference(SettingsThemePreference preference) async {
    if (_themePreference == preference) {
      return;
    }

    await _settingsRepository.saveThemePreference(preference);
    _themePreference = preference;
    notifyListeners();
  }
}
