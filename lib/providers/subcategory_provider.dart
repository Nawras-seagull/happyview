import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:happy_view/services/pixabay_services.dart';
import '../l10n/app_localizations.dart';
import 'package:happy_view/widgets/subcategory_data.dart';
import 'package:happy_view/services/profanity_filter.dart'; // 👈 Import the profanity filter

class SubcategoryService {
  static final Map<String, List<Map<String, String>>> _categoryCache = {};
  final Map<String, ImageProvider> _imageCache = {};
  static const String _fallbackImage = 'lib/assets/images/panda_peek.png';

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
      if (_imageCache.containsKey(topic)) {
        return _createSubcategoryItem(localizations, topic, topic);
      }

      final images = await PixabayService.fetchImages(topic, perPage: 20);

      if (images.isNotEmpty) {
        // Pick a different image every 3 days, but check for profanity in tags
        final now = DateTime.now();
        final dayGroup = now.difference(DateTime(2020, 1, 1)).inDays ~/ 3;

        // Try to find a non-profane image, cycling through hits
        for (int i = 0; i < images.length; i++) {
          final index = (dayGroup + i) % images.length;
          final image = images[index];
          final tags = (image['title'] as String?) ?? '';
          if (!_filter.containsBadWords(tags)) {
            final imageUrl = (image['previewURL'] ??
                    image['webformatURL'] ??
                    image['largeImageURL'] ??
                    image['url']) as String?;
            if (imageUrl == null || imageUrl.isEmpty) {
              return _createSubcategoryItem(localizations, topic, _fallbackImage);
            }
            _imageCache[topic] = NetworkImage(imageUrl);
            return _createSubcategoryItem(localizations, topic, imageUrl);
          }
        }
        // If all images have profane tags, fall back
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching topic $topic: $e');
    }
    return _createSubcategoryItem(localizations, topic, _fallbackImage);
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
  }
}
