import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  static const String languageCode = 'languageCode';
  
  Locale _currentLocale = Locale('en');
  Locale get currentLocale => _currentLocale;

  LanguageProvider() {
    _loadSavedLanguage();
  }

  // Load the saved language preference
  void _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(languageCode);
    
    if (savedLanguage != null) {
      _currentLocale = Locale(savedLanguage);
      notifyListeners();
    }
  }

  // Change the app's language
  void changeLanguage(String languageCode) async {
    if (languageCode == _currentLocale.languageCode) return;
    
    _currentLocale = Locale(languageCode);
    
    // Save the selected language
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(languageCode, languageCode);
    
    notifyListeners();
  }

  // Check if the current language is RTL
  bool isRtl() {
    return _currentLocale.languageCode == 'ar';
  }
}