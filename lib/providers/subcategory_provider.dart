import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:happy_view/widgets/subcategory_data.dart';
import 'package:happy_view/services/profanity_filter.dart'; // 👈 Import the profanity filter

class SubcategoryService {
  static final Map<String, List<Map<String, String>>> _categoryCache = {};
  final Map<String, String> _imageUrlCache = {};
  static const String _fallbackImage = 'lib/assets/images/panda_peek.webp';

  // 👇 Add ProfanityFilter instance
  static final ProfanityFilter _filter = ProfanityFilter('');
  static bool _isFilterLoaded = false;

  Future<List<Map<String, String>>> getSubcategories(
      BuildContext context, String category) async {
    // Capture AppLocalizations before async gap
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return [];
    }

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
      cleanTopics.map((topic) => _fetchTopic(localizations, topic)),
    );

    final subcategories = results.whereType<Map<String, String>>().toList();
    _categoryCache[category] = subcategories;
    return subcategories;
  }

  Future<Map<String, String>?> _fetchTopic(
      AppLocalizations localizations, String topic) async {
    try {
      final assetPath = SubcategoryData.getTopicAsset(topic);
      if (_imageUrlCache.containsKey(topic)) {
        return _createSubcategoryItem(localizations, topic, _imageUrlCache[topic]!);
      }

      _imageUrlCache[topic] = assetPath;
      return _createSubcategoryItem(localizations, topic, assetPath);
    } catch (e) {
      if (kDebugMode) print('Error resolving topic asset for $topic: $e');
      return _createSubcategoryItem(localizations, topic, _fallbackImage);
    }
  }

  Map<String, String> _createSubcategoryItem(
      AppLocalizations localizations, String topic, String image) {
    return {
      'name': SubcategoryData.getTranslatedTopic(localizations, topic),
      'query': topic,
      'image': image,
    };
  }

  void clearCache() {
    _categoryCache.clear();
    _imageUrlCache.clear();
  }
}
