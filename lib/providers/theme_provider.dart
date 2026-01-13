import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  Color _accentColor = const Color(0xFFD86B8B); // Deep rose pink

  bool get isDarkMode => _isDarkMode;
  Color get accentColor => _accentColor;
  ThemeData get currentTheme => _isDarkMode ? _darkTheme : _lightTheme;

  // LIGHT THEME
  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: const Color(0xFFD86B8B), // Deep rose
    scaffoldBackgroundColor: const Color(0xFFFFF9FA), // Very soft pink-white
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFF9FA),
      foregroundColor: Color(0xFFD86B8B),
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Color(0xFFD86B8B),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD86B8B),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.black87, fontSize: 14),
      titleLarge: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      labelLarge: TextStyle(color: Colors.white, fontSize: 16),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEFA2B4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD86B8B), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Color(0xFF6B6B6B)),
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.pink,
      accentColor: const Color(0xFFD86B8B),
      backgroundColor: const Color(0xFFFFF9FA),
    ),
  );

  // DARK THEME
  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    primaryColor: const Color(0xFFEFA2B4),
    scaffoldBackgroundColor: const Color(0xFF1B1B1B),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1B1B1B),
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF2A2A2A),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD86B8B),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      labelLarge: TextStyle(color: Colors.white, fontSize: 16),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEFA2B4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD86B8B), width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      labelStyle: const TextStyle(color: Color(0xFFD1D5DB)),
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.pink,
      accentColor: const Color(0xFFD86B8B),
      backgroundColor: const Color(0xFF1B1B1B),
    ),
  );

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _saveTheme();
    notifyListeners();
  }

  void setAccentColor(Color newColor) async {
    _accentColor = newColor;
    await _saveAccentColor();
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    final accentColorValue = prefs.getInt('accentColor');
    if (accentColorValue != null) {
      _accentColor = Color(accentColorValue);
    }
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  Future<void> _saveAccentColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accentColor', _accentColor.value);
  }
}
