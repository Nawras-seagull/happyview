// subcategory_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:happy_view/services/unsplash_service.dart';

import 'package:happy_view/widgets/subcategory_data.dart';
import 'package:http/http.dart' as http;


class SubcategoryService {
  static final Map<String, List<Map<String, String>>> _categoryCache = {};
  final Map<String, ImageProvider> _imageCache = {};
  static const String _fallbackImage = 'https://via.placeholder.com/300';

  Future<List<Map<String, String>>> getSubcategories(
      BuildContext context, String category) async {
    if (_categoryCache.containsKey(category)) {
      return _categoryCache[category]!;
    }

    final topics = SubcategoryData.getCategoryTopics(category);
    final results = await Future.wait(
      topics.map((topic) => _fetchTopic(context, topic)),
    );
    
    final subcategories = results.whereType<Map<String, String>>().toList();
    _categoryCache[category] = subcategories;
    return subcategories;
  }

  Future<Map<String, String>?> _fetchTopic(
      BuildContext context, String topic) async {
    try {
      if (_imageCache.containsKey(topic)) {
        return _createSubcategoryItem(context, topic, topic);
      }

      final response = await http.get(Uri.parse(
          'https://api.unsplash.com/search/photos?query=$topic&client_id=${UnsplashService.accessKey}&per_page=1'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        if (data['results'].isNotEmpty) {
          final imageUrl = data['results'][0]['urls']['regular'] as String;
          _imageCache[topic] = NetworkImage(imageUrl);
          return _createSubcategoryItem(context, topic, imageUrl);
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching topic $topic: $e');
    }
    return _createSubcategoryItem(context, topic, _fallbackImage);
  }

  Map<String, String> _createSubcategoryItem(
      BuildContext context, String topic, String image) {
    return {
      'name': SubcategoryData.getTranslatedTopic(AppLocalizations.of(context), topic),
      'query': topic,
      'image': image,
    };
  }

  void clearCache() {
    _categoryCache.clear();
  }
}