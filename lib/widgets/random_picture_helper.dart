import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:happy_view/screens/fullscreen_image_viewer.dart';
import 'package:happy_view/widgets/categories.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  // Prefetch more images in the background
  Future<void> _prefetchMoreImages() async {
    if (_isPrefetching) return;
    
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
    
    // Start prefetching
    _prefetchMoreImages();
  }

  // Fetch a random image from the API
  Future<Map<String, dynamic>?> _fetchRandomImage() async {
    try {
      final random = Random();
      // Hard-coded topics to avoid dependency on context
      final topics = ['nature', 'animals', 'happy', 'art', 'travel', 'food'];
      final randomTopic = topics[random.nextInt(topics.length)];

      final response = await http.get(
        Uri.parse(
          'https://api.unsplash.com/photos/random?query=$randomTopic&client_id=rymj4kWDUWfggopViVtniGBy1FV6alObBnbHlVeWw6g',
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

// Improved function to show random pictures with reduced delay
Future<void> showRandomPicture(BuildContext context) async {
  final random = Random();
  final localizations = AppLocalizations.of(context)!;
  
  // Show loading indicator immediately (with a more engaging animation)
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
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
    
    // If no prefetched image is available, fetch one
    if (imageData == null) {
      // Fetch categories dynamically
      final categories = getCategories(localizations);
      final topics = categories.map((category) => category['query']).toList();

      // Select a random topic
      final randomTopic = topics[random.nextInt(topics.length)];

      // Make the API request
      final response = await http.get(
        Uri.parse(
          'https://api.unsplash.com/photos/random?query=$randomTopic&client_id=rymj4kWDUWfggopViVtniGBy1FV6alObBnbHlVeWw6g',
        ),
      );

      if (response.statusCode == 200) {
        // Parse JSON off the main thread
        imageData = await compute(parseJson, response.body);
      } else {
        throw Exception('Failed to load image');
      }
    }

    if (!context.mounted) return;
    
    // Close loading dialog
    Navigator.pop(context);

    // Navigate to image view
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageView(
          imageUrl: imageData!['urls']['regular'],
          photographerName: imageData['user']['name'],
          photoLink: imageData['links']['html'],
        ),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    
    // Ensure we always dismiss the loading dialog even on error
    if (ModalRoute.of(context)?.isCurrent != true) {
      Navigator.pop(context);
    }

    // Display error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}

// Initialize prefetching when the app starts
void initializeImagePrefetching(BuildContext context) {
  ImagePrefetcher().initialize(context);
}