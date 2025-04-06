import 'dart:convert';
import 'package:flutter/services.dart';

class ProfanityFilter {
  List<String> _badWords = [];

  Future<void> loadBadWords(String path) async {
    final String jsonString = await rootBundle.loadString(path);
    final List<dynamic> decoded = json.decode(jsonString);
    _badWords = (decoded).map((word) => word.toString().toLowerCase()).toList();
  }

  bool containsBadWords(String text) {
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    return words.any((word) => _badWords.contains(word));
  }

  String censor(String text) {
    final words = text.split(' ');
    return words.map((word) {
      return _badWords.contains(word.toLowerCase())
          ? '*' * word.length
          : word;
    }).join(' ');
  }
}