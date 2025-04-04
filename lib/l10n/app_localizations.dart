import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


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
  String imageIndex(int index, int total) {
    return Intl.message(
      'Image $index of $total',
      name: 'imageIndex',
      args: [index, total],
      desc: 'Displayed image index and total number of images',
    );
  }
  // Add other translations as needed
  String get verification => Intl.message('Verification', name: 'verification');
  String get incorrectAnswer => Intl.message('Incorrect answer. Try again.', name: 'incorrectAnswer');
  String get cancel => Intl.message('Cancel', name: 'cancel');
}
