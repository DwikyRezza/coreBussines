import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const keyThemeMode = 'theme_mode';

  final SharedPreferences _prefs;
  ThemeMode _themeMode;

  ThemeController(this._prefs) : _themeMode = _readThemeMode(_prefs);

  ThemeMode get themeMode => _themeMode;

  String get selectedValue {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _prefs.setString(keyThemeMode, _valueFor(mode));
    notifyListeners();
  }

  static ThemeMode modeForValue(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static ThemeMode _readThemeMode(SharedPreferences prefs) {
    return modeForValue(prefs.getString(keyThemeMode) ?? 'system');
  }

  static String _valueFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
