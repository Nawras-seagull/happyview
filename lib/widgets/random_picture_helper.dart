import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:happy_view/services/unsplash_service.dart';
import 'package:http/http.dart' as http;
import 'package:happy_view/screens/fullscreen_image_viewer.dart';
import 'package:happy_view/widgets/categories.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// Top-level function for parsing JSON off the main thread
Map<String, dynamic> parseJson(String responseBody) {
  return json.decode(responseBody);
}

// Class to manage prefetched images
class ImagePrefetcher {
  static final ImagePrefetcher _instance = ImagePrefetcher._internal();
  factory ImagePrefetcher() => _instance;
  ImagePrefetcher._internal();

  // Queue of prefetched image data
  final List<Map<String, dynamic>> _prefetchedImages = [];
  bool _isPrefetching = false;
  List<String>? _availableTopics;

  // Get a prefetched image if available
  Map<String, dynamic>? getRandomPrefetchedImage() {
    if (_prefetchedImages.isEmpty) {
      return null;
    }

    final random = Random();
    final index = random.nextInt(_prefetchedImages.length);
    final image = _prefetchedImages.removeAt(index);

    // Start prefetching new images if we're running low
    if (_prefetchedImages.length < 3 && !_isPrefetching) {
      _prefetchMoreImages();
    }

    return image;
  }

  // Set available topics from categories
  void setAvailableTopics(List<String> topics) {
    _availableTopics = topics;
  }
  // Prefetch more images in the background
  Future<void> _prefetchMoreImages() async {
    if (_isPrefetching || _availableTopics == null || _availableTopics!.isEmpty) return;

    _isPrefetching = true;
    try {
      // Prefetch 5 more images
      for (int i = 0; i < 5; i++) {
        final image = await _fetchRandomImage();
        if (image != null) {
          _prefetchedImages.add(image);
          // Also prefetch the actual image file
          await DefaultCacheManager().downloadFile(image['urls']['regular']);
        }
      }
    } finally {
      _isPrefetching = false;
    }
  }

  // Initialize by prefetching some images
  Future<void> initialize(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final categories = getCategories(localizations);

    // Extract topics from categories
    final topics = categories.map((category) => category['query'].toString()).toList();
    setAvailableTopics(topics);
    // Start prefetching images
    _prefetchMoreImages();
  }

  // Fetch a random image from the API
  Future<Map<String, dynamic>?> _fetchRandomImage() async {
    try {
      final random = Random();
      // Hard-coded topics to avoid dependency on context
      final randomTopic = _availableTopics![random.nextInt(_availableTopics!.length)];

      final response = await http.get(
        Uri.parse(
          'https://api.unsplash.com/photos/random?query=$randomTopic&client_id=${UnsplashService.accessKey}',
        ),
      );

      if (response.statusCode == 200) {
        // Parse JSON off the main thread
        return await compute(parseJson, response.body);
      }
    } catch (e) {
      debugPrint('Error prefetching image: ${e.toString()}');
    }
    return null;
  }
}
Future<void> showRandomPicture(BuildContext context) async {
  final random = Random();
  final localizations = AppLocalizations.of(context)!;

  // Show loading indicator immediately
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(
                          alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const SpinKitPulse(
          color: Color.fromARGB(255, 8, 127, 148),
          size: 50.0,
        ),
      ),
    ),
  );

  try {
    // Try to get a prefetched image first
    Map<String, dynamic>? imageData = ImagePrefetcher().getRandomPrefetchedImage();

    // If we have a prefetched image, use it
    if (imageData != null) {
      if (!context.mounted) return;
      Navigator.pop(context); // Remove loading indicator
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImageView(
            imageUrl: imageData['urls']['regular'],
            photographerName: imageData['user']['name'],
            photoLink: imageData['links']['html'],
            downloadUrl: imageData['links']['download'], 
            // Pass the download URL
          ),
        ),
      );
      return;
    }

    // If no prefetched image, fetch a new one
    final categories = getCategories(localizations);
    final topics = categories.map((category) => category['query']).toList();
    final randomTopic = topics[random.nextInt(topics.length)];

    final response = await http.get(
      Uri.parse(
        'https://api.unsplash.com/photos/random?query=$randomTopic&client_id=rymj4kWDUWfggopViVtniGBy1FV6alObBnbHlVeWw6g',
      ),
    );

    if (!context.mounted) return;
    Navigator.pop(context); // Remove loading indicator

    if (response.statusCode == 200) {
      final data = await compute(parseJson, response.body);

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImageView(
            imageUrl: data['urls']['regular'],
            photographerName: data['user']['name'],
            photoLink: data['links']['html'],
            downloadUrl: data['links']['download'], // Pass the download URL
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load image')),
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    Navigator.pop(context); // Remove loading indicator on error
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}
// Initialize prefetching when the app starts
void initializeImagePrefetching(BuildContext context) {
  ImagePrefetcher().initialize(context);
}
