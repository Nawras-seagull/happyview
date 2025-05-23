// pixabay_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'profanity_filter.dart';

class PixabayService {
  static const String accessKey = '49682872-0649c795fb759cec1a2ddb865';
  static const String baseUrl = 'https://pixabay.com/api/';

  static final ProfanityFilter _filter = ProfanityFilter('');
  static bool _isFilterLoaded = false;

  static Future<List<Map<String, dynamic>>> fetchImages(
    String query, {
    int page = 1,
    int perPage = 20,
    String? category,
    bool safesearch = true,
  }) async {
    try {
      // Load bad words only once
      if (!_isFilterLoaded) {
        await _filter.loadBadWords('assets/profanity/en.json');
        _isFilterLoaded = true;
      }

      final url = Uri.parse(
        '$baseUrl?key=$accessKey'
        '&q=${Uri.encodeQueryComponent(query)}'
        '&page=$page'
        '&per_page=$perPage'
        '&image_type=photo'
        '&safesearch=${safesearch ? "true" : "false"}'
        '${category != null ? '&category=$category' : ''}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final parsed = await compute(_parseResponse, response.body);

        final filtered = parsed.where((image) {
          final tags = (image['title'] as String?)?.split(',') ?? [];
          return tags.every((tag) => !_filter.containsBadWords(tag.trim()));
        }).toList();

        return filtered;
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
        'url': hit['webformatURL'],
        'largeUrl': hit['largeImageURL'],
        'photographer': hit['user'],
        'safesearch': hit['safesearch'],
        'photoLink': 'https://pixabay.com/users/${hit['user']}-${hit['user_id']}/',
        'download': hit['webformatURL'],
        'title': hit['tags'],
        'likes': hit['likes'],
      };
    }).toList();
  }
}