import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class UnsplashService {
  static const String accessKey = 'rymj4kWDUWfggopViVtniGBy1FV6alObBnbHlVeWw6g';

// List of inappropriate keywords loaded from profanity/en.json
  static List<String> _inappropriateKeywords = [];

  /// Initialize the inappropriate keywords from the JSON file
  static Future<void> loadInappropriateKeywords() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/profanity/en.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _inappropriateKeywords = jsonList.map((e) => e.toString().toLowerCase()).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading inappropriate keywords: $e');
      }
      _inappropriateKeywords = []; // Fallback to an empty list if loading fails
    }
  }

  // Advanced content filtering method

  static Future<List<Map<String, dynamic>>> fetchImages(
    String query, {
    int page = 1,
    String subcategory = '',
  }) async {
    final fullQuery = subcategory.isNotEmpty ? '$query $subcategory' : query;
 try {
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
          'location': photo['location'] ?? '',
          'download': photo['links']['download'],
          'downloadLocation': photo['links']['download_location'],
        };
      }).toList();

      return safeImages;
   } else if (response.statusCode == 403) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to load images: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching images: $e');
      }
      throw Exception('An error occurred while fetching images.');
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
