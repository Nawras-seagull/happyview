// pixabay_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'backend_config.dart';
import 'profanity_filter.dart';

/// Fetches images via the HappyView backend proxy — never calls Pixabay directly
/// (the API key lives server-side only).
class PixabayService {
  static const String baseUrl = '${BackendConfig.baseUrl}/api/images';

  static final ProfanityFilter _filter = ProfanityFilter('');
  static bool _isFilterLoaded = false;

  static Future<List<Map<String, dynamic>>> fetchImages(
    String query, {
    int page = 1,
    int perPage = 12,
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
        '$baseUrl?q=${Uri.encodeQueryComponent(query)}'
        '&page=$page'
        '&perPage=$perPage'
        '&safesearch=${safesearch ? "true" : "false"}'
        '${category != null ? '&category=${Uri.encodeQueryComponent(category)}' : ''}',
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

  // Backend already projects hits into this shape, so just decode the list.
  static List<Map<String, dynamic>> _parseResponse(String responseBody) {
    final List<dynamic> data = json.decode(responseBody);
    return data.cast<Map<String, dynamic>>();
  }
}