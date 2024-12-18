import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  late SharedPreferences _prefs;
  static const String _darkModeKey = 'darkMode';

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool(_darkModeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(_darkModeKey, _isDarkMode);
    notifyListeners();
  }

  ThemeData get theme {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  static final ThemeData _lightTheme = ThemeData(
    primaryColor: AppTheme.primaryLight,
    scaffoldBackgroundColor: AppTheme.backgroundLight,
    brightness: Brightness.light,
    cardTheme: CardTheme(
      color: AppTheme.cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: TextTheme(
      headlineMedium: AppTheme.headingLight,
      titleLarge: AppTheme.subheadingLight,
      bodyMedium: AppTheme.bodyLight,
    ),
    dividerColor: Colors.transparent,
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: AppTheme.cardLight,
      collapsedBackgroundColor: AppTheme.cardLight,
      tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    primaryColor: AppTheme.primaryDark,
    scaffoldBackgroundColor: AppTheme.backgroundDark,
    brightness: Brightness.dark,
    cardTheme: CardTheme(
      color: AppTheme.cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: TextTheme(
      headlineMedium: AppTheme.headingDark,
      titleLarge: AppTheme.subheadingDark,
      bodyMedium: AppTheme.bodyDark,
    ),
    dividerColor: Colors.transparent,
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: AppTheme.cardDark,
      collapsedBackgroundColor: AppTheme.cardDark,
      tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
    ),
  );
} 