/* import 'dart:convert';

import 'package:http/http.dart' as http;

class UnsplashService {
  static const String _baseUrl = 'https://api.unsplash.com';
  // Made accessKey public with a getter method
  static String get accessKey => 'rymj4kWDUWfggopViVtniGBy1FV6alObBnbHlVeWw6g';

  // Fetch images for a specific category and subcategory
  static Future<List<Map<String, dynamic>>> fetchImages(String query, {int page = 1, String subcategory = ''}) async {
    final searchQuery = subcategory.isEmpty ? query : '$query $subcategory'; // Combine main category and subcategory
    final url = '$_baseUrl/search/photos?query=$searchQuery&per_page=20&page=$page&client_id=$accessKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((image) {
        return {
          'id': image['id'],
          'url': image['urls']['regular'], // Use the 'regular' size image
          'description': image['description'] ?? 'No description',
        };
      }).toList();
    } else {
      throw Exception('Failed to load images');
    }
  }

  // Added a helper method to get the base URL too if needed
  static String get baseUrl => _baseUrl;
} */

///////////////
///import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class UnsplashService {
  static const String accessKey = 'rymj4kWDUWfggopViVtniGBy1FV6alObBnbHlVeWw6g';
  
  // List of keywords to filter out
  static final List<String> _inappropriateKeywords = [
    'nude', 'explicit', 'violence', 'gore', 
    'weapon', 'graphic', 'sexual', 'mature', 
    'adult', 'offensive', 'trauma', 'blood',
    'drugs', 'alcohol', 'politically sensitive',
    'hate speech', 'profanity', 'abuse',
    'dead'
  ];

  // Advanced content filtering method
  static Future<List<Map<String, dynamic>>> fetchImages(
    String query, {
    int page = 1,
    String subcategory = '',
    int perPage = 30,
  }) async {
        final searchQuery = subcategory.isEmpty ? query : '$query $subcategory'; // Combine main category and subcategory

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.unsplash.com/search/photos?'
          'query=$query&'
          'page=$page&'
          'per_page=$perPage&'
          'client_id=$accessKey'
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];

        // Filter images based on multiple criteria
        final filteredImages = results.where((image) {
          return _isImageSafe(image);
        }).toList();

        return filteredImages.map((image) {
          return {
            'id': image['id'],
            'url': image['urls']['regular'],
            'description': image['description'] ?? image['alt_description'] ?? '',
            'photographer': image['user']['name'] ?? 'Unknown',
          };
        }).toList();
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching safe images: $e');
      }
      return [];
    }
  }

  // Comprehensive safety check
  static bool _isImageSafe(dynamic image) {
    try {
      // Check description and alt description for inappropriate content
      final description = (image['description'] ?? image['alt_description'] ?? '').toLowerCase();
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
    return _inappropriateKeywords.any((keyword) => 
      text.contains(keyword));
  }

  // Optional color suspicion check
  static bool _isColorSuspicious(String color) {
    // This could be expanded to detect unusual or extreme color patterns
    final suspiciousColors = ['#000000', '#FF0000']; // Example: pure black, pure red
    
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