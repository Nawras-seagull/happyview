import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:happy_view/services/pixabay_services.dart';
import '../l10n/app_localizations.dart';
import 'package:happy_view/widgets/subcategory_data.dart';
import 'package:http/http.dart' as http;
import 'package:happy_view/services/profanity_filter.dart'; // 👈 Import the profanity filter

class SubcategoryService {
  static final Map<String, List<Map<String, String>>> _categoryCache = {};
  final Map<String, ImageProvider> _imageCache = {};
  static const String _fallbackImage = 'lib/assets/images/logo.png';

  // 👇 Add ProfanityFilter instance
  static final ProfanityFilter _filter = ProfanityFilter('');
  static bool _isFilterLoaded = false;

  Future<List<Map<String, String>>> getSubcategories(
      BuildContext context, String category) async {
    if (!_isFilterLoaded) {
      await _filter.loadBadWords('assets/profanity/en.json');
      _isFilterLoaded = true;
    }

    if (_categoryCache.containsKey(category)) {
      return _categoryCache[category]!;
    }

    final topics = SubcategoryData.getCategoryTopics(category);

    // 👇 Filter out inappropriate topics
    final cleanTopics =
        topics.where((topic) => !_filter.containsBadWords(topic)).toList();

    final results = await Future.wait(
      cleanTopics.map((topic) => _fetchTopic(context, topic)),
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
          'https://pixabay.com/api/?key=${PixabayService.accessKey}&q=$topic&image_type=photo&safesearch=true'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['hits'].isNotEmpty) {
          // Pick a different image every 3 days, but check for profanity in tags
          final hits = data['hits'] as List;
          final now = DateTime.now();
          final dayGroup = now.difference(DateTime(2020, 1, 1)).inDays ~/ 3;

          // Try to find a non-profane image, cycling through hits
          for (int i = 0; i < hits.length; i++) {
            final index = (dayGroup + i) % hits.length;
            final hit = hits[index];
            final tags = (hit['tags'] as String?) ?? '';
            if (!_filter.containsBadWords(tags)) {
              final imageUrl = hit['webformatURL'] as String;
              _imageCache[topic] = NetworkImage(imageUrl);
              return _createSubcategoryItem(context, topic, imageUrl);
            }
          }
          // If all images have profane tags, fall back
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
      'name': SubcategoryData.getTranslatedTopic(
          AppLocalizations.of(context), topic),
      'query': topic,
      'image': image,
    };
  }

  void clearCache() {
    _categoryCache.clear();
  }
}
