import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _keyThemeMode = 'theme_mode_v1';
  final SharedPreferences? _prefsInstance;

  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider([this._prefsInstance]);

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<SharedPreferences> _getPrefs() async {
    if (_prefsInstance != null) {
      return _prefsInstance;
    }
    return await SharedPreferences.getInstance();
  }

  Future<void> initialize() async {
    try {
      final prefs = await _getPrefs();
      final savedMode = prefs.getString(_keyThemeMode);
      if (savedMode != null) {
        if (savedMode == 'dark') {
          _themeMode = ThemeMode.dark;
        } else if (savedMode == 'light') {
          _themeMode = ThemeMode.light;
        } else {
          _themeMode = ThemeMode.system;
        }
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();

    try {
      final prefs = await _getPrefs();
      await prefs.setString(
        _keyThemeMode,
        _themeMode == ThemeMode.dark ? 'dark' : 'light',
      );
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await _getPrefs();
      String val = 'system';
      if (mode == ThemeMode.dark) val = 'dark';
      if (mode == ThemeMode.light) val = 'light';
      await prefs.setString(_keyThemeMode, val);
    } catch (_) {}
  }
}
