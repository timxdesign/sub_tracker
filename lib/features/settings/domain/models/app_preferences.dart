import 'package:flutter/material.dart';

enum SettingsThemePreference {
  system,
  light,
  dark;

  ThemeMode get themeMode {
    switch (this) {
      case SettingsThemePreference.system:
        return ThemeMode.system;
      case SettingsThemePreference.light:
        return ThemeMode.light;
      case SettingsThemePreference.dark:
        return ThemeMode.dark;
    }
  }

  String get storageValue {
    switch (this) {
      case SettingsThemePreference.system:
        return 'system';
      case SettingsThemePreference.light:
        return 'light';
      case SettingsThemePreference.dark:
        return 'dark';
    }
  }

  String get label {
    switch (this) {
      case SettingsThemePreference.system:
        return 'Auto';
      case SettingsThemePreference.light:
        return 'Light mode';
      case SettingsThemePreference.dark:
        return 'Dark mode';
    }
  }

  static SettingsThemePreference fromStorage(String? value) {
    switch (value) {
      case 'light':
        return SettingsThemePreference.light;
      case 'dark':
        return SettingsThemePreference.dark;
      default:
        return SettingsThemePreference.system;
    }
  }
}

class AppPreferences {
  const AppPreferences({
    required this.currencyCode,
    required this.themePreference,
    required this.biometricsEnabled,
  });

  final String currencyCode;
  final SettingsThemePreference themePreference;
  final bool biometricsEnabled;
}
