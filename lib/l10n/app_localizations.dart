
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:intl/intl.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString('lib/l10n/intel_${locale.languageCode}.arb');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en',  'ar','tr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = Locale('en', '');

  Locale get currentLocale => _currentLocale;

  void changeLocale(String languageCode) {
    _currentLocale = Locale(languageCode, '');
    notifyListeners();
  }

String whatIsSum(int num1, int num2) {
    return Intl.message(
      'What is $num1 + $num2?',
      name: 'whatIsSum',
      args: [num1, num2],
      desc: 'Prompt for addition verification',
    );
  }

  // Add other translations as needed
  String get verification => Intl.message('Verification', name: 'verification');
  String get incorrectAnswer => Intl.message('Incorrect answer. Try again.', name: 'incorrectAnswer');
  String get cancel => Intl.message('Cancel', name: 'cancel');
}

