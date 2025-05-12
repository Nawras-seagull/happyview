// pixabay_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class PixabayService {
  static const String accessKey = '49682872-0649c795fb759cec1a2ddb865';
  static const String baseUrl = 'https://pixabay.com/api/';

  static Future<List<Map<String, dynamic>>> fetchImages(
    String query, {
    int page = 1,
    int perPage = 20,
    String? category, // Add category parameter for Pixabay's categories
    bool safesearch = true, // Add safesearch parameter

  }) async {
    try {
      // Build URL with optional category
      final url = Uri.parse(
        '$baseUrl?key=$accessKey'
        '&q=${Uri.encodeQueryComponent(query)}'
        '&page=$page'
        '&per_page=$perPage'
        '&image_type=photo'
              '&safesearch=${safesearch ? "true" : "false"}' // Add safesearch

        '${category != null ? '&category=$category' : ''}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return await compute(_parseResponse, response.body);
      } else {
        throw Exception('Failed to load images: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load images: $e');
    }
  }

  static List<Map<String, dynamic>> _parseResponse(String responseBody) {
    final jsonData = json.decode(responseBody);
    final List<dynamic> hits = jsonData['hits'];

    return hits.map((hit) {
      return {
        'id': hit['id'],
        'url': hit['webformatURL'], // Medium size image
        'largeUrl': hit['largeImageURL'], // Large size image
        'photographer': hit['user'],
        'safesearch': hit['safesearch'],
        'photoLink': 'https://pixabay.com/users/${hit['user']}-${hit['user_id']}/',
        'download': hit['webformatURL'], // Pixabay doesn't require tracking downloads,
         'title': hit['tags'], // Adding title (Pixabay uses tags as title)
        'likes': hit['likes'], 
      
       
      };
    }).toList();
  }
}



