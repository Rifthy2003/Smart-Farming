import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en'); // Default is English

  Locale get locale => _locale;

  LocaleProvider() {
    _loadSavedLocale();
  }

  // Change language and save to phone memory
  void setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners(); // This tells the WHOLE APP to rebuild
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  // Load the language when the app starts
  void _loadSavedLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? code = prefs.getString('language_code');
    if (code != null) {
      _locale = Locale(code);
      notifyListeners();
    }
  }
}