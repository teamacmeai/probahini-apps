import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en', 'US');

  Locale get currentLocale => _currentLocale;
  bool get isBangla => _currentLocale.languageCode == 'bn';

  LanguageProvider() {
    _loadLanguage();
  }

  void toggleLanguage() async {
    _currentLocale = _currentLocale.languageCode == 'en'
        ? const Locale('bn', 'BD')
        : const Locale('en', 'US');
    await _saveLanguage();
    notifyListeners();
  }

  _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      _currentLocale = languageCode == 'bn'
          ? const Locale('bn', 'BD')
          : const Locale('en', 'US');
      notifyListeners();
    }
  }

  _saveLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', _currentLocale.languageCode);
  }
}
