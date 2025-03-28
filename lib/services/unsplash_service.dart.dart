import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class UnsplashService {
  static const String accessKey = 'rymj4kWDUWfggopViVtniGBy1FV6alObBnbHlVeWw6g';

  // List of keywords to filter out
  static final List<String> _inappropriateKeywords = [
    'nude',
    'explicit',
    'violence',
    'gore',
    'weapon',
    'graphic',
    'sexual',
    'mature',
    'adult',
    'offensive',
    'trauma',
    'blood',
    'drugs',
    'alcohol',
    'politically sensitive',
    'hate speech',
    'profanity',
    'abuse',
    'dead'
  ];

  // Advanced content filtering method

  static Future<List<Map<String, dynamic>>> fetchImages(
    String query, {
    int page = 1,
    String subcategory = '',
  }) async {
    final fullQuery = subcategory.isNotEmpty ? '$query $subcategory' : query;

    final response = await http.get(
      Uri.parse(
        'https://api.unsplash.com/search/photos?query=$fullQuery&client_id=$accessKey&page=$page&per_page=20',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Filter images using _isImageSafe
      final safeImages = (data['results'] as List)
          .where((photo) => _isImageSafe(photo))
          .map((photo) {
        return {
          'url': photo['urls']['regular'],
          'photographer': photo['user']['name'],
          'photographerLink': photo['user']['links']['html'],
          'photoLink': photo['links']['html'],
        };
      }).toList();

      return safeImages;
    } else {
      throw Exception('Failed to load images');
    }
  }

  // Comprehensive safety check
  static bool _isImageSafe(dynamic image) {
    try {
      // Check description and alt description for inappropriate content
      final description =
          (image['description'] ?? image['alt_description'] ?? '')
              .toLowerCase();
      final altDescription = (image['alt_description'] ?? '').toLowerCase();

      // Keyword filtering
      if (_containsInappropriateKeywords(description) ||
          _containsInappropriateKeywords(altDescription)) {
        return false;
      }

      // Optional: Color and aesthetic analysis
      // You could add more sophisticated filtering here
      final colors = image['color'] ?? '';
      if (_isColorSuspicious(colors)) {
        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Safety check error: $e');
      }
      return false;
    }
  }

  // Check if text contains any inappropriate keywords
  static bool _containsInappropriateKeywords(String text) {
    return _inappropriateKeywords.any((keyword) => text.contains(keyword));
  }

  // Optional color suspicion check
  static bool _isColorSuspicious(String color) {
    // This could be expanded to detect unusual or extreme color patterns
    final suspiciousColors = [
      '#000000',
      '#FF0000'
    ]; // Example: pure black, pure red

    return suspiciousColors.contains(color);
  }

  // Optional: Age verification wrapper
  static Future<List<Map<String, dynamic>>> fetchImagesWithAgeVerification(
    String query, {
    bool adultContentAllowed = false,
    int minAge = 13,
  }) async {
    if (!adultContentAllowed) {
      return fetchImages(query);
    }
    // Here you could implement more nuanced age-based filtering
    return fetchImages(query);
  }
}
