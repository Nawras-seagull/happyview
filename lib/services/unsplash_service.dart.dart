import 'dart:convert';

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
}